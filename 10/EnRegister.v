module EnRegister #(
    parameter N = 8
)(
    input  wire           clk,
    input  wire           rstN,
    input  wire           enable,
    input  wire [N-1:0]   d,
    output reg  [N-1:0]   q
);

    always @(posedge clk) begin
        if (!rstN)
            q <= {N{1'b0}};
        else if (enable)
            q <= d;
    end

endmodule
