//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------

//in mediul de verificare se instantiaza toate componentele de verificare
// `include "vr_transaction.sv"
// `include "spi_transaction.sv"
// `include "vr_generator.sv"
// `include "vr_driver.sv"
// `include "vr_monitor.sv"
// `include "spi_generator.sv"
`include "spi_driver.sv"
`include "spi_monitor.sv"
// `include "coverage.sv"
// `include "scoreboard.sv"

class environment;
  
  //componentele de verificare sunt declarate
  reset_driver rst_drv;

  //vr generator driver and monitor instance
  vr_generator  vr_gen;
  vr_driver     vr_driv;
  vr_monitor    vr_mon;
  
  //mailbox handle's
  mailbox vr_gen2driv;
  mailbox vr_mon2scb;
  
  //event for synchronization between generator and test
  event vr_gen_ended;
  
  //spi generator driver and monitor instance
  spi_generator  spi_gen;
  spi_driver     spi_driv;
  spi_monitor    spi_mon;

  // scoreboard scb;
  
  //mailbox handle's
  mailbox spi_gen2driv;
  mailbox spi_mon2scb;
  
  //event for synchronization between generator and test
  event spi_gen_ended;

  //virtual interface
  virtual spi_intf spi_vif;
  virtual vr_intf vr_vif;
  
  //constructor
  function new(virtual vr_intf vr_vif, virtual spi_intf spi_vif);
    //get the interface from test
    this.vr_vif = vr_vif;
    this.spi_vif = spi_vif;

    rst_drv = new(vr_vif);
    
    //creating the mailbox (Same handle will be shared across generator and driver)
    vr_gen2driv = new();
    vr_mon2scb  = new();
    spi_gen2driv = new();
    spi_mon2scb  = new();
    
    //componentele de verificare sunt create
    //creating generator and driver
    vr_gen  = new(vr_gen2driv,vr_gen_ended);
    vr_driv = new(vr_vif,vr_gen2driv);
    vr_mon  = new(vr_vif,vr_mon2scb);

    spi_gen  = new(spi_gen2driv,spi_gen_ended);
    spi_driv = new(spi_vif,spi_gen2driv);
    spi_mon  = new(spi_vif,spi_mon2scb);
  endfunction
  
  //
  task pre_test();
    vr_driv.reset();
    spi_driv.reset();
  endtask
  
  task test();
    fork 
    vr_gen.main();
    spi_gen.main();
    vr_mon.main();
    spi_mon.main();
    join_any
  endtask
  
  task post_test();
    wait(vr_gen_ended.triggered);
    wait(spi_gen_ended.triggered);
    //se urmareste ca toate datele generate sa fie transmise la DUT si sa ajunga si la scoreboard
    wait(vr_gen.repeat_count == vr_driv.no_transactions);
    wait(spi_gen.repeat_count == spi_driv.no_transactions);
    // wait(vr_gen.repeat_count == scb.no_transactions);
  endtask  
  
  function report();
    $display("[%0t] [ENVIRONMENT] Test Completed. Reporting the results...", $time);
    // scb.colector_coverage.print_coverage();
  endfunction
  
  //run task
  task run;
    pre_test();
    test();
    post_test();
    report();
    //linia de mai jos este necesara pentru ca simularea sa sa termine
    $finish;
  endtask
  
endclass

