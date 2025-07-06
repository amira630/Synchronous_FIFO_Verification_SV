////////////////////////////////////////////////////////////////////////////////
// Author: Amira Atef
// Course: Digital Verification using SV & UVM
// Date: 04-07-2025
// Description: Interface for FIFO Design
////////////////////////////////////////////////////////////////////////////////

interface FIFO_if #(parameter FIFO_WIDTH = 16) (input bit clk);
    
    /////////////////////////////////////////////////////////
    /////////// Interface Signal Declaration ////////////////
    /////////////////////////////////////////////////////////
    
    logic [FIFO_WIDTH-1:0] data_in;
    logic rst_n, wr_en, rd_en;
    logic [FIFO_WIDTH-1:0] data_out;
    logic wr_ack, overflow;
    logic full, empty, almostfull, almostempty, underflow;


    ////////////////////////////////////////////////////////
    ////////////////////// Modports ////////////////////////
    ////////////////////////////////////////////////////////

    modport TEST (
        input clk, data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow,
        output rst_n, wr_en, rd_en, data_in
    );
    
    modport DUT (
        input clk, rst_n, wr_en, rd_en, data_in,
        output data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow
    );

    modport MONITOR (
        input clk, rst_n, wr_en, rd_en, data_in, data_out, wr_ack, overflow, full, empty, almostfull, almostempty, underflow
    );
endinterface