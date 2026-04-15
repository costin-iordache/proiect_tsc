//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
//monitorul urmareste traficul de pe interfetele DUT-ului, preia datele verificate si recompune tranzactiile (folosind obiecte ale clasei transaction); in implementarea de fata, datele preluate de pe interfete sunt trimise scoreboardului pentru verificare
//Samples the interface signals, captures into transaction packet and send the packet to scoreboard.

//in macro-ul MON_IF se retine blocul de semnale de unde monitorul extrage datele
`define MON_IF vr_vif.MONITOR.monitor_cb
class vr_monitor;
  
  //creating virtual interface handle
  virtual vr_intf vr_vif;
  
  //se creaza portul prin care monitorul trimite scoreboardului datele colectate de pe interfata DUT-ului sub forma de tranzactii 
  //creating mailbox handle
  mailbox mon2scb;

  coverage cov;
  
  //cand se creaza obiectul de tip monitor (in fisierul environment.sv), interfata de pe care acesta colecteaza date este conectata la interfata reala a DUT-ului
  //constructor
  function new(virtual vr_intf vr_vif,mailbox mon2scb,coverage cov);
    //getting the interface
    this.vr_vif = vr_vif;
    //getting the mailbox handles from  environment 
    this.mon2scb = mon2scb;
    this.cov = cov;
  endfunction
  
  //Samples the interface signal and send the sample packet to scoreboard
  task main;
      $display("[%0t] VALID READY MONITOR STARTED \n", $time);
    forever begin
      //se declara si se creaza obiectul de tip tranzactie care va contine datele preluate de pe interfata
      vr_transaction trans;
      trans = new();

      //datele sunt citite pe frontul de ceas, informatiile preluate de pe semnale fiind retinute in oboiectul de tip tranzactie
      @(posedge vr_vif.clk iff `MON_IF.valid && `MON_IF.ready); 
        trans.wdata  = `MON_IF.data;
      // dupa ce s-au retinut informatiile referitoare la o tranzactie, continutul obiectului trans se trimite catre scoreboard
        mon2scb.put(trans);
        cov.sample_vr(trans);
    end
  endtask
  
endclass