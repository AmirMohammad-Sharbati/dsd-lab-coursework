module booth_mult #(parameter N = 8, LOGN = 3)
(
    input clk, reset,
    input signed [N-1:0] multiplicand, multiplier,
    output done,
    output signed [2*N-1:0] result
);

    wire [2*N:0] operator;
    wire operation_select;
    wire [LOGN:0] shamt_this_clk;

    control_unit #(N, LOGN) cu (clk, reset, operator, operation_select, done, shamt_this_clk);
	 
    datapath #(N, LOGN) dp (clk, reset, done, operation_select, multiplicand, multiplier, shamt_this_clk, result, operator);


endmodule