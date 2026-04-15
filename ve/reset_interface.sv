interface reset_intf(input logic clk);

    logic reset;

    clocking cb @(posedge clk);
        output reset;
    endclocking

    modport RESET (clocking cb, input clk);

    //reset Generation
    initial begin
        reset = 0;
        #15 reset = 1;
        $display("[%0t] Initial Reset Deasserted \n", $time);
    end
    
endinterface //reset_intf