////////////////////////////////////////////////////////////////////////////////
// Author: Amira Atef
// Course: Digital Verification using SV & UVM
// Date: 04-07-2025
// Description: Package containing FIFO transaction class for generating random transactions
////////////////////////////////////////////////////////////////////////////////

package FIFO_transaction_pkg;
    import shared_pkg::*;
    class FIFO_transaction;
        // FIFO transaction properties
        rand logic rst_n;
        rand logic wr_en;
        rand logic rd_en;
        randc logic [FIFO_WIDTH-1:0] data_in;
        logic [FIFO_WIDTH-1:0] data_out;
        logic wr_ack;
        logic overflow;
        logic full;
        logic empty;
        logic almostfull;
        logic almostempty;
        logic underflow;
        int WR_EN_ON_DISTANCE = 70; // Distance between write enable signals
        int RD_EN_ON_DISTANCE = 30; // Distance between read enable signals
        
        constraint c_rst_n { 
            rst_n dist {1'b1 := 90, 1'b0 := 10}; // 90% chance of being 1, 10% chance of being 0
        } // Reset is active low

        constraint c_wr_en {
            wr_en dist { 0 := (100 - WR_EN_ON_DISTANCE), 1 := WR_EN_ON_DISTANCE; }; // Write enable signal
        }       

        constraint c_rd_en {
            rd_en dist { 0 := (100 - RD_EN_ON_DISTANCE), 1 := RD_EN_ON_DISTANCE; }; // Read enable signal
        }

    endclass
endpackage