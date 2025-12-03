module booth_mult #(parameter N = 8, LOGN = 3)
(
    input clk, reset,
    input [N-1:0] multiplicand, multiplier,
    output done,
    output [2*N-1:0] result
);

    wire [N-1:0] operator;
    wire operation_select;
    wire [LOGN:0] shift_a, shift_b;

    control_unit #(N, LOGN) cu (clk, reset, operator, operation_select, done, shift_a, shift_b);

    // (    
    //     input clk, reset,
    //     input [N-1:0] Q, // multiplier which which we shift it 
    //     output operation_select, 
    //     output done,
    //     output [LOGN:0] shift_a, shift_b
    // );


    // module datapath #(parameter N = 8, LOGN = 3)(
    //     input clk, reset, done, operation_select, 
    //     input [N-1:0] M, Q, // M is multiplicand and Q is multiplier
    //     input [LOGN:0] shift_a, shift_b,
    //     output reg signed [2*N-1:0] result, 
    //     output reg [N-1:0] operator
    // );

    datapath #(N, LOGN) dp (clk, reset, done, operation_select, multiplicand, multiplier, shift_a, shift_b, result, operator);


endmodule