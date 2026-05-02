//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------
//scoreboardul preia datele de la monitor si verifica acuratetea acestora; pentru a se face aceasta verificare, in scoreboard este implementata functionalitatea DUT-ului; intrarile pe care le primeste DUT-ul sunt preluate de catre monitor si transmise scoreboardului; comparandu-se iesirile monitorului si ale scoreboardului se poate determina daca acestea functioneaza corect

//the scoreboard gets the packet from monitor, generates the expected result and compares with the //actual result recived from Monitor

class scoreboard;
   
  //se declara portul prin care scoreboardul primeste date de la monitor; daca sunt mai multe monitoare, se pot declara mai multe porturi de acest tip
  //creating mailbox handle
  mailbox spi_mon2scb;
  mailbox  vr_mon2scb;
  
  //used to count the number of transactions and errors
  int errors;
  int no_trans;
  
  spi_transaction spi_q [$];
  vr_transaction vr_q [$];
   
  //se declara si se creaza colectorul de coverage
  coverage colector_coverage;

  //constructor
  function new(mailbox spi_mon2scb, mailbox vr_mon2scb);
    //getting the mailbox handles from  environment 
    this.spi_mon2scb = spi_mon2scb;
    this.vr_mon2scb = vr_mon2scb;
    colector_coverage = new();
  endfunction
  
  //stores wdata and compare rdata with stored data
  task main;
    spi_transaction spi_trans;
    vr_transaction vr_trans;
    $display("[%0t] SCOREBOARD STARTED \n", $time);
    fork
      begin 
        forever begin 
          //getting the spi transaction from monitor
          spi_mon2scb.get(spi_trans);
          $display("[%0t] [SCOREBOARD] Received SPI Transaction %0d: %0h", $time, spi_q.size(), spi_trans.miso_data);
          spi_q.push_back(spi_trans);
        end
      end
      begin 
        forever begin 
          //getting the vr transaction from monitor
          vr_mon2scb.get(vr_trans);
          $display("[%0t] [SCOREBOARD] Received VR Transaction %0d: %0h", $time, vr_q.size(), vr_trans.wdata);
          vr_q.push_back(vr_trans);
        end
      end
    join
    disable fork;
  endtask

function void compare_transactions();
  spi_transaction spi_trans;
  vr_transaction vr_trans;

  no_trans = (spi_q.size() < vr_q.size()) ? spi_q.size() : vr_q.size();
  for(int i = 0; i < no_trans; i++) begin
    spi_trans = spi_q.pop_front();
    vr_trans = vr_q.pop_front();
    if(spi_trans.miso_data != vr_trans.wdata) begin
      $error("[SCOREBOARD] Mismatch in transaction %0d: Expected MOSI data = %0b, Received MOSI data = %0b", i, vr_trans.wdata, spi_trans.miso_data);
      errors++;
    end
  end

  if(spi_q.size() != 0 && vr_q.size() != 0) begin
    $error("[SCOREBOARD] Error: Remaining transactions in queues. SPI Queue Size: %0d, VR Queue Size: %0d", spi_q.size(), vr_q.size());
    errors++;
  end

endfunction

function void print_results();
  $display("[SCOREBOARD] Total Transactions: %0d", no_trans);
  if(errors == 0) begin
    $display("[SCOREBOARD] All transactions matched successfully!");
  end else begin
    $error("[SCOREBOARD] Mismatches in %0d transactions.", errors);
  end
endfunction
  
endclass