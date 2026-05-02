//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------

//testele contin unul sau mai multe scenarii de verificarel testele instantiaza mediul de verificare (a se vedea linia 28); testele sunt pornite din testbench

// `include "environment.sv"

class valid_trans extends vr_transaction;
  constraint valid_c { valid == 1'b1; }
endclass

program test(vr_intf vr_intf, spi_intf spi_intf, reset_intf rst_intf);
  
  //declaring environment instance
  environment env;
  valid_trans good_trans; 

  
  initial begin
    //creating environment
    env = new(vr_intf, spi_intf, rst_intf);
    
    //setting the repeat count of generator as 4, means to generate 4 packets
    env.vr_gen.repeat_count = 4;
    env.spi_gen.repeat_count = 4;

    env.vr_gen.trans = good_trans;
    
    //calling run of env, it interns calls generator and driver main tasks.
    env.run();
  end
endprogram