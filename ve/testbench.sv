//-------------------------------------------------------------------------
//				www.verificationguide.com   testbench.sv
//-------------------------------------------------------------------------
//tbench_top or testbench top, this is the top most file, in which DUT(Design Under Test) and Verification environment are connected. 
//-------------------------------------------------------------------------
`timescale 1ns/1ps
//including interface and testcase files
`include "vr_interface.sv"
`include "spi_interface.sv"

//-------------------------[NOTE]---------------------------------
//Particular testcase can be run by uncommenting, and commenting the rest
//`include "random_test.sv"
//`include "wr_rd_test.sv"
`include "basic_test.sv"
//----------------------------------------------------------------

module testbench;
  
  //clock and reset signal declaration
  bit clk;
  
  //clock generation
  always #5 clk = ~clk;
  
  
  
  //creatinng instance of interface, inorder to connect DUT and testcase
  vr_intf vr_intf(clk,rst_intf.reset);
  spi_intf spi_intf(clk,rst_intf.reset);
  reset_intf rst_intf(clk);
  
  //Testcase instance, interface handle is passed to test as an argument
  test t1(vr_intf, spi_intf, rst_intf);
  
  //DUT instance, interface signals are connected to the DUT ports
  spi_master DUT (
    .clk    (vr_intf.clk),
    .rst_n  (rst_intf.reset),
    .data_i (vr_intf.data),
    .valid  (vr_intf.valid),
    .ready  (vr_intf.ready),
    .ss     (spi_intf.ss),
    .sclk   (spi_intf.sclk),
    .mosi   (spi_intf.mosi),
    .miso   (spi_intf.miso)
    );
  
endmodule