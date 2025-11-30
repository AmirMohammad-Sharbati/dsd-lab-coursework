module find_first_different_bit #(parameter N = 8, LOGN = 3)
(input [2*N:0] number, output reg [LOGN:0] shift_len);

    integer i;
    always @(*) begin
        shift_len = 1; 

        for (i = 2; i < N; i = i + 1) begin
            // continue growing only if: (number[i] == number[0]) AND (all previous bits matched)
            if ((number[i] == number[0]) && (shift_len == i - 1) && (number[1] == number[0]))
                shift_len = i;
        end
    end

endmodule 