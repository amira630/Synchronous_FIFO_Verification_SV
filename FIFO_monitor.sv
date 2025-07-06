////////////////////////////////////////////////////////////////////////////////
// Author: Amira Atef
// Course: Digital Verification using SV & UVM
// Date: 04-07-2025
// Description: Monitor module for FIFO Design Verification
////////////////////////////////////////////////////////////////////////////////

import shared_pkg::*;
import FIFO_transaction_pkg::*;
import FIFO_scoreboard_pkg::*;
import FIFO_coverage_pkg::*;

module FIFO_monitor(FIFO_if.MONITOR fifo_if);
    FIFO_transaction trns;
    FIFO_scoreboard sb;
    FIFO_coverage cov;

    initial begin
        trns = new();
        sb = new();
        cov = new();

        forever begin
            @(negedge fifo_if.clk);
            trns.rst_n = fifo_if.rst_n;
            trns.wr_en = fifo_if.wr_en;
            trns.rd_en = fifo_if.rd_en;
            trns.data_in = fifo_if.data_in;

            trns.data_out = fifo_if.data_out;
            trns.wr_ack = fifo_if.wr_ack;
            trns.overflow = fifo_if.overflow;
            trns.full = fifo_if.full;
            trns.empty = fifo_if.empty;
            trns.almostfull = fifo_if.almostfull;
            trns.almostempty = fifo_if.almostempty;
            trns.underflow = fifo_if.underflow;
            fork
                begin
                    @(posedge fifo_if.clk);
                    sb.check_data(trns);
                end
                begin
                    cov.sample_data(trns);
                end
            join
            if (test_finished) begin
                $display("Test finished: Correct count = %0d, Error count = %0d", correct_count, error_count);
                $finish;
            end
        end
    end
endmodule