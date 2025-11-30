module combinational_comparator (
	input [3:0] a, b,
	output a_greater_b, a_equal_b, a_less_b
);

	wire a3_greater_b3, a3_equal_b3, a3_less_b3;
	cascadable_1bit_comparator com3 (
		a[3], b[3], 1'b0, 1'b1, 1'b0, 
		a3_greater_b3, a3_equal_b3, a3_less_b3
	); // For MSB we should set 0, 1, 0 as previous result

	wire a2_greater_b2, a2_equal_b2, a2_less_b2;
	cascadable_1bit_comparator com2 (
		a[2], b[2], a3_greater_b3, a3_equal_b3, a3_less_b3, 
		a2_greater_b2, a2_equal_b2, a2_less_b2
	); 
	
	wire a1_greater_b1, a1_equal_b1, a1_less_b1;
	cascadable_1bit_comparator com1 (
		a[1], b[1], a2_greater_b2, a2_equal_b2, a2_less_b2, 
		a1_greater_b1, a1_equal_b1, a1_less_b1
	); 
	
	cascadable_1bit_comparator com0 (
		a[0], b[0], a1_greater_b1, a1_equal_b1, a1_less_b1, 
		a_greater_b, a_equal_b, a_less_b
	); 


endmodule