////////////////////////////////////////////////////////////////////////////////
// Author: Amira Atef
// Course: Digital Verification using SV & UVM
// Date: 04-07-2025
// Description: Package containing scoreboard class for FIFO Design Verification
////////////////////////////////////////////////////////////////////////////////

package FIFO_scoreboard_pkg;

    import shared_pkg::*;
    import FIFO_transaction_pkg::*;

    class FIFO_scoreboard;
        // FIFO transaction object
        FIFO_transaction F_sb_txn;
        bit [FIFO_WIDTH-1:0] data_out_ref;
        bit wr_ack_ref, overflow_ref, full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;

        localparam max_fifo_addr = $clog2(FIFO_DEPTH);
        logic [FIFO_WIDTH-1:0] mem_ref [FIFO_DEPTH-1:0];
        logic [max_fifo_addr-1:0] wr_ptr, rd_ptr;
        logic [max_fifo_addr:0] count;

        // Constructor
        function new();
            F_sb_txn = new();
        endfunction

        // Method to check FIFO status and update scoreboard
        function void check_data(FIFO_transaction F_txn);
            F_sb_txn = F_txn;
            fifo_reference_model(F_sb_txn.rst_n, F_sb_txn.wr_en, F_sb_txn.rd_en, F_sb_txn.data_in);          
            if (F_sb_txn.data_out !== data_out_ref) begin
                error_count++;
                $display("[%0t] Data mismatch: Expected %0h, Got %0h", $time, data_out_ref, F_sb_txn.data_out);
            end else begin
                correct_count++;
            end
            `ifndef SIM
                if (F_sb_txn.wr_ack !== wr_ack_ref) begin
                    error_count++;
                    $display("Write acknowledgment mismatch: Expected %0b, Got %0b", wr_ack_ref, F_sb_txn.wr_ack);
                end
                else begin
                    correct_count++;
                end

                if (F_sb_txn.overflow !== overflow_ref) begin
                    error_count++;
                    $display("Overflow mismatch: Expected %0b, Got %0b", overflow_ref, F_sb_txn.overflow);
                end
                else begin
                    correct_count++;
                end

                if (F_sb_txn.full !== full_ref) begin
                    error_count++;
                    $display("Full status mismatch: Expected %0b, Got %0b", full_ref, F_sb_txn.full);
                end
                else begin
                    correct_count++;
                end

                if (F_sb_txn.empty !== empty_ref) begin
                    error_count++;
                    $display("Empty status mismatch: Expected %0b, Got %0b", empty_ref, F_sb_txn.empty);
                end
                else begin
                    correct_count++;
                end

                if (F_sb_txn.almostfull !== almostfull_ref) begin
                    error_count++;
                    $display("Almost full status mismatch: Expected %0b, Got %0b", almostfull_ref, F_sb_txn.almostfull);
                end
                else begin
                    correct_count++;
                end

                if (F_sb_txn.almostempty !== almostempty_ref) begin
                    error_count++;
                    $display("Almost empty status mismatch: Expected %0b, Got %0b", almostempty_ref, F_sb_txn.almostempty);
                end
                else begin
                    correct_count++;
                end

                if (F_sb_txn.underflow !== underflow_ref) begin
                    error_count++;
                    $display("Underflow status mismatch: Expected %0b, Got %0b", underflow_ref, F_sb_txn.underflow);
                end
                else begin
                    correct_count++;
                end
            `endif 
        endfunction

        function void fifo_reference_model(
            input bit rst_n, 
            input bit wr_en, 
            input bit rd_en, 
            input bit [FIFO_WIDTH-1:0] data_in
        );
            // Reference model logic to generate expected values
            if (!rst_n) begin
                data_out_ref = '0;
                count = '0;
                wr_ptr = '0;
                rd_ptr = '0;
                wr_ack_ref = 1'b0;
                overflow_ref = 1'b0;
                full_ref = 1'b0;
                empty_ref = 1'b1;
                almostfull_ref = 1'b0;
                almostempty_ref = 1'b0;
                underflow_ref = rd_en ? 1'b1 : 1'b0;
            end
            else begin 
                fork
                    begin
                        if (wr_en && count < FIFO_DEPTH) begin
                            mem_ref[wr_ptr] = data_in;
                            wr_ptr++;
                            wr_ack_ref = 1'b1;
                        end
                        else begin
                            wr_ack_ref = 1'b0;
                        end
                    end
                    begin
                        if (rd_en && count > 0) begin
                            data_out_ref = mem_ref[rd_ptr];
                            rd_ptr++;
                            empty_ref = (count == 0) ? 1'b1 : 1'b0;
                        end
                    end
                join
                if ({wr_en, rd_en} == 2'b11) begin 
                    if (empty_ref)
                        count++;
                    else if	(full_ref)
                        count--;
                end
                else if	( ({wr_en, rd_en} == 2'b10) && !full_ref) 
                    count++;
                else if ( ({wr_en, rd_en} == 2'b01) && !empty_ref)
                    count--;
                full_ref = (count == FIFO_DEPTH)? 1 : 0;     
                empty_ref = (count == 0)? 1 : 0;
                almostfull_ref = (count == FIFO_DEPTH-1)? 1 : 0;         
                almostempty_ref = (count == 1)? 1 : 0;    
                underflow_ref = (empty_ref)? 1 : 0; 
            end
        endfunction
    endclass : FIFO_scoreboard
    
endpackage