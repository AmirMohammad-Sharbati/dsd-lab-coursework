module Incubator (
    input wire RstN,
    input wire Clk,
    input wire signed [7:0] input_temp,
    input wire control,
    output reg is_heater_on,
    output reg [3:0] cooler_RPS,
    output wire [6:0] hex0,
    output wire [6:0] hex1,
    output reg invalid_temp
);

reg [7:0] stack_instance[3:0];
reg [2:0] pointer;
reg [2:0] state;
reg [7:0] temp;
wire [3:0] first_bits = temp[3:0];
wire [3:0] second_bits = temp[7:4];

assign hex0[0] = (first_bits == 4'd1|| first_bits == 4'd4 || first_bits == 4'd11 || first_bits == 4'd13);
assign hex0[1] = (first_bits == 4'd5 || first_bits == 4'd6 || first_bits == 4'd11 || first_bits == 4'd14 || first_bits == 4'd15);
assign hex0[2] = (first_bits == 4'd2 || first_bits == 4'd12 || first_bits == 4'd14 || first_bits == 4'd15);
assign hex0[3] = (first_bits == 4'd1 || first_bits == 4'd4 || first_bits == 4'd7 || first_bits == 4'd9 || first_bits == 4'd10 || first_bits == 4'd15);
assign hex0[4] = (first_bits == 4'd1 || first_bits == 4'd3 || first_bits == 4'd4 || first_bits == 4'd5 || first_bits == 4'd7 || first_bits == 4'd9);
assign hex0[5] = (first_bits == 4'd1 || first_bits == 4'd2 || first_bits == 4'd3 || first_bits == 4'd7 || first_bits == 4'd13);
assign hex0[6] = (first_bits == 4'd0 || first_bits == 4'd1 || first_bits == 4'd7 || first_bits == 4'd12);


assign hex1[0] = (second_bits == 4'd1|| second_bits == 4'd4 || second_bits == 4'd11 || second_bits == 4'd13);
assign hex1[1] = (second_bits == 4'd5 || second_bits == 4'd6 || second_bits == 4'd11 || second_bits == 4'd14 || second_bits == 4'd15);
assign hex1[2] = (second_bits == 4'd2 || second_bits == 4'd12 || second_bits == 4'd14 || second_bits == 4'd15);
assign hex1[3] = (second_bits == 4'd1 || second_bits == 4'd4 || second_bits == 4'd7 || second_bits == 4'd9 || second_bits == 4'd10 || second_bits == 4'd15);
assign hex1[4] = (second_bits == 4'd1 || second_bits == 4'd3 || second_bits == 4'd4 || second_bits == 4'd5 || second_bits == 4'd7 || second_bits == 4'd9);
assign hex1[5] = (second_bits == 4'd1 || second_bits == 4'd2 || second_bits == 4'd3 || second_bits == 4'd7 || second_bits == 4'd13);
assign hex1[6] = (second_bits == 4'd0 || second_bits == 4'd1 || second_bits == 4'd7 || second_bits == 4'd12);

reg Empty, Full;



always @(posedge Clk, negedge RstN) begin
    if(!RstN) begin
        state <= 0;
        is_heater_on <= 0;
        cooler_RPS <= 0;
        invalid_temp <= 0;
        Empty <= 1'b0;
		Full <= 1'b0;
		pointer <= 3'b0;
		temp <= 8'b0;
    end
    
    else if(control == 2'd0 && !Full) begin 
		stack_instance[pointer] <= input_temp;
		pointer <= pointer + 1;
		Full <= (pointer == 3'd7);
		Empty <= 1'b1;
	end else if (control == 2'd1 && Empty) begin
		pointer <= pointer - 1;
		temp <= stack_instance[pointer-1];
		Empty <= !(pointer == 3'd1);
		Full <= 1'b0;
	end else if (control == 2'd2) begin
		
		if(temp > 8'sd60 || temp < -8'sd10) begin
			invalid_temp <= 1;
		end

		else if(state == 3'd0 && temp < 8'sd15) begin
			state <= 3'd4;
			is_heater_on <= 1;
			invalid_temp <= 0;
		end

		else if(state == 3'd0 && temp > 8'sd35) begin
			cooler_RPS <= 4'd4;
			state <= 3'd1;
			invalid_temp <= 0;
		end

		else if(state == 3'd1 && temp < 8'sd25) begin
			cooler_RPS <= 4'd0;
			state <= 3'd0;
			invalid_temp <= 0;
		end

		else if(state == 3'd1 && temp > 8'sd 40) begin
			cooler_RPS <= 4'd6;
			state <= 3'd2;
			invalid_temp <= 0;
		end

		else if(state == 3'd2 && temp > 8'sd45) begin
			cooler_RPS <= 4'd8;
			state <= 3'd3;
			invalid_temp <= 0;
		end
		
		else if(state == 3'd2 && temp < 8'sd35 && temp >= 8'sd25) begin
			cooler_RPS <= 4'd4;
			state <= 3'd1;
			invalid_temp <= 0;
		end

		else if(state == 3'd2 && temp < 8'sd 25) begin
			cooler_RPS <= 4'd0;
			state <= 3'd0;
			invalid_temp <= 0;
		end

		else if(state == 3'd3 && temp >= 8'sd25 && temp < 8'sd40) begin
			cooler_RPS <= 4'd6;
			state <= 3'd2;
			invalid_temp <= 0;
		end

		else if(state == 3'd3 && temp < 8'sd25) begin
			cooler_RPS <= 4'd0;
			state <= 3'd0;
			invalid_temp <= 0;
		end

		else if(state == 3'd4 && temp > 8'sd30) begin
			is_heater_on <= 1'd0;
			state <= 3'd0;
			invalid_temp <= 0;
		end
	end
    

end
    
endmodule