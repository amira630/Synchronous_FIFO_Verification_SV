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
        bit wr_ack_ref;
        bit overflow_ref;
        bit full_ref;
        bit empty_ref;
        bit almostfull_ref;
        bit almostempty_ref;
        bit underflow_ref;

        localparam max_fifo_addr = $clog2(FIFO_DEPTH);
        logic [FIFO_WIDTH-1:0] mem_ref [FIFO_DEPTH-1:0];
        logic [max_fifo_addr-1:0] wr_ptr_ref, rd_ptr_ref;
        logic [max_fifo_addr:0] count_ref;

        // Constructor
        function new();
            F_sb_txn = new();
        endfunction

        // Method to check FIFO status and update scoreboard
        function void check_data();
            fifo_reference_model(F_sb_txn.rst_n, F_sb_txn.wr_en, F_sb_txn.rd_en, F_sb_txn.data_in,
                            data_out_ref, wr_ack_ref, overflow_ref, full_ref, empty_ref,
                            almostfull_ref, almostempty_ref, underflow_ref);
            if (F_sb_txn.data_out !== data_out_ref) begin
                error_count++;
                $display("Data mismatch: Expected %0h, Got %0h", data_out_ref, F_sb_txn.data_out);
            end else begin
                correct_count++;
            end

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
        endfunction

        function void fifo_reference_model(
            bit rst_n, 
            bit wr_en, 
            bit rd_en, 
            bit [FIFO_WIDTH-1:0] data_in,
            output bit [FIFO_WIDTH-1:0] data_out_ref,
            output bit wr_ack_ref,
            output bit overflow_ref,
            output bit full_ref,
            output bit empty_ref,
            output bit almostfull_ref,
            output bit almostempty_ref,
            output bit underflow_ref
        );
            // Reference model logic to generate expected values
            if (!rst_n) begin
                data_out_ref = 16'b0;
                wr_ack_ref = 1'b0;
                overflow_ref = 1'b0;
                full_ref = 1'b0;
                empty_ref = 1'b1;
                almostfull_ref = 1'b0;
                almostempty_ref = 1'b0;
                underflow_ref = 1'b0;
                wr_ptr_ref = 0;
                rd_ptr_ref = 0;
            end
            else begin 
                if (wr_en) begin
                    if (count_ref < FIFO_DEPTH) begin
                        mem_ref[wr_ptr_ref] = data_in;
                        wr_ack_ref = 1'b1;
                        wr_ptr_ref = wr_ptr_ref + 1;
                        overflow_ref = 1'b0; // No overflow if not full
                        count_ref++;
                    end
                    else begin
                        if(count_ref > FIFO_DEPTH) begin
                            overflow_ref = 1'b1; // Overflow if trying to write when full
                            full_ref = 1'b1;
                            almostfull_ref = 1'b0;
                        end
                        else begin
                            overflow_ref = 1'b0; // No overflow if not full
                            if (count_ref == FIFO_DEPTH) begin
                                full_ref = 1'b1;
                                almostfull_ref = 1'b0; // Not almost full if full
                            end
                            else if (count_ref == FIFO_DEPTH - 1) begin
                                full_ref = 1'b0;
                                almostfull_ref = 1'b1; // Almost full if one less than full
                            end
                            else begin
                                full_ref = 1'b0;
                                almostfull_ref = 1'b0;
                            end
                        end
                        wr_ack_ref = 1'b0;
                    end
                end
                else begin
                    wr_ack_ref = 1'b0;
                end
                if (rd_en) begin
                    if (count_ref > 0) begin
                        data_out_ref = mem_ref[rd_ptr_ref];
                        rd_ptr_ref = rd_ptr_ref + 1;
                        count_ref--;
                        if(count_ref == 0) begin
                            empty_ref = 1'b1; // Empty if no data left
                        end
                        else begin
                            empty_ref = 1'b0; // Not empty if there is data
                        end
                    end
                    else begin
                        // data_out_ref = 16'b0;
                        if (count_ref == 1) begin
                            almostempty_ref = 1'b1;
                            underflow_ref = 1'b0; // Underflow if trying to read when empty
                        end
                        else if (count_ref == 0) begin
                            almostempty_ref = 1'b0;
                            underflow_ref = 1'b1; // No underflow if empty
                        end
                        else begin
                            almostempty_ref = 1'b0;
                            underflow_ref = 1'b0; // Underflow if trying to read when empty
                        end
                    end
                end
            end
        endfunction
    endclass : FIFO_scoreboard
    
endpackage