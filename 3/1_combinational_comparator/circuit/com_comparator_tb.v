`timescale 1ns/1ps
module com_comparator_tb;
	reg[3:0] a, b;
	wire a_greater_b, a_equal_b, a_less_b;
	combinational_comparator comparator (a, b, a_greater_b, a_equal_b, a_less_b);
	
	integer i, j;
	integer errors = 0;
	
	reg correct_gt, correct_eq, correct_lt; // These are correct real results which we expect to see
	
	initial begin
		$dumpfile("com_comparator.vcd");
  		$dumpvars(0, com_comparator_tb);

		for (i = 0; i < 16; i = i + 1) begin
			for (j = 0; j < 16; j = j + 1) begin
				a = i; b = j;
				#1; // small delay to let outputs settle
				
				correct_gt = (a > b);
				correct_eq = (a == b);
				correct_lt = (a < b);
				
				if ((a_greater_b !== correct_gt) || (a_equal_b !== correct_eq) || (a_less_b !== correct_lt)) begin
					$display("Error at time %0t: a=%0d b=%0d | Expected: gt=%b eq=%b lt=%b | Got: gt=%b eq=%b lt=%b",
						$time, a, b, correct_gt, correct_eq, correct_lt, a_greater_b, a_equal_b, a_less_b);
					errors = errors + 1;
				end
			end
		end
	
		if (errors == 0)
			$display("-------------------------- All test cases PASSED! --------------------------");
		else
			$display("%0d test cases FAILED.", errors);

		$stop;
	end
endmodule


