////////////////////////////////////////////////////////////////////////////////
// Author: Amira Atef
// Course: Digital Verification using SV & UVM
// Date: 04-07-2025
// Description: Top-level module for FIFO Design Verification
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps
module top();
    bit clk;

    FIFO_if #(.FIFO_WIDTH(16)) fifo_if (clk);

    FIFO #(.FIFO_WIDTH(16), .FIFO_DEPTH(8)) DUT (fifo_if);

    FIFO_tb tb (fifo_if);

    FIFO_monitor mon (fifo_if);

    // FIFO SVA (fifo_if);
    // bind FIFO DUT SVA (fifo_if);

    ////////////////////////////////////////////////////////
    ////////////////// Clock Generator  ////////////////////
    ////////////////////////////////////////////////////////

    initial begin
        clk = 1;

        // Start the clock
        forever
            #5 clk = ~clk; // Clock period of 10 time units
    end

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, top);
    end
endmodule