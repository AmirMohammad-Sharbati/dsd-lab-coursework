module secial_counter(input clk, input reset, input ctrl, output reg [3:0] q);
	reg[3:0] holder;
	reg[27:0] clk_counter = 0;
	always @(posedge clk) begin
		clk_counter <= clk_counter + 1;
	end
	always @(negedge reset, posedge clk_counter[27]) begin
		if(!reset) begin
			q <= 0;
		end else begin
			if (ctrl) begin
				holder = q ^ (q >> 1) ^ (q >> 2) ^ (q >> 3);
				holder = holder + 1;
				q <= holder ^ (holder >> 1);
			end else begin
				q <= q + 1;
			end
		end
	end
endmodule