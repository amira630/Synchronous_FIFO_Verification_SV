////////////////////////////////////////////////////////////////////////////////
// Author: Amira Atef
// Course: Digital Verification using SV & UVM
// Date: 04-07-2025
// Description: Top-level module for FIFO Design Verification
////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

import shared_pkg::*;
module top();

    ////////////////////////////////////////////////////////
    ////////////////// Clock Generator  ////////////////////
    ////////////////////////////////////////////////////////

    bit clk;

    initial begin

        // Start the clock
        forever
            #5 clk = ~clk; // Clock period of 10 time units
    end

    FIFO_if #(.FIFO_WIDTH(FIFO_WIDTH)) fifo_if (clk);

    FIFO #(.FIFO_WIDTH(FIFO_WIDTH), .FIFO_DEPTH(FIFO_DEPTH)) DUT (fifo_if);

    FIFO_tb tb (fifo_if);

    FIFO_monitor mon (fifo_if);

    // FIFO SVA (fifo_if);
    // bind FIFO DUT SVA (fifo_if);

    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, top);
    end
endmodule