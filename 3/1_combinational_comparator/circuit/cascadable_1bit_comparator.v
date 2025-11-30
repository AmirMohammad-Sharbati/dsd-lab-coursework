module cascadable_1bit_comparator (
	input a, b, prev_a_greater_b, prev_a_equal_b, prev_a_less_b,
	output a_greater_b, a_equal_b, a_less_b
);
	assign a_greater_b = prev_a_greater_b | (prev_a_equal_b & (a & ~b));
	assign a_less_b = prev_a_less_b | (prev_a_equal_b & (~a & b));
	assign a_equal_b = prev_a_equal_b & (~(a ^ b));

endmodule