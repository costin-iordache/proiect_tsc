//-------------------------------------------------------------------------
//						www.verificationguide.com 
//-------------------------------------------------------------------------

//aici se declara tipul de data folosit pentru a stoca datele vehiculate intre generator si driver; monitorul, de asemenea, preia datele de pe interfata, le recompune folosind un obiect al acestui tip de data, si numai apoi le proceseaza
class vr_transaction;
  //se declara atributele clasei
  //campurile declarate cu cuvantul cheie rand vor primi valori aleatoare la aplicarea functiei randomize()
  rand bit [3:0] wdata;
  rand int delay;
  rand bit valid;

  //constrangerile reprezinta un tip de membru al claselor din SystemVerilog, pe langa atribute si metode
  //aceasta constrangere specifica faptul ca se executa fie o scriere, fie o citire
  //constrangerile sunt aplicate de catre compilator atunci cand atributele clasei primesc valori aleatoare in urma folosirii functiei randomize
     constraint wdata_c;
     constraint delay_c { delay inside {[0:10]}; };
  
  //aceasta functie este apelata dupa aplicarea functiei randomize() asupra obiectelor apartinand acestei clase
  //aceasta functie afiseaza valorile aleatorizate ale atributelor clasei
  function void post_randomize();
    $display("--------- [Trans] post_randomize ------");
    $display("\t wdata = %0h\t delay = %0d\t valid = %0b",wdata,delay, valid);
    $display("-----------------------------------------");
  endfunction
  
  //operator de copiere a unui obiect intr-un alt obiect (deep copy)
  function vr_transaction do_copy();
    vr_transaction trans;
    trans = new();
    trans.wdata = this.wdata;
    trans.delay = this.delay;
    trans.valid = this.valid;
    return trans;
  endfunction
endclass