module stack (
    input wire Clk,
    input wire RstN,
    input wire [3:0] Data_In,
    input wire Push,
    input wire Pop,
    output reg [3:0] Data_out,
    output reg Full, //Full = 1 indicates that stack is Full
    output reg Empty //Empty = 0 indicates that stack is empty
);
    reg [3:0] stack_instance[7:0];
    reg [3:0] pointer;

    always @(posedge Clk, negedge RstN) begin
        if(!RstN) begin
            Empty <= 1'b0;
            Full <= 1'b0;
            pointer <= 4'b0;
            Data_out <= 4'b0;
        end else if(Push && !Full) begin
                stack_instance[pointer] <= Data_In;
                pointer <= pointer + 1;
                Full <= (pointer == 4'd7);
                Empty <= 1'b1;
        end else if(Pop && Empty) begin
                pointer <= pointer - 1;
                Data_out <= stack_instance[pointer-1];
                Empty <= !(pointer == 4'd1);
                Full <= 1'b0;
            end
        end        
endmodule

