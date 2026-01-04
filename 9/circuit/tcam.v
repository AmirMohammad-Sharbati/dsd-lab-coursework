module tcam #(
    parameter WIDTH = 16, DEPTH = 16,
    parameter ADDR_WIDTH = 4 // log2(DEPTH)
)(
    input wire clk, reset, write_enable,
    input wire [ADDR_WIDTH-1:0] write_addr,
    input wire [WIDTH-1:0] write_value, write_mask, search_data,
    output reg [DEPTH-1:0] match
);

    reg [WIDTH-1:0] value_mem [0:DEPTH-1];
    reg [WIDTH-1:0] mask_mem  [0:DEPTH-1];

    integer i;

    // Write logic (FPGA registers)
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                value_mem[i] <= {WIDTH{1'b0}};
                mask_mem [i] <= {WIDTH{1'b0}};
            end
        end else if (write_enable) begin
            value_mem[write_addr] <= write_value;
            mask_mem [write_addr] <= write_mask;
        end
    end

    // TCAM compare logic
    always @(*) begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            match[i] = & (mask_mem[i] | ~(search_data ^ value_mem[i]));
        end
    end

endmodule
