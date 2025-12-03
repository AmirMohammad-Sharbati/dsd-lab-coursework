module datapath #(parameter N = 8, LOGN = 3)(
    input clk, reset, done, 
    input [1:0] operation_select, 
    input [N-1:0] M, Q, // M is multiplicand and Q is multiplier
    input [LOGN:0] shamt_this_clk,
    output reg signed [2*N-1:0] result, 
    output reg signed [2*N:0] operator
);

    // Internal datapath regs
    reg signed [2*N:0] update_plus;
    reg signed [2*N:0] update_min;

    always @(posedge clk, negedge reset) begin
        if (~reset) begin
            result <= 0;
            operator <= {{N{1'b0}}, Q, 1'b0};
            update_plus <= {M, {(N+1){1'b0}}};
            update_min <= {(-M), {(N+1){1'b0}}};
        end else if (~done) begin
            operator = operator >>> shamt_this_clk;

            if (operation_select == 2'b01) begin
                operator = operator + update_plus;
            end else if (operation_select == 2'b10) begin
                operator = operator + update_min;
            end
            operator = operator >>> 1;
        end else begin
            result <= operator[2*N:1];
        end
    end

    
endmodule