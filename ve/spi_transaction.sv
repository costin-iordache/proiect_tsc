//-------------------------------------------------------------------------
//						www.verificationguide.com 
//-------------------------------------------------------------------------

//aici se declara tipul de data folosit pentru a stoca datele vehiculate intre generator si driver; monitorul, de asemenea, preia datele de pe interfata, le recompune folosind un obiect al acestui tip de data, si numai apoi le proceseaza
class spi_transaction;
  //se declara atributele clasei
  //campurile declarate cu cuvantul cheie rand vor primi valori aleatoare la aplicarea functiei randomize()
  rand bit [3:0] miso_data;

  //constrangerile reprezinta un tip de membru al claselor din SystemVerilog, pe langa atribute si metode
  //aceasta constrangere specifica faptul ca se executa fie o scriere, fie o citire
  //constrangerile sunt aplicate de catre compilator atunci cand atributele clasei primesc valori aleatoare in urma folosirii functiei randomize
     constraint miso_data_c;
  
  //aceasta functie este apelata dupa aplicarea functiei randomize() asupra obiectelor apartinand acestei clase
  //aceasta functie afiseaza valorile aleatorizate ale atributelor clasei
  function void post_randomize();
    $display("--------- [Trans] post_randomize ------");
    $display("\t miso_data = %0h", miso_data);
    $display("-----------------------------------------");
  endfunction
  
  //operator de copiere a unui obiect intr-un alt obiect (deep copy)
  function spi_transaction do_copy();
    spi_transaction trans;
    trans = new();
    trans.miso_data = this.miso_data;
    return trans;
  endfunction
endclass