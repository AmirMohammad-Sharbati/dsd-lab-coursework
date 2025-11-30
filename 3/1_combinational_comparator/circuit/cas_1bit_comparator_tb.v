`timescale 1ns/1ps
module cas_1bit_comparator_tb;
	reg a, b;
	reg prev_a_greater_b, prev_a_equal_b, prev_a_less_b;
	wire a_greater_b, a_equal_b, a_less_b;

	cascadable_1bit_comparator comparator (
		a, b, prev_a_greater_b, prev_a_equal_b, prev_a_less_b,
		a_greater_b, a_equal_b, a_less_b
	);

	// Task for display (optional, for cleaner code)
   task show_result;
		begin
			$display("t=%0t | a=%b b=%b | prev_gt=%b prev_eq=%b prev_lt=%b || gt=%b eq=%b lt=%b",
			$time, a, b, prev_a_greater_b, prev_a_equal_b, prev_a_less_b,
			a_greater_b, a_equal_b, a_less_b);
		end
	endtask
	
	
	integer i, j;
   	initial begin
		$dumpfile("cas_1bit_com.vcd");
  		$dumpvars(0, cas_1bit_comparator_tb);

		// Case 1: previous stage says equal (typical MSB case)
		prev_a_greater_b = 0;
		prev_a_equal_b = 1;
		prev_a_less_b = 0;

		for (i = 0; i < 2; i = i + 1) begin
			for (j = 0; j < 2; j = j + 1) begin
				a = i;
				b = j;
				#10 show_result();
			end
		end

		// Case 2: previous stage already decided A > B
		prev_a_greater_b = 1;
		prev_a_equal_b = 0;
		for (i = 0; i < 2; i = i + 1) begin
			for (j = 0; j < 2; j = j + 1) begin
				a = i;
				b = j;
				#10 show_result();
			end
		end

		// Case 3: previous stage already decided A < B
		prev_a_greater_b = 0;
		prev_a_less_b = 1;
		for (i = 0; i < 2; i = i + 1) begin
			for (j = 0; j < 2; j = j + 1) begin
				a = i;
				b = j;
				#10 show_result();
			end
		end

		$display("TEST FINIHSED");
		$stop;
	end


endmodule