interface reset_intf(input logic clk, output logic reset);

    clocking cb @(posedge clk);
        output reset;
    endclocking

    modport RESET (clocking cb, input clk);
    
endinterface //reset_intf