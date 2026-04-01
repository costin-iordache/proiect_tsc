//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
`define DATA_WIDTH 8

interface vr_intf(input logic clk, reset);
  
  //declaring the signals
  logic valid;
  logic ready;
  logic [`DATA_WIDTH-1:0] data;
  
  //semnalele din clocking block sunt sincrone cu frontul crescator de ceas
  //driver clocking block
  clocking driver_cb @(posedge clk);
    //semnalele de intrare sunt citite o unitate de timp inainte frontului de ceas, iar semnalele de iesire sunt citite o unitate de timp dupa frontul de ceas; astfel se elimina situatiile in care se fac scrieri sau citiri in acelasi timp
    input ready;
    output data;
    output valid;
  endclocking
  
  //monitor clocking block
  clocking monitor_cb @(posedge clk);
    input ready;
    input data;
    input valid;
  endclocking
  
  //driver modport
  modport DRIVER  (clocking driver_cb,input clk,reset);
  
  //monitor modport  
  modport MONITOR (clocking monitor_cb,input clk,reset);

  property p_data_valid;
    @(posedge clk) disable iff (reset==0) (valid == 1'b1) |-> (!$isunknown(data));
  endproperty

  property p_ready_valid;
    @(posedge clk) disable iff (reset==0) (valid == 1'b1) |-> (ready == 1'b1);
  endproperty

  data_valid: assert property (p_data_valid) 
  else $error("DATA is not valid while VALID is active");
  DATA_VALID: cover property (p_data_valid);
  ready_valid: assert property (p_ready_valid) 
  else $error("READY is not asserted while VALID is active");
  READY_VALID: cover property (p_ready_valid);
  
endinterface