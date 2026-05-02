//-------------------------------------------------------------------------
// Test: Date fara Valid 
// Descriere: Plaseaza date pe magistrala wdata fara a afirma semnalul valid
//            folosind suprascrierea tranzactiei (OOP Override).
//-------------------------------------------------------------------------

class err_no_valid_trans extends vr_transaction;
  constraint c_no_valid { valid == 1'b0; }
endclass

program test(vr_intf vr_intf, spi_intf spi_intf, reset_intf rst_intf);
  
  environment env;
  
  // Declarăm un handle pentru tranzacția alterată
  err_no_valid_trans bad_trans; 
  
  initial begin
    env = new(vr_intf, spi_intf, rst_intf);
    bad_trans = new();

    env.vr_gen.repeat_count = 10;
    env.spi_gen.repeat_count = 0; 
    
    env.vr_gen.trans = bad_trans;
    
    env.run();
  end
endprogram