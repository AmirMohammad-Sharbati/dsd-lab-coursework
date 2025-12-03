module control_unit
# (parameter N = 8, LOGN = 3)
(    
    input clk, reset,
    input [N-1:0] Q, // multiplier which which we shift it 
    output operation_select, 
    output done,
    output [LOGN:0] shift_a, shift_b
);

    wire [LOGN:0] index0, index1;
    reg [LOGN:0] total_shift;
    reg start;
    
    find_first_different_bit #(N, LOGN) finder (Q, index0, index1);

    assign done = shift_a >= N;
    assign operation_select = start & Q[0];

    assign shift_b = operation_select ? index0 : index1;
    assign shift_a = total_shift + shift_b;

    always @(posedge clk, negedge reset) begin
        if (~reset) begin
            start <= 0;
            total_shift <= 0;
        end else begin    
            start <= 1;        
            total_shift <= total_shift + shift_b;
        end
    end

endmodule