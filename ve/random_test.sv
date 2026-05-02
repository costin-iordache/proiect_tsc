//-------------------------------------------------------------------------
//						www.verificationguide.com
//-------------------------------------------------------------------------

//tranzactiile din acest text se genereaza complet aleatoriu (singura constrangere fiind in fisierul transaction.sv, aceasta asigurand functionalitatea corecta a DUT-ului)
`include "environment.sv"
program test(vr_intf vr_intf, spi_intf spi_intf, reset_intf rst_intf);
  
  //declaring environment instance
  environment env;
  
  initial begin
    //creating environment
    env = new(vr_intf, spi_intf, rst_intf);
    
    //setting the repeat count of generator as 4, means to generate 4 packets
    env.vr_gen.repeat_count = 20;
    env.spi_gen.repeat_count = 20;

    //calling run of env, it interns calls generator and driver main tasks.
    env.run();
  end
endprogram