//-------------------------------------------------------------------------
// Test: Reset in timpul transferului SPI
// Descriere: Mediul ruleaza normal. Resetul este programat sa se declanseze
//            automat in viitor, in timpul transferului activ.
//-------------------------------------------------------------------------

program test(vr_intf vr_intf, spi_intf spi_intf, reset_intf rst_intf);

  environment env;
  
  initial begin
    // creare environment
    env = new(vr_intf, spi_intf, rst_intf);
    
    // Setam un numar suficient de generari pentru a garanta trafic
    env.vr_gen.repeat_count = 15;
    env.spi_gen.repeat_count = 15;
    
   
    fork
      begin 
        // Rularea mediului. Transferul incepe imediat, iar evenimentele de reset 
        // programate mai sus se declanseaza automat pe fundal la momentele stabilite.
        env.run();
      end
      begin 
        // PROGRAMAREA RESETULUI ÎN VIITOR:
        #500ns env.rst_drv.drive();
      end
    join
    disable fork;
  end
  
endprogram