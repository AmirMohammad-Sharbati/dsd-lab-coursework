module Memory (
    input [7:0] data_in,
    input clk,
    input we,
    input rstN,
    input [7:0]address,
    output [7:0] read_data,
    output [7:0] io_output,
    output [7:0] error_output
);
    reg [7:0] mem[255:0];
    assign io_output = mem[254];
    assign error_output = mem[255];
    assign read_data = we?8'bxxxxxxxx:mem[address];
    always @(posedge clk, negedge rstN) begin
        if(!rstN) begin
            mem[255] <=  8'd0;
            mem[254] <= 8'd0;
        end
        else if(we) begin
            mem[address] <= data_in;
        end
    end
endmodule