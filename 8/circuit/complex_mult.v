module complex_mult (
    input clk, resetNot, start,
    input [31:0] A, B,
    output reg [63:0] result,
    output reg done
);

    wire signed [15:0] a_real = A[31:16];
    wire signed [15:0] a_imag = A[15:0];
    wire signed [15:0] b_real = B[31:16];
    wire signed [15:0] b_imag = B[15:0];

    // FSM states
    reg [2:0] state;
    localparam IDLE = 3'd0, AC = 3'd1, BD = 3'd2, AD = 3'd3, BC = 3'd4, 
                WRITE = 3'd5, DONE = 3'd6;

    // Internal registers
    reg signed [31:0] ac, bd, ad, bc;
    reg signed [15:0] mul_a, mul_b;
    wire signed [31:0] mul_out = mul_a * mul_b;


    always @(posedge clk or negedge resetNot) begin
        if (!resetNot) begin
            state <= IDLE;
            done  <= 1'b0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;    
                    if (start) begin 
                        state <= AC;
                    end
                end

                AC: begin
                    ac <= a_real * b_real;
                    state <= BD;
                end

                BD: begin
                    bd <= a_imag * b_imag;
                    state <= AD;
                end

                AD: begin
                    ad <= a_real * b_imag;
                    state <= BC;
                end

                BC: begin
                    result[63:32] <= ac - bd;
                    bc <= a_imag * b_real;
                    state <= WRITE;
                end

                WRITE: begin
                    state <= DONE;
                end

                DONE: begin
                    result[31:0] <= ad + bc;
                    done <= 1'b1;
                    state  <= IDLE;
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule
