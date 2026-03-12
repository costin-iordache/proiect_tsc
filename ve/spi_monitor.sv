//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
//monitorul urmareste traficul de pe interfetele DUT-ului, preia datele verificate si recompune tranzactiile (folosind obiecte ale clasei transaction); in implementarea de fata, datele preluate de pe interfete sunt trimise scoreboardului pentru verificare
//Samples the interface signals, captures into transaction packet and send the packet to scoreboard.

//in macro-ul SPI_IF se retine blocul de semnale de unde monitorul extrage datele
`define SPI_IF SPI_vif.MONITOR.monitor_cb
class monitor;
  
  //creating virtual interface handle
  virtual spi_intf spi_vif;
  
  //se creaza portul prin care monitorul trimite scoreboardului datele colectate de pe interfata DUT-ului sub forma de tranzactii 
  //creating mailbox handle
  mailbox mon2scb;
  
  //cand se creaza obiectul de tip monitor (in fisierul environment.sv), interfata de pe care acesta colecteaza date este conectata la interfata reala a DUT-ului
  //constructor
  function new(virtual spi_intf spi_vif,mailbox mon2scb);
    //getting the interface
    this.spi_vif = spi_vif;
    //getting the mailbox handles from  environment 
    this.mon2scb = mon2scb;
  endfunction
  
  //Samples the interface signal and send the sample packet to scoreboard
  task collect();
    forever begin
      int bit_index = 0;
      //se declara si se creaza obiectul de tip tranzactie care va contine datele preluate de pe interfata
      transaction trans;
      trans = new();

      //datele sunt citite pe frontul de ceas, informatiile preluate de pe semnale fiind retinute in oboiectul de tip tranzactie
      wait(!`SPI_IF.ss);
      fork
        begin 
          while(!`SPI_IF.ss) begin 
            @(negedge spi_vif.MONITOR.sclk);
            trans.data[bit_index] = `SPI_IF.mosi;
            bit_index++;
          end
        end
        begin 
          wait(`SPI_IF.ss);
        end
      join_any
      disable fork;
      // dupa ce s-au retinut informatiile referitoare la o tranzactie, continutul obiectului trans se trimite catre scoreboard
      mon2scb.put(trans);
    end
  endtask

  task main(); 
    forever begin 
      fork
        begin 
          wait(!spi_vif.reset);
        end
        begin 
          collect();
        end
      join_any
      disable fork;
      wait(spi_vif.reset);
    end
  endtask
  
endclass