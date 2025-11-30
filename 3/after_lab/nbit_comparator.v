module nbit_comparator (
    input clk, reset, a, b,
    output a_greater_b, a_equal_b, a_less_b    
);    
    // It was assumed that reset was active low, which is generally the case.
    assign prev_a_equal_b = reset ? (clk ? prev_a_equal_b : a_equal_b) : 1'b1;
    assign prev_a_greater_b = reset ? (clk ? prev_a_greater_b : a_greater_b) : 1'b0;
    assign prev_a_less_b = reset ? (clk ? prev_a_less_b : a_less_b): 1'b0 ;

    assign equal_one_bit = reset ? (clk ? equal_one_bit : (~(a ^ b))) : 1'b1;
    assign a_greater_one_bit = reset ? (clk ? a_greater_one_bit : (a & ~b)) : 1'b0;
    assign a_less_one_bit = reset ? (clk ? a_less_one_bit : (~a & b)) : 1'b0;

	assign a_equal_b = reset ? (clk ? (prev_a_equal_b & equal_one_bit) : a_equal_b) : 1'b1;
    assign a_greater_b = reset ? (clk ? (a_greater_one_bit | (prev_a_greater_b & equal_one_bit)) : a_greater_b) : 1'b0;
	assign a_less_b = reset ? (clk ? (a_less_one_bit | (prev_a_less_b & equal_one_bit)) : a_less_b) : 1'b0;

endmodule