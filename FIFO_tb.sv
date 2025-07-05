////////////////////////////////////////////////////////////////////////////////
// Author: Amira Atef
// Course: Digital Verification using SV & UVM
// Date: 04-07-2025
// Description: Testbench for FIFO Design Verification
////////////////////////////////////////////////////////////////////////////////

import shared_pkg::*;
import FIFO_transaction_pkg::*;
module FIFO_tb(FIFO_if.TEST fifo_if);
    // Declare the local variables
    int i;
    int data;

    ////////////////////////////////////////////////////////
    /////////// Applying Stimulus on Inputs //////////////// 
    ////////////////////////////////////////////////////////

    FIFO_transaction trns;

    initial begin
        
        // Initialize the FIFO interface
        initialize();

        trns = new();

        // Generate test data
        for (i = 0; i < 200; i++) begin
            assert(trns.randomize);
            fifo_if.rst_n = trns.rst_n;
            fifo_if.wr_en = trns.wr_en;
            fifo_if.rd_en = trns.rd_en;
            fifo_if.data_in = trns.data_in;
            @(negedge fifo_if.clk);
        end
        // Finish the test after writing all data
        test_finished = 1;
    end


    ////////////////////////////////////////////////////////
    /////////////////////// TASKS //////////////////////////
    ////////////////////////////////////////////////////////

    /////////////// Signals Initialization //////////////////

    task initialize;
        begin
            fifo_if.wr_en 	= 1'b1;
            fifo_if.rd_en 	= 1'b0;
            fifo_if.data_in = 16'hFF_FF; // Example data		
            correct_count = 0;
            error_count = 0;
            test_finished = 0;
            reset();
        end
    endtask

    ///////////////////////// RESET /////////////////////////

    task reset;
        begin
            fifo_if.rst_n = 1'b1;
            @(negedge fifo_if.clk);
            fifo_if.rst_n = 1'b0;
            @(negedge fifo_if.clk);
            fifo_if.rst_n = 1'b1;
            fifo_if.wr_en = 1'b0; // Disable write enable after reset
        end
    endtask
endmodule