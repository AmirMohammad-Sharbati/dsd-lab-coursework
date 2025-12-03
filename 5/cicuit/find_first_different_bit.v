module find_first_different_bit #(parameter N = 8, LOGN = 3)
(input [N-1:0] num, output  [LOGN:0] index0, index1);
    
    reg [LOGN:0] index;
    integer i;
    always @(*) begin
        if (num == {N{1'b1}} || num == {N{1'b0}}) begin
            index = N;
        end else begin
            for (i = N-1; i > 0; i = i - 1) begin
                // Iterate from left to right. We can also do this from right to left iteration.
                if (num[i] != num[0])
                    index = i;
            end
        end
    end

    assign index0 = num[0] ? index : 0;
    assign index1 = num[0] ? 0 : index;

endmodule 