module Cpu (
    input clk,
    input rstN,
    input enable,
    input[7:0] data_in,
    output error,
    output [7:0] io_output
);

wire [4:0] pc_din;
wire[4:0] pc_dout;
wire pc_enable; 
EnRegister#(.N(5)) pc(
    .clk(clk),
    .rstN(rstN),
    .enable(pc_enable),
    .d(pc_din),
    .q(pc_dout)
);

wire Z_din, Z_dout, Z_enable, S_din, S_dout, S_enable;
EnRegister#(.N(1)) Z(
    .clk(clk),
    .rstN(rstN),
    .enable(Z_enable),
    .d(Z_din),
    .q(Z_dout)
);

EnRegister#(.N(1)) S(
    .clk(clk),
    .rstN(rstN),
    .enable(S_enable),
    .d(S_din),
    .q(S_dout)
);

wire inst_step;
EnRegister#(.N(1)) step(
    .clk(clk),
    .rstN(rstN),
    .enable(enable),
    .d(~inst_step),
    .q(inst_step)
);

wire[11:0]instruction;
Instmem instruction_rom (
    .PC(pc_dout),
    .instruction(instruction)
);
wire[3:0] opcode = instruction[11:8];
wire [7:0] operand = instruction[7:0];

assign pc_enable = enable && inst_step;
assign Z_enable = ((opcode == 4'd6) || (opcode == 4'd7)) && inst_step;
assign S_enable = ((opcode == 4'd6) || (opcode == 4'd7)) && inst_step;

wire[7:0] stack_dout;

assign pc_din = (opcode == 4'd3) || (opcode == 4'd4 && Z_dout) || (opcode == 4'd5 && S_dout)?stack_dout:pc_dout + 1;
assign Z_din = (stack_dout == 8'd0);
assign S_din = stack_dout[7];

wire stack_push, stack_pop, stack_is_addition;
wire [7:0] stack_din;
wire stack_error;
AdvancedStack cpu_stack (
    .clk(clk),
    .rstN(rstN),
    .push(stack_push),
    .pop(stack_pop),
    .is_addition(stack_is_addition),
    .data_in(stack_din),
    .data_out(stack_dout),
    .error(stack_error)
);


wire memory_we;
wire[7:0] memory_din;
wire[7:0] memory_address;
wire[7:0] memory_dout;
wire[7:0] memory_error;

assign stack_push = ((opcode == 4'd0) || (opcode == 4'd1) || (opcode == 4'd6) || (opcode == 4'd7)) && !inst_step;
assign jump_pop_cond = (opcode == 4'd4 && Z_dout) || (opcode == 4'd5 && S_dout);
assign stack_pop = ((opcode == 4'd2) || (opcode == 4'd6) || (opcode == 4'd7) || jump_pop_cond) && !inst_step;
assign stack_is_addition = opcode == 4'd6;
assign stack_din = (opcode == 4'd0)?operand:memory_dout;

Memory cpu_memory(
    .clk(clk),
    .rstN(rstN),
    .we(memory_we),
    .data_in(memory_din),
    .address(memory_address),
    .read_data(memory_dout),
    .io_output(io_output),
    .error_output(memory_error)
);

assign error = memory_error[0];

wire write_error_cond = (opcode < 4'd3 || opcode > 4'd5) && stack_error && inst_step;
wire write_in_pop_cond = opcode == 4'd2 && !stack_error && inst_step;
assign memory_we = !enable || write_error_cond || write_in_pop_cond;
assign memory_address = !enable?8'd248:(write_error_cond?8'd255:operand);
assign memory_din = !enable?data_in:(write_error_cond?8'd1:stack_dout);

endmodule