module CpuWrapper (
    input clk,
    input rstN,
    input[7:0]data_in,
    input enable,
    output error,
    output[6:0] hex0,
    output[6:0] hex1
);

wire [7:0] io_output;
Cpu inner_cpu (
    .clk(clk),
    .rstN(rstN),
    .data_in(data_in),
    .enable(enable),
    .error(error),
    .io_output(io_output)
);

wire first_bits = io_output[3:0];
wire second_bits = io_output[7:4];

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

    
endmodule