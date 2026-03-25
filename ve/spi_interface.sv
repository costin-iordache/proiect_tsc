//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
interface spi_intf(input logic clk,reset);
  
  //declaring the signals
  logic sclk;
  logic ss;
  logic mosi;
  logic miso;
  
  //semnalele din clocking block sunt sincrone cu frontul crescator de ceas
  //driver clocking block
  clocking driver_cb @(posedge clk);
    input  sclk;  
    input  ss;  
    input  mosi;  
    output miso;
  endclocking
  
  //monitor clocking block
  clocking monitor_cb @(posedge clk);
    input sclk;
    input ss;
    input mosi;
    input miso;
  endclocking
  
  //driver modport
  modport DRIVER  (clocking driver_cb,input clk,reset);
  
  //monitor modport  
  modport MONITOR (clocking monitor_cb,input clk,reset);

  property p_sclk_active_only_when_ss_active;
    @(posedge clk) disable iff (reset==0) (ss == 1'b0) |-> (!$isunknown(sclk));
  endproperty

  property p_mosi_valid_only_when_ss_active;
    @(posedge clk) disable iff (reset==0) (ss == 1'b0) |-> (!$isunknown(mosi));
  endproperty

  property p_miso_valid_only_when_ss_active;
    @(posedge clk) disable iff (reset==0) (ss == 1'b0) |-> (!$isunknown(miso));
  endproperty

  miso_valid: assert property (p_miso_valid_only_when_ss_active) 
  else $error("MISO is valid while SS is inactive");
  MISO_VALID: cover property (p_miso_valid_only_when_ss_active);

  mosi_valid: assert property (p_mosi_valid_only_when_ss_active) 
  else $error("MOSI is valid while SS is inactive");
  MOSI_VALID: cover property (p_mosi_valid_only_when_ss_active);

  sclk_valid: assert property (p_sclk_active_only_when_ss_active) 
  else $error("SCLK is active while SS is inactive");
  SCLK_VALID: cover property (p_sclk_active_only_when_ss_active);

endinterface