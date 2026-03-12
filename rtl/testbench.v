`timescale 1ns/1ns
module testbench;

parameter DATA_WIDTH = 4;
parameter FIFO_DEPTH = 8;
parameter DIVIDER    = 4;

reg                   clk   ;
reg                   rst_n ;
              
reg [DATA_WIDTH-1:0]  data_i;
reg                   valid ;
wire                  ready ;

wire                  ss    ;   //cip enable/slave select
wire                  sclk  ;   //clock spi
wire                  mosi  ;   //master out sleve in
reg                   miso  ;   // master in slave out


// 5 GHz clock generator
initial begin
  clk <= 0;
  forever #5 clk <= ~clk;
end


  
//reset generator
initial begin
  rst_n <= 0;
  repeat (20) @(posedge clk);
  rst_n <= 1;
end

initial begin
  forever begin
  @(negedge sclk)
  miso <= $random();
  end
end

//initial begin
//  valid  <= 0;
//  data_i <= 0;
//  @(posedge rst_n);
//  @(posedge clk);
//  valid  <= 1;
//  data_i <= 15;
//  @(posedge clk);
//  valid  <= 0;
//  repeat(10) @(posedge clk);
//  valid  <= 1;
//  data_i <= 0;
//  @(posedge clk);
//   valid  <= 0;
//   data_i <= 5;
//  repeat(10) @(posedge clk);
//  valid  <= 1;
//  data_i <= 15;
//  @(posedge clk);
//  valid  <= 0;
//   @(posedge clk);
//  valid  <= 1;
//  data_i <= 0;
//  @(posedge clk);
//  valid  <= 0;
//    @(posedge clk);
//  valid  <= 1;
//  data_i <= 15;
//  @(posedge clk);
//  valid  <= 0;
//    @(posedge clk);
//  valid  <= 1;
//  data_i <= 5;
//  
//  repeat(1)@(posedge clk);
//  valid  <= 1;
//  data_i <= 10;
//  repeat(3)@(posedge clk);
//  valid  <= 1;
//  data_i <= 7;
//  
//  repeat(15)@(posedge clk);
//  valid  <= 0;
//  repeat(8)@(posedge clk);
//  valid  <= 0;
//  #3000
//  $stop;
//  
//end


initial begin
  
  valid  <= 0;
  data_i <= 0;
  @(negedge rst_n);
  @(posedge rst_n);
  @(posedge clk);
  
  write(15,0);
  write(0,0);
  write(5,3);
  write(15,5);
  write(0,1);
  write(15,0);
  write(5,0);
  write(10,3);
  write(7,5);
  write(3,1);
  
  repeat(300)@(posedge clk); 
  $stop;

end

spi_master#(
  .DATA_WIDTH (DATA_WIDTH),
  .FIFO_DEPTH (FIFO_DEPTH),
  .DIVIDER    (DIVIDER   )
)i_spi_master(
  .clk    (clk   ),
  .rst_n  (rst_n ),

  .valid  (valid ),
  .ready  (ready ),
  .data_i (data_i),

  .sclk   (sclk  ),
  .ss     (ss    ),
  .mosi   (mosi  ),
  .miso   (miso  )
);


task write;
  input [DATA_WIDTH-1:0] data ;
  input [5         -1:0] delay;
begin
  valid <= 1   ;
  data_i <= data;
  @(posedge clk);
  
  while (~ready) @(posedge clk);
  
  valid <= 0;
  repeat (delay) @(posedge clk);
end
endtask

endmodule