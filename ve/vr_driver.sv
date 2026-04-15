//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
//driverul preia datele de la generator, la nivel abstract, si le trimite DUT-ului conform protocolului de comunicatie pe interfata respectiva
//gets the packet from generator and drive the transaction paket items into interface (interface is connected to DUT, so the items driven into interface signal will get driven in to DUT) 


//se declara macro-ul VR_DRIV_IF care va reprezenta interfata pe care driverul va trimite date DUT-ului
`define VR_DRIV_IF vr_vif.DRIVER.driver_cb
class vr_driver;
  
  //used to count the number of transactions
  int no_transactions = 0;
  int valid_trans = 0;
  
  //creating virtual interface handle
  virtual vr_intf vr_vif;
  
  //se creaza portul prin care driverul primeste datele la nivel abstract de la DUT
  //creating mailbox handle
  mailbox gen2driv;
  
  //constructor
  function new(virtual vr_intf vr_vif,mailbox gen2driv);
    //cand se creaza driverul, interfata pe care acesta trimite datele este conectata la interfata reala a DUT-ului
    //getting the interface
    this.vr_vif = vr_vif;
    //getting the mailbox handles from  environment 
    this.gen2driv = gen2driv;
  endfunction
  
  //Reset task, Reset the Interface signals to default/initial values
  task reset;
    wait(!vr_vif.reset);
    $display("--------- [VR DRIVER] Reset Started ---------");
    `VR_DRIV_IF.data <= 0;
    `VR_DRIV_IF.valid <= 0;
    wait(vr_vif.reset);
    $display("--------- [VR DRIVER] Reset Ended ---------");
  endtask
  
  //drives the transaction items to interface signals
  task drive;
    vr_transaction trans;
      
    //se asteapta ca modulul sa iasa din reset
     wait(vr_vif.reset);//linie valabila daca resetul este activ in 0
    //wait(!vr_vif.reset);//linie valabila daca resetul este activ in 1
    
    //daca nu are date de la generator, driverul ramane cu executia la linia de mai jos, pana cand primeste respectivele date
      gen2driv.get(trans);
      wait(`VR_DRIV_IF.ready == 1'b1); //wait until DUT is ready to accept the data
      repeat(trans.delay) @(posedge vr_vif.DRIVER.clk);
      `VR_DRIV_IF.valid <= trans.valid;
      `VR_DRIV_IF.data <= trans.wdata;
      @(posedge vr_vif.DRIVER.clk);
      `VR_DRIV_IF.valid <= 0;
      no_transactions++;
      if(trans.valid) valid_trans++;
      $display("--------- [VR DRIVER-TRANSFER: %0d] --------- \n \tVALID = %0b \n \tWDATA = %0h",no_transactions, trans.valid, trans.wdata);
  endtask
  
    
  //Cele doua fire de executie de mai jos ruleaza in paralel. Dupa ce primul dintre ele se termina al doilea este intrerupt automat. Daca se activeaza reset-ul, nu se mai transmit date. 
  task main;
    $display("[%0t] VALID READY DRIVER STARTED \n", $time);
    forever begin
      fork
        //Thread-1: Waiting for reset
        begin
          wait(!vr_vif.reset);//linie valabila daca resetul este activ in 0
          //wait(vr_vif.reset);//linie valabila daca resetul este activ in 1
        end
        //Thread-2: Calling drive task
        begin
          //transmiterea datelor se face permanent, dar este conditionta de primirea datelor de la monitor.
          forever
            drive();
        end
      join_any
      disable fork;
    end
  endtask
        
endclass