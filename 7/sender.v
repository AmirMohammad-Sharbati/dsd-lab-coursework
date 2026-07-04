module sender(
    input wire RstN,
    input wire clk,
    input wire start,
    input wire [6:0] data_to_send,
    output reg placing_bit,
    output reg done
);
//state zero for IDLE, One for received start signal, two for placing input data, three for placing parity bit, four for sending finish signal, five for returning the bus to zero
    reg [2:0] state;
    reg [6:0] given_data_at_start;
    reg [3:0] bits_sent;
    wire parity_bit = ^given_data_at_start;

    always@(negedge RstN, posedge clk) begin

        if(!RstN) begin
            state <= 0;
            bits_sent <= 4'd0;
            placing_bit <= 4'd0;
            done <= 1'd0;
        end

        else if(state == 3'd0 && start) begin
            given_data_at_start <= data_to_send;
            state <= 3'd 1;
            bits_sent <= 4'd0;
            done <= 1'd0;
        end

        else if(state == 3'd1) begin
            placing_bit <= 1'd1;
            state <= 3'd2;
        end

        else if(state == 3'd2 && bits_sent != 4'd6) begin
            placing_bit <= given_data_at_start[bits_sent];
            bits_sent <= bits_sent + 1;
        end

        else if(state == 3'd2) begin
            placing_bit <= given_data_at_start[bits_sent];
            state <= 3'd3;
        end

        else if(state == 3'd3) begin
            placing_bit <= parity_bit;
            state <= 3'd4;
        end

        else if(state == 3'd4) begin
            placing_bit <= 1;
            state <= 3'd5;
        end

        else if(state == 3'd5) begin
            placing_bit <= 1'd0;
            done <= 1'd1;
            state <= 3'd0;
        end
    end
   
endmodule