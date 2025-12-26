module complex_number_ALU (
    input clk, resetNot, start,
    input [4:0] pc
);

    // Pipeline registers
    reg [31:0] instr_fetch;
    reg [31:0] instr_decode;
    reg [4:0] mem_address;
    wire[31:0] instruction;

    // Instruction fields
    reg [3:0] opcode;

    // Example operands
    reg signed [15:0] a_real, a_imag, b_real, b_imag;

    wire signed [15:0] add_real, add_imag;
    wire signed [31:0] mul_real, mul_imag;
    wire done;

    // Instruction memory
    memory mem (clk, mem_address, instruction);
    input clk, 
    input write_enable, read_enable,
    input [4:0] address,
    input [31:0] write_data,
    output reg [31:0] read_data  

    // Adder/Subtractor
    complex_add_sub ADDER (
        .a_real(a_real),
        .a_imag(a_imag),
        .b_real(b_real),
        .b_imag(b_imag),
        .op(opcode[0]),
        .y_real(add_real),
        .y_imag(add_imag)
    );

    // Multiplier
    complex_mul MUL (
        .clk(clk),
        .rst(rst),
        .start(opcode == 4'b0010),
        .a_real(a_real),
        .a_imag(a_imag),
        .b_real(b_real),
        .b_imag(b_imag),
        .y_real(mul_real),
        .y_imag(mul_imag),
        .done(mul_done)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc <= 0;
        end else begin
            pc <= pc + 1;

            // IF → ID
            instr_ID <= instr_IF;

            // Decode
            opcode <= instr_ID[31:28];

            // Example fixed operands (replace with register file later)
            a_real <= 16'd3;
            a_imag <= 16'd2;
            b_real <= 16'd1;
            b_imag <= 16'd4;
        end
    end

endmodule
