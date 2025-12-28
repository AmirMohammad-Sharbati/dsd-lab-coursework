module memory (
    input clk, 
    input write_enable, read_enable,
    input [4:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data  
);

    reg signed [31:0] mem [0:31]; // 32 words, each 32-bit

    always @(posedge clk) begin
        if (write_enable) 
            mem[address] <= write_data;
        else if (read_enable) 
            read_data <= mem[address]; 
    end
endmodule
