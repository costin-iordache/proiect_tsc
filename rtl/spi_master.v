// BUG_NEGEDGE_SCLK
// BUG_DIVIDER
// BUG_FIFO_FULL
// BUG_FIFO_ACCESS
// BUG_OUTPUT_DATA_POSITION_2
// BUG_SCLK_TOGGLE_WHILE_SS

`ifndef DATA_WIDTH_SIMULATION
`define DATA_WIDTH_SIMULATION 4
`endif

`ifndef FIFO_DEPTH_SIMULATION
`define FIFO_DEPTH_SIMULATION 8
`endif

`ifndef DIVIDER_SIMULATION
`define DIVIDER_SIMULATION 4
`endif

module spi_master  #(
parameter DATA_WIDTH = `DATA_WIDTH_SIMULATION,
parameter FIFO_DEPTH = `FIFO_DEPTH_SIMULATION,
parameter DIVIDER    = `DIVIDER_SIMULATION
)(
input                     clk      ,
input                     rst_n    ,

input [DATA_WIDTH-1:0]    data_i   ,
input                     valid    ,
output                    ready    ,

output reg                ss       ,
output reg                sclk     ,
output reg                mosi     , 
input                     miso
);
 
 
 
reg [DATA_WIDTH - 1:0] fifo [FIFO_DEPTH - 1:0];

wire fifo_full   ;
wire fifo_empty  ;
wire negedge_ss  ;
reg ss_d        ;            // ss intarziat
reg sclk_d      ;            // sclk intarziat
wire posedge_sclk; 
wire [DATA_WIDTH-1:0] real_cnt;
 


// pt bit counter
wire bit_overflow, posedge_bit_overflow;
reg bit_overflow_d ;
wire [DATA_WIDTH-1:0] bit_cnt     ;
wire bit_load    ;

// pt sclk counter
wire sclk_load    ;
wire [DIVIDER-1:0] sclk_cnt     ;
wire sclk_enable  ;
wire sclk_overflow;


reg [FIFO_DEPTH-1:0] r_counter;
reg [FIFO_DEPTH-1:0] w_counter;
reg [FIFO_DEPTH-1:0] rx_spi   ;
reg [FIFO_DEPTH-1:0] no_fifo_elements;



// configurare semnal ready si semnale ajutatoare
assign ready = ~fifo_full                                   ;
assign negedge_ss = ~ss && ss_d                             ;
`ifndef BUG_NEGEDGE_SCLK // daca acest bug este activat, datele se vor scrie si citi pe frontul descrescator de sclk si nu pe cel crescator
assign posedge_sclk = sclk && ~sclk_d                       ;
`else
assign posedge_sclk = ~sclk && sclk_d                       ;

`endif

assign negedge_sclk = ~sclk && sclk_d                       ;

assign bit_load = bit_overflow || negedge_ss                ;
assign posedge_bit_overflow = ~bit_overflow_d & bit_overflow;


// configurare repere pentru fifo
assign fifo_empty = (no_fifo_elements == 0);
`ifndef BUG_FIFO_FULL // daca acest bug este activat, semnalul de fifo_full nu va mai fi niciodata 1
assign fifo_full  = ( no_fifo_elements == FIFO_DEPTH)? 1 : 0;
`else
assign fifo_full  = 0;
`endif


// bit_overflow intarziat, folosit pentru a crea posedge_bit_overflow
always @(posedge clk or negedge rst_n)
if (~rst_n)               bit_overflow_d <= 0           ;else
                          bit_overflow_d <= bit_overflow; 
                          

//semnalul ss/ cip_enable

`ifdef BUG_SCLK_TOGGLE_WHILE_SS // daca este activat acest bug, semnalul sclk se mai modifica (are un front descrescator) si dupa ce semnalul ss s-a dezactivat (s-a dus in 1)
always @(posedge clk or negedge rst_n)
if (~rst_n)               ss <= 1         ;else
                          ss <= fifo_empty; 
`else
always @(posedge clk or negedge rst_n)
if (~rst_n)               ss <= 1         ;else
  if (no_fifo_elements >0) ss<=0;
  else if (fifo_empty && negedge_sclk) ss <= 1;
  else ss <= ss;
