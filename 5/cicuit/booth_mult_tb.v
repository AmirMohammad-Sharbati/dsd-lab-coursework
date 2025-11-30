`timescale 1ns/1ps
module booth_mult_tb;

    parameter N = 8; 

    reg clk;
    reg rst;
    reg signed [N-1:0] M;
    reg signed [N-1:0] Q;
    wire done;
    wire signed [2*N-1:0] product;

    booth_mult #(.N(N)) uut (clk, rst, M, Q, done, product);

    initial clk = 0;
    always #5 clk = ~clk;

    integer a,b;
    integer errors;
    reg [31:0] cycles;

    initial begin
        $dumpfile("booth_mult.vcd");
  		$dumpvars(0, booth_mult_tb);

        errors = 0;
        rst = 0; 
        #20;
        rst = 1;
        #10;

        for (a = -100; a < 150; a = a + 100) begin
            for (b = -100; b < 150; b = b + 100) begin
                M = a;
                Q = b;
                cycles = 0;
                while (!done && cycles < 1000) begin
                    @(posedge clk);
                    cycles = cycles + 1;
                end

                if (!done) begin
                    $display("TIMEOUT M=%0d Q=%0d", $signed(M), $signed(Q));
                    errors = errors + 1;
                end else begin
                    @(posedge clk);
                    if (product !== (M * Q)) begin
                        $display("ERROR M=%0d Q=%0d got=%0d exp=%0d", M, Q, product, M*Q);
                        errors = errors + 1;
                    end
                    
                end
                rst = 0;
                @(posedge clk);
                rst = 1;
            end
        end

        if (errors == 0) $display("All exhaustive tests passed for N=%0d", N);
        else $display("Errors: %0d", errors);

        $finish;
    end

endmodule
