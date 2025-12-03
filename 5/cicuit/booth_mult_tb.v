`timescale 1ns/1ps
module booth_mult_tb;
    parameter N = 16, LOGN = 4; 
    reg clk, reset;
    reg signed [N-1:0] M, Q;
    wire done;
    wire signed [2*N-1:0] product;

    booth_mult #(N, LOGN) multt (clk, reset, M, Q, done, product);

    initial clk = 0;
    always #5 clk = ~clk;

    integer a, b, exp, errors;
    reg [31:0] cycles;

    initial begin
        $dumpfile("booth_mult.vcd");
  		$dumpvars(0, booth_mult_tb);

        errors = 0;
        reset = 0; 
        #20;

        for (a = -8; a < 8; a = a + 1) begin
            for (b = -8; b < 8; b = b + 1) begin
                exp = a*b;
                M = a;
                Q = b;
                cycles = 0;
                #20;
                reset = 1;
                while (!done && cycles < 1000) begin
                    @(posedge clk);
                    cycles = cycles + 1;
                end

                if (!done) begin
                    $display("TIMEOUT M=%0d Q=%0d", M, Q);
                    errors = errors + 1;
                end else begin
                    @(posedge clk);
                    if (product !== exp) begin
                        $display("ERROR M=%0d Q=%0d got=%0d exp=%0d", M, Q, product, exp);
                        errors = errors + 1;
                    end
                end

                reset = 0;
            end
        end

        if (errors == 0) $display("------------------ Fortunately, all tests passed for N=%0d ------------------", N);
        else $display("Errors: %0d", errors);

        $finish;
    end

endmodule
