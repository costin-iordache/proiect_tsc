//prin coverage, putem vedea ce situatii (de exemplu, ce tipuri de tranzactii) au fost generate in simulare; astfel putem masura stadiul la care am ajuns cu verificarea
class coverage;
  
  vr_transaction vr_trans_covered;
  spi_transaction spi_trans_covered;

  //pentru a se putea vedea valoarea de coverage pentru fiecare element trebuie create mai multe grupuri de coverage, sau trebuie creata o functie de afisare proprie
  covergroup vr_transaction_cg;
    //linia de mai jos este adaugata deoarece, daca sunt mai multe instante pentru care se calculeaza coverage-ul, noi vrem sa stim pentru fiecare dintre ele, separat, ce valoare avem.
    option.per_instance = 1;
    valid_enable_cp: coverpoint vr_trans_covered.valid;
    delay_cp: coverpoint vr_trans_covered.delay;
    
    write_data_cp: coverpoint vr_trans_covered.wdata {
      bins big_values = {[191:255]};
      bins medium_values = {[127:190]};
      bins low_values = {[0:126]};
    }
  endgroup

  covergroup spi_transaction_cg;
  //linia de mai jos este adaugata deoarece, daca sunt mai multe instante pentru care se calculeaza coverage-ul, noi vrem sa stim pentru fiecare dintre ele, separat, ce valoare avem.
  option.per_instance = 1;
  
  miso_data_cp: coverpoint spi_trans_covered.miso_data {
    bins big_values = {[191:255]};
    bins medium_values = {[127:190]};
    bins low_values = {[0:126]};
  }
  endgroup

  //se creaza grupul de coverage; ATENTIE! Fara functia de mai jos, grupul de coverage nu va putea esantiona niciodata date deoarece pana acum el a fost doar declarat, nu si creat
  function new();
    vr_transaction_cg = new();
    spi_transaction_cg = new();
    vr_trans_covered = new();
    spi_trans_covered = new();
  endfunction
  
  task sample_vr(vr_transaction trans_covered); 
    this.vr_trans_covered = trans_covered; 
  	vr_transaction_cg.sample(); 
  endtask: sample_vr
  
  task sample_spi(spi_transaction trans_covered); 
    this.spi_trans_covered = trans_covered; 
  	spi_transaction_cg.sample(); 
  endtask: sample_spi

  function print_coverage();
    $display ("Valid enable coverage = %.2f%%", vr_transaction_cg.valid_enable_cp.get_coverage());
    $display ("Delay coverage = %.2f%%", vr_transaction_cg.delay_cp.get_coverage());
    $display ("Write data coverage = %.2f%%", vr_transaction_cg.write_data_cp.get_coverage());
    $display ("MISO data coverage = %.2f%%", spi_transaction_cg.miso_data_cp.get_coverage());
  endfunction
  
  //o alta modalitate de a incheia declaratia unei clase este sa se scrie "endclass: numele_clasei"; acest lucru este util mai ales cand se declara mai multe clase in acelasi fisier; totusi, se recomanda ca fiecare fisier sa nu contina mai mult de o declaratie a unei clase
endclass: coverage

