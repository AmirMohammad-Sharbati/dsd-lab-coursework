module control_unit
# (parameter N = 8, LOGN = 3)
(    
    input clk, reset,
    input [2*N:0] Q, // multiplier which which we shift it 
    output [1:0] operation_select, 
    output done,
    output reg [LOGN:0] shamt_this_clk
);

    reg [LOGN:0] total_shift;
    integer i;
    assign operation_select = {Q[1], Q[0]};
    assign done = (total_shift > N);

    always @(posedge clk, negedge reset) begin
        if (~reset) 
            total_shift = 0;

        else begin
            shamt_this_clk = 0; 
            // for (i = 1; i < N+1; i = i + 1) begin
            //     // continue growing only if: (number[i] == number[0]) AND (all previous bits matched)
            //     if ((Q[i] == Q[0]) && (shamt_this_clk == i - 1) && (total_shift <= (N-shamt_this_clk)))
            //         shamt_this_clk = i;
            // end
            total_shift = total_shift + shamt_this_clk + 1;
        end
    end

endmodule