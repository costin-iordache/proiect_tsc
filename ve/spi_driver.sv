<<<<<<< HEAD
//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
//driverul preia datele de la generator, la nivel abstract, si le trimite DUT-ului conform protocolului de comunicatie pe interfata respectiva
//gets the packet from generator and drive the transaction paket items into interface (interface is connected to DUT, so the items driven into interface signal will get driven in to DUT) 


//se declara macro-ul DRIV_IF care va reprezenta interfata pe care driverul va trimite date DUT-ului
`define DRIV_IF spi_vif.DRIVER.driver_cb
class driver;
  
  //used to count the number of transactions
  int no_transactions;
  
  //creating virtual interface handle
  virtual spi_intf spi_vif;
  
  //se creaza portul prin care driverul primeste datele la nivel abstract de la DUT
  //creating mailbox handle
  mailbox gen2driv;
  
  //constructor
  function new(virtual spi_intf spi_vif,mailbox gen2driv);
    //cand se creaza driverul, interfata pe care acesta trimite datele este conectata la interfata reala a DUT-ului
    //getting the interface
    this.spi_vif = spi_vif;
    //getting the mailbox handles from  environment 
    this.gen2driv = gen2driv;
  endfunction
  
  //Reset task, Reset the Interface signals to default/initial values
  task reset;
    wait(spi_vif.reset);
    $display("--------- [DRIVER] Reset Started ---------");
    `DRIV_IF.miso <= 0;      
    wait(!spi_vif.reset);
    $display("--------- [DRIVER] Reset Ended ---------");
  endtask
  
  //drives the transaction items to interface signals
  task drive;
      transaction trans;
      int bit_index = 0;
      
    //se asteapta ca modulul sa iasa din reset
     wait(spi_vif.reset);
    
    //daca nu are date de la generator, driverul ramane cu executia la linia de mai jos, pana cand primeste respectivele date
      gen2driv.get(trans);
      $display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);
      wait(!`DRIV_IF.ss);
      fork
        begin 
          while(bit_index < DATA_WIDTH) begin 
            `DRIV_IF.miso <= trans.data[bit_index];
            @(negedge `DRIV_IF.sclk);
            bit_index++;
          end
        end
        begin 
          wait(`DRIV_IF.ss);
        end
      join_any
      disable fork;
      $display("-----------------------------------------");
      no_transactions++;
  endtask
  
    
  //Cele doua fire de executie de mai jos ruleaza in paralel. Dupa ce primul dintre ele se termina al doilea este intrerupt automat. Daca se activeaza reset-ul, nu se mai transmit date. 
  task main;
    forever begin
      fork
        //Thread-1: Waiting for reset
        begin
          wait(!spi_vif.reset);
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
        
=======
//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
//driverul preia datele de la generator, la nivel abstract, si le trimite DUT-ului conform protocolului de comunicatie pe interfata respectiva
//gets the packet from generator and drive the transaction paket items into interface (interface is connected to DUT, so the items driven into interface signal will get driven in to DUT) 


//se declara macro-ul DRIV_IF care va reprezenta interfata pe care driverul va trimite date DUT-ului
`define DRIV_IF spi_vif.DRIVER.driver_cb
class driver;
  
  //used to count the number of transactions
  int no_transactions;
  
  //creating virtual interface handle
  virtual spi_intf spi_vif;
  
  //se creaza portul prin care driverul primeste datele la nivel abstract de la DUT
  //creating mailbox handle
  mailbox gen2driv;
  
  //constructor
  function new(virtual spi_intf spi_vif,mailbox gen2driv);
    //cand se creaza driverul, interfata pe care acesta trimite datele este conectata la interfata reala a DUT-ului
    //getting the interface
    this.spi_vif = spi_vif;
    //getting the mailbox handles from  environment 
    this.gen2driv = gen2driv;
  endfunction
  
  //Reset task, Reset the Interface signals to default/initial values
  task reset;
    wait(spi_vif.reset);
    $display("--------- [DRIVER] Reset Started ---------");
    `DRIV_IF.miso <= 0;      
    wait(!spi_vif.reset);
    $display("--------- [DRIVER] Reset Ended ---------");
  endtask
  
  //drives the transaction items to interface signals
  task drive;
      transaction trans;
      int bit_index = 0;
      
    //se asteapta ca modulul sa iasa din reset
     wait(spi_vif.reset);
    
    //daca nu are date de la generator, driverul ramane cu executia la linia de mai jos, pana cand primeste respectivele date
      gen2driv.get(trans);
      $display("--------- [DRIVER-TRANSFER: %0d] ---------",no_transactions);
      wait(!`DRIV_IF.ss);
      fork
        begin 
          while(bit_index < DATA_WIDTH) begin 
            `DRIV_IF.miso <= trans.data[bit_index];
            @(negedge `DRIV_IF.sclk);
            bit_index++;
          end
        end
        begin 
          wait(`DRIV_IF.ss);
        end
      join_any
      disable fork;
      $display("-----------------------------------------");
      no_transactions++;
  endtask
  
    
  //Cele doua fire de executie de mai jos ruleaza in paralel. Dupa ce primul dintre ele se termina al doilea este intrerupt automat. Daca se activeaza reset-ul, nu se mai transmit date. 
  task main;
    forever begin
      fork
        //Thread-1: Waiting for reset
        begin
          wait(!spi_vif.reset);
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
        
>>>>>>> 94100b4d261f0c6f6c3cbd050f816e14171adfdb
endclass