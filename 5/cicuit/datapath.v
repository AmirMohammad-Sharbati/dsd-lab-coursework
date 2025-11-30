module datapath #(parameter N = 8, LOGN = 3)(
    input clk, reset, done, operation_select, 
    input [N-1:0] M, Q, // M is multiplicand and Q is multiplier
    input [LOGN:0] shamt_this_clk,
    output reg signed [2*N-1:0] result, 
    output reg signed [2*N:0] operator
);

    // Internal datapath regs
    reg signed [N-1:0] A; // accumulator
    reg signed [2*N:0] update;

    always @(posedge clk, negedge reset) begin
        if (~reset) begin
            A <= 0;
            result <= 0;
            operator <= {A, Q, 1'b0};
            update <= (M << (N+1));
        end else if (~done) begin
            operator = operator >>> shamt_this_clk;
            if (operation_select) begin
                operator <= operator + update;
            end else begin
                operator <= operator - update;
            end
        end else begin
            result <= operator[2*N:1];
        end
    end

    
endmodule