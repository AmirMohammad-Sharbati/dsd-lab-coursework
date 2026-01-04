module memory (
    input clk, rstN, 
    input write_enable, read_enable,
    input [4:0] address1, address2, inst_addr,
    input [31:0] write_data,
    output reg [31:0] read_data_1, read_data_2, read_inst  
);

    reg signed [31:0] mem [0:31]; // 32 words, each 32-bit

    always @(posedge clk, negedge rstN) begin
		if (!rstN) begin
			// Operand A = 3 + 2i
			// mem[16] = {16'd3, 16'd2};

			// Operand B = 1 + 4i
			// mem[17] = {16'd1, 16'd4};
			
            // Instruction LOAD: mem[16] = input
			mem[0] = {4'b0011, 5'd16, 23'd0};
			
            // Instruction LOAD: mem[17] = input
			mem[1] = {4'b0011, 5'd17, 23'd0};

			// Instruction: ADD:  mem[16] + mem[17] -> mem[10]
			mem[2] = {4'b0000, 5'd16, 5'd17, 5'd10, 13'd0};

			// Instruction: MUL: mem[16] * mem[17] -> mem[11]
			mem[3] = {4'b0010, 5'd16, 5'd17, 5'd11, 13'd0};

			// Instruction: SUB: mem[16] - mem[17] -> mem[13]
			mem[4] = {4'b0001, 5'd16, 5'd17, 5'd13, 13'd0};
		end else if (write_enable) 
            mem[address1] <= write_data;
        else if (read_enable) begin
            read_data_1 <= mem[address1]; 
            read_data_2 <= mem[address2];
            read_inst <= mem[inst_addr];
          end
    end
endmodule
