module Incubator (
    input wire RstN,
    input wire Clk,
    input wire signed [7:0] temp,
    output reg is_heater_on,
    output reg [3:0] cooler_RPS
);

reg [2:0] state;

always @(posedge Clk, negedge RstN) begin
    if(!RstN) begin
        state <= 0;
        is_heater_on <= 0;
        cooler_RPS <= 0;
    end

    else if(state == 3'd0 && temp < 8'sd15) begin
        state <= 3'd4;
        is_heater_on <= 1;
    end

    else if(state == 3'd0 && temp > 8'sd35) begin
        cooler_RPS <= 4'd4;
        state <= 3'd1;
    end

    else if(state == 3'd1 && temp < 8'sd25) begin
        cooler_RPS <= 4'd0;
        state <= 3'd0;
    end

    else if(state == 3'd1 && temp > 8'sd 40) begin
        cooler_RPS <= 4'd6;
        state <= 3'd2;
    end

    else if(state == 3'd2 && temp > 8'sd45) begin
        cooler_RPS <= 4'd8;
        state <= 3'd3;
    end
    
    else if(state == 3'd2 && temp < 8'sd35 && temp >= 8'sd25) begin
        cooler_RPS <= 4'd4;
        state <= 3'd1;
    end

    else if(state == 3'd2 && temp < 8'sd 25) begin
        cooler_RPS <= 4'd0;
        state <= 3'd0;
    end

    else if(state == 3'd3 && temp >= 8'sd25 && temp < 8'sd40) begin
        cooler_RPS <= 4'd6;
        state <= 3'd2;
    end

    else if(state == 3'd3 && temp < 8'sd25) begin
        cooler_RPS <= 4'd0;
        state <= 3'd0;
    end

    else if(state == 3'd4 && temp > 8'sd30) begin
        is_heater_on <= 1'd0;
        state <= 3'd0;
    end

end
    
endmodule