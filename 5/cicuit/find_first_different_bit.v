module find_first_different_bit #(parameter N = 8, LOGN = 3)
(input [N-1:0] num, output [LOGN:0] index0, index1);

    assign index0 = num[0] ? (num[1] ? (num[2] ? (num[3] ? 4: 3) : 2) : 1) : 0;
    assign index1 = ~num[0] ? (~num[1] ? (~num[2] ? (~num[3] ? 4: 3) : 2) : 1) : 0;

endmodule 