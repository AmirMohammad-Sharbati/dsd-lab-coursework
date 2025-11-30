module control_unit
# (parameter N = 8, LOGN = 3)
(    
    input clk, start,
    input [2*N:0] Q, // multiplier which which we shift it 
    output operation_select, done,
    output [LOGN:0] shamt_this_clk
);

    reg [LOGN:0] total_shift;
    find_first_different_bit finder (Q, shamt_this_clk);

    assign operation_select = Q[0];
    assign done = (total_shift >= N);

    always @(posedge clk, negedge start) begin
        if (~start) 
            total_shift <= 0;
        else total_shift <= total_shift + shamt_this_clk;
    end
    
endmodule