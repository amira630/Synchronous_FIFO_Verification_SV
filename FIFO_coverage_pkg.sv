////////////////////////////////////////////////////////////////////////////////
// Author: Amira Atef
// Course: Digital Verification using SV & UVM
// Date: 04-07-2025
// Description: Package containing coverage class for FIFO Design Verification
////////////////////////////////////////////////////////////////////////////////

package FIFO_coverage_pkg;

    import FIFO_transaction_pkg::*;

    class FIFO_coverage;
        FIFO_transaction F_cvg_txn;

        covergroup FIFO_cvr_grp;
            // Coverpoints for FIFO transaction signals
            rst_n_c:        coverpoint F_cvg_txn.rst_n;
            wr_en_c:        coverpoint F_cvg_txn.wr_en;
            rd_en_c:        coverpoint F_cvg_txn.rd_en;
            // data_in_c:      coverpoint F_cvg_txn.data_in {option.cross_auto_bin_max = 0;};
            // data_out_c:     coverpoint F_cvg_txn.data_out{option.cross_auto_bin_max = 0;};
            wr_ack_c:       coverpoint F_cvg_txn.wr_ack;
            overflow_c:     coverpoint F_cvg_txn.overflow;
            full_c:         coverpoint F_cvg_txn.full;
            empty_c:        coverpoint F_cvg_txn.empty;
            almostfull_c:   coverpoint F_cvg_txn.almostfull;
            almostempty_c:  coverpoint F_cvg_txn.almostempty;
            underflow_c:    coverpoint F_cvg_txn.underflow;

            // Cross coverage for write and read enable signals

            wr_ack_cross: cross wr_en_c, rd_en_c, wr_ack_c {
                ignore_bins read_wr_ack = binsof(wr_en_c) intersect {0} && binsof(rd_en_c) intersect {1} && binsof(wr_ack_c) intersect {1};
                ignore_bins write_read_wr_ack = binsof(wr_en_c) intersect {0} && binsof(wr_ack_c) intersect {1};
            }

            overflow_cross: cross wr_en_c, rd_en_c, overflow_c {
                ignore_bins write_overflow = binsof(wr_en_c) intersect {0} && binsof(overflow_c) intersect {1};
            }

            full_cross: cross wr_en_c, rd_en_c, full_c {
                ignore_bins write_full = binsof(wr_en_c) intersect {0} && binsof(full_c) intersect {1};
                ignore_bins read_full = binsof(rd_en_c) intersect {1} && binsof(full_c) intersect {1};
            }
            
            empty_cross: cross wr_en_c, rd_en_c, empty_c {
                ignore_bins read_empty = binsof(rd_en_c) intersect {0} && binsof(empty_c) intersect {1};
            }

            almostfull_cross: cross wr_en_c, rd_en_c, almostfull_c {
                ignore_bins read_write_almostfull = binsof(wr_en_c) intersect {0} && binsof(rd_en_c) intersect {1} && binsof(almostfull_c) intersect {1};
                ignore_bins write_almostfull = binsof(wr_en_c) intersect {0} && binsof(almostfull_c) intersect {1};
            }   

            almostempty_cross: cross wr_en_c, rd_en_c, almostempty_c {
                ignore_bins read_almostempty = binsof(rd_en_c) intersect {0} && binsof(almostempty_c) intersect {1};
                ignore_bins write_read_almostempty = binsof(rd_en_c) intersect {0} && binsof(wr_en_c) intersect {1} && binsof(almostempty_c) intersect {1};
            }

            underflow_cross: cross wr_en_c, rd_en_c, underflow_c {
                ignore_bins read_underflow = binsof(rd_en_c) intersect {0} && binsof(underflow_c) intersect {1};
                ignore_bins write_underflow = binsof(wr_en_c) intersect {1} && binsof(underflow_c) intersect {1};
            }
        endgroup : FIFO_cvr_grp

        // Constructor
        function new();
            F_cvg_txn = new();
            FIFO_cvr_grp = new();
        endfunction

        // Sample data for coverage
        function void sample_data(FIFO_transaction F_txn);
            // Implement coverage sampling logic here
            F_cvg_txn = F_txn;
            FIFO_cvr_grp.sample();
        endfunction

    endclass
    
endpackage