`timescale 1ns/1ps
module nbit_comparator_tb;
    reg clk, reset, current_bit_a, current_bit_b;
	wire a_greater_b, a_equal_b, a_less_b;

	nbit_comparator comparator (
		clk, reset, current_bit_a, current_bit_b,
		a_greater_b, a_equal_b, a_less_b
	);

	// Helper function to create progressive strings
    function [7:0] get_partial(input [7:0] v, input integer idx);
        reg [7:0] partial;
        integer j;
        begin
            partial = 0;
            for (j = idx; j >= 0; j = j - 1) begin
                partial[j] = v[j];
            end
            get_partial = partial;
        end
    endfunction


    task compare_serial;
        input [7:0] A, B;
        begin
            reset = 0;
            #10 reset = 1;
            // Bit-by-bit comparison, MSB first
            for (i = 0; i < 8; i = i + 1) begin
                current_bit_a = A[i];
                current_bit_b = B[i];
                #10 clk = ~clk;  // simulate level change
                
                // When the clock is high, the input bits change, but we don't see the effect on the outputs.
                current_bit_a = 1'b0;
                current_bit_b = 1'b1;
                #10;
                $display("time=%0t  i=%0d || A=%b  B=%b || a_greater_b=%b  a_equal_b=%b  a_less_b=%b",
                        $time, (i), get_partial(A, i), get_partial(B, i), a_greater_b, a_equal_b, a_less_b);
                clk = ~clk;  // return clock
            end

            #20;
            if (a_greater_b)
                $display("Final Result: A > B");
            else if (a_less_b)
                $display("Final Result: A < B");
            else
                $display("Final Result: A == B");

            $display("-----------------------------");
        end
    endtask
	

    integer i, j;
    initial begin
        $dumpfile("nbit_comp.vcd");
  		$dumpvars(0, nbit_comparator_tb);

        clk = 0;
        compare_serial(8'b10101010, 8'b11001101);
        #10 compare_serial(8'b01001001, 8'b01001001);

        #20 $stop;
    end


endmodule