`timescale 1ns/1ps

module complex_ALU_tb;
    reg clk, rstN;
    wire done;

    complex_number_ALU DUT (
        .clk(clk),
        .rstN(rstN),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        $dumpfile("complex_ALU.vcd");
        $dumpvars(0, complex_ALU_tb);

        clk = 0;
        rstN = 1;

        // Reset
        #20 rstN = 0;

        // Initialize memory manually
        // Complex numbers: [31:16]=real, [15:0]=imag

        // Operand A = 3 + j2
        DUT.MEM.mem[1] = {16'd3, 16'd2};

        // Operand B = 1 + j4
        DUT.MEM.mem[2] = {16'd1, 16'd4};

        // Instruction: ADD  mem[1] + mem[2] → mem[3]
        // opcode=0000
        DUT.MEM.mem[0] = {4'b0000, 5'd1, 5'd2, 5'd3, 13'd0};

        // Instruction: MUL mem[1] * mem[2] → mem[4]
        DUT.MEM.mem[5] = {4'b0010, 5'd1, 5'd2, 5'd4, 13'd0};

        // Let simulation run
        wait (done) begin
           $display("ADD result = %d + j%d",
                DUT.MEM.mem[3][31:16],
                DUT.MEM.mem[3][15:0]);
        end

        

        $display("MUL result = %d + j%d",
            DUT.MEM.mem[4][31:16],
            DUT.MEM.mem[4][15:0]);

        $stop;
    end

endmodule