`endif
 
 
//ss intarziat
always @(posedge clk or negedge rst_n)
if (~rst_n)               ss_d <= 1 ;else
                          ss_d <= ss; 


//semnalul de sclk                          
always @(posedge clk or negedge rst_n)
if (~rst_n)                         sclk <= 0;else
if (ss)                             sclk <= 0;else
if (sclk_cnt ==DIVIDER/2)           sclk <= ~sclk;
                                    
  
  
//sclk intarziat
always @(posedge clk or negedge rst_n)
if (~rst_n)               sclk_d <= 0   ;else
                          sclk_d <= sclk;


//counter pt elementele scrise in fifo
always @(posedge clk or negedge rst_n)
if (~rst_n)               w_counter <= 0                         ;else
`ifndef BUG_FIFO_ACCESS // daca se activeaza acest bug, ultima pozitie din FIFO nu va fi scrisa niciodata cu date
if (valid && ready )      w_counter <= (w_counter + 1)%FIFO_DEPTH;else
`else
if (valid && ready )      w_counter <= (w_counter + 1)%(FIFO_DEPTH-1);else
`endif
                          w_counter <= w_counter                 ;


//counter pt elementele citite din fifo
always @(posedge clk or negedge rst_n)
if (~rst_n)                               r_counter <= 0                         ;else
`ifndef BUG_OUTPUT_DATA_POSITION_2 // daca acest bug este activat, in loc de datele din fifo de pe pozitia 2 se vor transmite pe miso datele din fifo de pe pozitia 0
if (bit_overflow && posedge_sclk)         r_counter <= (r_counter + 1)%FIFO_DEPTH;else
`else
if (bit_overflow && posedge_sclk)         r_counter <= ((r_counter + 1)%FIFO_DEPTH == 2) ? 0: (r_counter + 1)%FIFO_DEPTH;else
`endif
                                          r_counter <= r_counter                 ;


//cate elemente sunt in fifo: number of fifo elements
always @(posedge clk or negedge rst_n)
if (~rst_n)                                        no_fifo_elements <= 0                   ;else 
begin
if (valid && ready && no_fifo_elements<FIFO_DEPTH) no_fifo_elements <= no_fifo_elements + 1;
if (bit_overflow && posedge_sclk )                 no_fifo_elements <= no_fifo_elements - 1;
end


//modelare mosi
always @(posedge clk or negedge rst_n)
if (~rst_n)                 mosi <= 0;else
if (~ss && posedge_sclk )   mosi <= fifo[r_counter][real_cnt];


//din cauza ca in simulare imi numara un bit in spate
assign real_cnt = bit_cnt+1;


//dau valori lui fifo, care apoi vor fi puse pe mosi
always @(posedge clk or negedge rst_n)
if(valid &&ready)      fifo[w_counter] <= data_i;


//modelare miso
always @(posedge clk or negedge rst_n)
if (~rst_n)                rx_spi <= 0;else
if (~ss && posedge_sclk)   rx_spi[bit_cnt] <= miso;


//instantiere counter bit
counter #(
  .WIDTH (DATA_WIDTH)
)i_bit_counter(
  .clk      (clk           ),
  .rst_n    (rst_n         ),
  .enable_i (posedge_sclk || negedge_ss),
  .up_down_i(1'b0          ),
  .load_i   (bit_load      ),
  .data_i   (DATA_WIDTH - 2),
  .overflow (bit_overflow  ),
  .cnt_o    (bit_cnt       )
);


assign sclk_load = sclk_overflow || negedge_ss;
assign sclk_enable = ~ss ;


//instantiere counter sclk
counter #(
  .WIDTH (DIVIDER)
)i_sclk_counter(
  .clk      (clk          ),
  .rst_n    (rst_n        ),
  .enable_i (sclk_enable  ),
  .up_down_i(1'b0         ),
  .load_i   (sclk_load    ),
  `ifndef BUG_DIVIDER // daca este activat acest bug, se va modifica frecventa semnalului SCLK
  .data_i   (DIVIDER-2    ),
  `else
  .data_i   (DIVIDER/2+1    ),
  `endif
  .overflow (sclk_overflow),
  .cnt_o    (sclk_cnt     )
);


endmodule 
