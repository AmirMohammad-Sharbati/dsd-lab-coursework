module complex_adder (
    input clk, resetNot, start,
    input [31:0] A, B,
    input op, // 0 = add, 1 = sub
    output reg [31:0] result,
    output reg done
);

    reg [1:0] state;   // 0 = real, 1 = imag

    reg signed [15:0] add_a, add_b;

    wire signed [15:0] a_real = A[31:16];
    wire signed [15:0] a_imag = A[15:0];
    wire signed [15:0] b_real = B[31:16];
    wire signed [15:0] b_imag = B[15:0];


    wire signed [15:0] add_out = op ? (add_a - add_b) : add_a + add_b;

    always @(posedge clk, negedge resetNot) begin
        if (!resetNot) begin
            state <= 1'b0;
            done  <= 1'b0;
        end else begin
            case (state)
                1'b0: begin  // REAL PART
                    done <= 1'b0;
                    if (start) begin  
                        add_a <= a_real;
                        add_b <= b_real;
                        state <= 1'b1;
                    end
                end

                1'b1: begin  // IMAG PART
                    result[31:16] <= add_out; // This is real result (previous state)
                    add_a <= a_imag;
                    add_b <= b_imag;
                    state <= 2'd2;
                end

                2'd2: begin
                    result[15:0] <= add_out;
                    done <= 1'b1;
                    state <= 1'b0;
                end

            endcase
        end
    end


endmodule

