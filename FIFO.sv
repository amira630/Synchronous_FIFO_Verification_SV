////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////


module FIFO #(parameter FIFO_WIDTH = 16, FIFO_DEPTH = 8) (FIFO_if.DUT fifo_if);

logic clk, rst_n, wr_en, rd_en, wr_ack, overflow, full, empty, almostfull, almostempty, underflow;
logic [FIFO_WIDTH-1:0] data_in;
logic [FIFO_WIDTH-1:0] data_out;

// Interface signals
assign clk = fifo_if.clk;
assign rst_n = fifo_if.rst_n;
assign wr_en = fifo_if.wr_en;
assign rd_en = fifo_if.rd_en;
assign data_in = fifo_if.data_in;

assign fifo_if.data_out = data_out;
assign fifo_if.wr_ack = wr_ack;
assign fifo_if.overflow = overflow;
assign fifo_if.full = full;
assign fifo_if.empty = empty;
assign fifo_if.almostfull = almostfull;
assign fifo_if.almostempty = almostempty;
assign fifo_if.underflow = underflow;

localparam max_fifo_addr = $clog2(FIFO_DEPTH);

reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		wr_ptr <= 0;
		wr_ack <= 0;   //wr_ack and overflow were not reset
		overflow <= 0;
	end
	else if (wr_en && count < FIFO_DEPTH) begin 
		mem[wr_ptr] <= data_in;
		wr_ack <= 1;
		wr_ptr <= wr_ptr + 1;
		overflow <= 0;  //overflow should be zero if wr_en and !full
	end
	else begin 
		wr_ack <= 0; 
		if (full && wr_en) begin // should be && not & for conditional coverage
			overflow <= 1;
		end
		else begin
			overflow <= 0;
		end
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		rd_ptr <= 0;
		data_out <= 0;  //data_out was not reset
	end
	else if (rd_en && count != 0) begin 
		data_out <= mem[rd_ptr];
		rd_ptr <= rd_ptr + 1;
	end
end

always @(posedge clk or negedge rst_n) begin
	if (!rst_n) begin
		count <= 0;
	end
	else begin
		if ({wr_en, rd_en} == 2'b11) begin  //The possibility of rd & wr enable with either empty or full was not considered.
			if (empty)
				count <= count + 1;
			else if	(full)
				count <= count - 1;
		end
		else if	( ({wr_en, rd_en} == 2'b10) && !full) 
			count <= count + 1;
		else if (rd_en && !empty) // for conditional coverage 
			count <= count - 1;
	end
end

assign full = (count == FIFO_DEPTH)? 1 : 0;
assign empty = (count == 0)? 1 : 0; 
assign underflow = (empty && rd_en)? 1 : 0; 
assign almostfull = (count == FIFO_DEPTH-1)? 1 : 0; // it was FIFO_DEPTH-2, almostfull means 1 element can be added
assign almostempty = (count == 1)? 1 : 0;

`ifdef SIM
	// Assertions and coverage for FIFO behavior
	property overflow_prop;
		@(posedge clk) disable iff (~rst_n) (wr_en && full) |=> overflow ;
	endproperty

	property underflow_prop;
		@(posedge clk) disable iff (~rst_n) (rd_en && empty) |-> underflow ;
	endproperty

	property wr_ack_prop;
		@(posedge clk) disable iff (~rst_n) (wr_en && count < FIFO_DEPTH) |=> wr_ack ;
	endproperty

	property full_prop;
		@(posedge clk) disable iff (~rst_n) (count == FIFO_DEPTH) |-> full;
	endproperty

	property empty_prop;
		@(posedge clk) disable iff (~rst_n) (count == 0) |-> empty;
	endproperty

	property almostfull_prop;
		@(posedge clk) disable iff (~rst_n) (count == FIFO_DEPTH-1) |-> almostfull;
	endproperty

	property almostempty_prop;
		@(posedge clk) disable iff (~rst_n) (count == 1) |-> almostempty;
	endproperty

	property count_wr_prop;
		@(posedge clk) disable iff (~rst_n) ((wr_en && !full && !rd_en) || (wr_en && rd_en && empty)) |=> (count == $past(count) + 1);
	endproperty

	property count_rd_prop;
		@(posedge clk) disable iff (~rst_n) ((rd_en && !empty && !wr_en) || (wr_en && rd_en && full)) |=> (count == $past(count) - 1);
	endproperty	
	
	assert property (overflow_prop) else $error("Overflow occurred when FIFO is full");
	assert property (underflow_prop) else $error("Underflow occurred when FIFO is empty");
	assert property (wr_ack_prop) else $error("Write acknowledge not asserted when FIFO is not full");
	assert property (full_prop) else $error("FIFO not full when count is equal to FIFO_DEPTH");
	assert property (empty_prop) else $error("FIFO not empty when count is zero");
	assert property (almostfull_prop) else $error("FIFO not almost full when count is equal to FIFO_DEPTH-1");
	assert property (almostempty_prop) else $error("FIFO not almost empty when count is equal to 1");
	assert property (count_wr_prop) else $error("Count not updated correctly during write operation");
	assert property (count_rd_prop) else $error("Count not updated correctly during read operation");

	cover property (overflow_prop);
	cover property (underflow_prop);
	cover property (wr_ack_prop);
	cover property (full_prop);
	cover property (empty_prop);
	cover property (almostfull_prop);
	cover property (almostempty_prop);
	cover property (count_wr_prop);
	cover property (count_rd_prop);
`endif
endmodule