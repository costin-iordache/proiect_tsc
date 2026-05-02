// alternate_valid_test.sv
`include "environment.sv"

program test(vr_intf vr_intf, spi_intf spi_intf, rst_intf rst_intf);

  // Extindem vr_transaction pentru a controla campul valid
  class alt_valid_transaction extends vr_transaction;

    int cnt = 0;  // contor local pentru alternare

    function void pre_randomize();
      // Dezactivam randomizarea pentru "valid"
      valid.rand_mode(0);

      // Alternam: pachetele pare au valid=1, cele impare valid=0
      if (cnt % 2 == 0)
        valid = 1;
      else
        valid = 0;

      cnt++;
    endfunction

  endclass

  environment env;
  alt_valid_transaction my_tr;

  initial begin
    env   = new(vr_intf, spi_intf, rst_intf);
    my_tr = new();

    // Injectam tranzactia custom in generator
    env.vr_gen.trans        = my_tr;
    env.vr_gen.repeat_count = 8;   // 8 pachete: valid=1,0,1,0,1,0,1,0
    env.spi_gen.repeat_count = 8;

    env.run();
  end

endprogram