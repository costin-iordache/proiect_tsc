//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
//driverul preia datele de la generator, la nivel abstract, si le trimite DUT-ului conform protocolului de comunicatie pe interfata respectiva
//gets the packet from generator and drive the transaction paket items into interface (interface is connected to DUT, so the items driven into interface signal will get driven in to DUT) 

//se declara macro-ul DRIV_IF care va reprezenta interfata pe care driverul va trimite date DUT-ului
class reset_driver;
  
  //creating virtual interface handle
  virtual vr_intf vr_vif;
  
  event reset_done;
  
  //constructor
  function new(virtual vr_intf vr_vif);
    //cand se creaza driverul, interfata pe care acesta trimite datele este conectata la interfata reala a DUT-ului
    //getting the interface
    this.vr_vif = vr_vif;
  endfunction
  
  //drives the transaction items to interface signals
  task drive;
    vr_vif.reset <= 0;
    repeat(3) @(posedge vr_vif.clk);
    vr_vif.reset <= 1;
    -> reset_done;
  endtask
        
endclass