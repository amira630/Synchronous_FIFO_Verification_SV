////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////


module FIFO #(parameter FIFO_WIDTH = 16, FIFO_DEPTH = 8) (FIFO_if fifo_if);

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
		if (full & wr_en)
			overflow <= 1;
		else 
			overflow <= 0;
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
		if (({wr_en, rd_en} == 2'b11)) begin  //The possibility of rd & wr enable with either empty or full was not considered.
			if (empty)
				count <= count + 1;
			else if	(full)
				count <= count - 1;
		end
		else if	( ({wr_en, rd_en} == 2'b10) && !full) 
			count <= count + 1;
		else if ( ({wr_en, rd_en} == 2'b01) && !empty)
			count <= count - 1;
	end
end

assign full = (count == FIFO_DEPTH)? 1 : 0;
assign empty = (count == 0)? 1 : 0;
assign underflow = (empty && rd_en)? 1 : 0; 
assign almostfull = (count == FIFO_DEPTH-2)? 1 : 0; 
assign almostempty = (count == 1)? 1 : 0;

endmodule