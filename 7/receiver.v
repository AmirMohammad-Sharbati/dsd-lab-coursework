module receiver(
    input wire clk,
    input wire RstN,
    input wire bit_in,
    output reg[7:0] data_with_parity,
    output reg is_parity_correct,
    output reg done
);

//state zero for IDLE, one for receiving data, two for receiving parity bit, three for receiving the finish bit
reg [2:0] state;
reg [2:0] bits_received;

always @(posedge clk, negedge RstN) begin

    if(!RstN) begin
        done <= 1'd0;
        state <= 2'd0;
        bits_received <= 3'd0;
        is_parity_correct <= 1'd0;
        data_with_parity <= 8'd0;
    end

    else if(state == 3'd0 && bit_in == 1'd1) begin
        done <= 1'd0;
        bits_received <= 3'd0;
        is_parity_correct <= 1'd0;
        data_with_parity <= 8'd0;
        state <= 2'd1;
    end 

    else if(state == 3'd1 && bits_received != 6) begin
        data_with_parity[bits_received] <= bit_in;
        bits_received <= bits_received + 1;
    end

    else if(state == 3'd1) begin
        data_with_parity[bits_received] <= bit_in;
        state <= 3'd2;
    end

    else if(state == 3'd2) begin
        data_with_parity[7] <= bit_in;
        state <= 3'd3;
    end

    else if(state == 3'd3) begin
        is_parity_correct <= !(^data_with_parity);
        state <= 3'd4;
    end

    else if(state == 3'd4) begin
        done <= 1'd1;
        state <= 3'd0;
    end
end
endmodule