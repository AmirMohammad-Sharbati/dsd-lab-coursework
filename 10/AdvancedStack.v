module AdvancedStack (
    input wire clk,
    input wire rstN,
    input wire [7:0] data_in,
    input wire push,
    input wire pop,
    input wire is_addition,
    output reg [7:0] data_out,
    output reg error
);

    reg [7:0] stack_instance[7:0];
    reg [3:0] pointer;
    //Full = 1 indicates that stack is Full
    //Empty = 0 indicates that stack is empty
    reg full, empty;

    always @(posedge clk, negedge rstN) begin
        if(!rstN) begin
            empty <= 1'b0;
            full <= 1'b0;
            pointer <= 4'b0;
            data_out <= 4'b0;
            error <= 1'd0;
        end
        else if(push && !pop && full) error <= 1'd1;
        else if(push && !pop && !full) begin
            stack_instance[pointer] <= data_in;
            pointer <= pointer + 1;
            if(pointer == 4'd7) full <= 1'd1;
            empty <= 1'd1;
        end
        else if(!push && pop && !empty) error <= 1;
        else if(!push && pop && empty) begin
            pointer <= pointer - 1;
            data_out <= stack_instance[pointer - 1];
            if(pointer == 3'd1) empty <= 1'd0;
            full <= 1'd0;
        end
        else if(push && pop && pointer <= 1) error <= 1;
        else if(push && pop && is_addition) begin
            stack_instance[pointer - 2] <= stack_instance[pointer - 1] + stack_instance[pointer - 2];
            pointer <= pointer - 1;
            full <= 1'd0;
            data_out <= stack_instance[pointer - 1] + stack_instance[pointer - 2];
        end
        else if(push && pop && !is_addition) begin
            stack_instance[pointer - 2] <= stack_instance[pointer - 2] - stack_instance[pointer - 1];
            pointer <= pointer - 1;
            full <= 1'd0;
            data_out <= stack_instance[pointer - 2] - stack_instance[pointer - 1];
        end
    end
endmodule
