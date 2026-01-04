module tcam #(
    parameter int WIDTH = 16, // number of bits per entry
    parameter int DEPTH = 16  // number of TCAM entries
)(
    input wire [WIDTH-1:0] search_data,
    input wire [WIDTH-1:0] value [DEPTH-1:0],
    input wire [WIDTH-1:0] mask  [DEPTH-1:0],
    output reg [DEPTH-1:0] match
);

    integer i;

    always @(*) begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            match[i] = & (mask[i] | ~(search_data ^ value[i]));
        end
    end

endmodule
