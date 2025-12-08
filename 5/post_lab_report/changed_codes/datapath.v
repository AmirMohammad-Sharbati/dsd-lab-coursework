module datapath #(parameter N = 8, LOGN = 3)(
    input clk, reset, done, operation_select, 
    input [N-1:0] M, Q, // M is multiplicand and Q is multiplier
    input [LOGN:0] shift_a, shift_b,
    //output reg [2*N-1:0] result,
    output reg [2*N-1:0] total, 
    output reg [N-1:0] operator,
    output reg [LOGN:0] clk_count,
    output reg [LOGN:0] add_count,
    output reg [LOGN:0] sub_count,
    output reg is_added
);

    reg [2*N-1:0] Acc;
    reg [2*N-1:0] result;
    
    

    always @(posedge clk, negedge reset) begin
        if (~reset) begin
            Acc <= {{N{M[N-1]}}, M};
            operator <= Q;
            result <= 0;
            add_count <= 0;
            sub_count <= 0;
            clk_count <= 0;
            total <= 0;
            is_added <= 0;
        end 
        else if (is_added) begin
			Acc <= {{N{M[N-1]}}, M};
            operator <= Q;
            result <= 0;
            add_count <= 0;
            sub_count <= 0;
            clk_count <= 0;
            is_added <= 0;
		end
        
        else if (~done) begin
            operator <= operator >> shift_b;
            clk_count <= clk_count + 1;
            if (operation_select) begin
                result <= result + (Acc << shift_a);
                add_count <= add_count + 1;
            end else begin
                result <= result - (Acc << shift_a);
                sub_count <= sub_count + 1;
            end
        end
        
        else if (done) begin
			total <= total + result;
            is_added <= 1;
		end
    end
    
endmodule