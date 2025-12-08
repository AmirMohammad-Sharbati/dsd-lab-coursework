module booth_mult #(parameter N = 4, LOGN = 2)
(
    input clk, reset,
    input [N-1:0] multiplicand, multiplier,
    output done,
    output [2*N-1:0] result,
    output [LOGN:0] clk_count,
    output [LOGN:0] add_count,
    output [LOGN:0] sub_count
);

    wire [N-1:0] operator;
    wire operation_select;
    wire [LOGN:0] shift_a, shift_b;
    wire is_added;

    control_unit #(N, LOGN) cu (clk, reset, is_added, operator, operation_select, done, shift_a, shift_b);

    datapath #(N, LOGN) dp (clk, reset, done, operation_select, multiplicand, multiplier, shift_a, shift_b, result, operator,
    clk_count, add_count, sub_count, is_added);
endmodule