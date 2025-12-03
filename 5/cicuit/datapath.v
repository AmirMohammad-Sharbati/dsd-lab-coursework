module datapath #(parameter N = 8, LOGN = 3)(
    input clk, reset, done, operation_select, 
    input [N-1:0] M, Q, // M is multiplicand and Q is multiplier
    input [LOGN:0] shift_a, shift_b,
    output reg [2*N-1:0] result, 
    output reg [N-1:0] operator
);

    reg [2*N-1:0] Acc;

    always @(posedge clk, negedge reset) begin
        if (~reset) begin
            Acc <= {{N{M[3]}}, M};
            operator <= {{N{Q[3]}}, Q};
            result <= 0;
        end else if (~done) begin
            operator <= operator >> shift_b;
            if (operation_select) begin
                result <= result + (Acc << shift_a);
            end else begin
                result <= result - (Acc << shift_a);
            end
        end
    end
    
endmodule