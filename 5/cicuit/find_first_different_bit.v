module find_first_different_bit #(parameter N = 8, LOGN = 3)
(input [2*N:0] number, output reg [LOGN:0] shift_len);

    integer i;
    always @(*) begin
        shift_len = 0; 

        for (i = 1; i < N+1; i = i + 1) begin
            // continue growing only if: (number[i] == number[0]) AND (all previous bits matched)
            if ((number[i] == number[0]) && (shift_len == i - 1))
                shift_len = i;
        end
    end

endmodule 