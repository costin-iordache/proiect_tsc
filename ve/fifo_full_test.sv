//-------------------------------------------------------------------------
// Test: FIFO plin, dupa 1 transfer ready=1
// Descriere: Se trimit FIFO_DEPTH+1 tranzactii cu valid=1 si delay=0.
//            Primele FIFO_DEPTH umplu FIFO-ul -> ready scade la 0.
//            Dupa ce primul transfer SPI se finalizeaza, se elibereaza
//            un slot -> ready revine la 1, iar ultima tranzactie este
//            acceptata de DUT.
//-------------------------------------------------------------------------

`include "environment.sv"

program test(vr_intf vr_intf, spi_intf spi_intf, rst_intf rst_intf);

  environment env;

  // Tranzactie cu valid=1 garantat si fara delay,
  // pentru a umple FIFO-ul fara intreruperi
  class trans_valid extends vr_transaction;
    constraint valid_c { valid == 1'b1; }
    constraint delay_c { delay == 0;    }
  endclass

  trans_valid tv;

  initial begin
    env = new(vr_intf, spi_intf, rst_intf);

    tv = new();
    env.vr_gen.trans = tv;

    // FIFO_DEPTH(4) + 1: primele 4 tranzactii umplu FIFO-ul (ready=0),
    // a 5-a este trimisa doar dupa ce ready revine la 1 (dupa 1 transfer SPI)
    env.vr_gen.repeat_count  = 5;
    env.spi_gen.repeat_count = 5;

    env.run();
  end

endprogram