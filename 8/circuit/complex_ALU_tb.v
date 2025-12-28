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
        // Reset
        rstN = 0;
        #20 rstN = 1;

        // Initialize memory manually
        // Complex numbers: [31:16]=real, [15:0]=imag

        // Operand A = 3 + 2i
        DUT.MEM.mem[16] = {16'd3, 16'd2};

        // Operand B = 1 + 4i
        DUT.MEM.mem[17] = {16'd1, 16'd4};

        // Instruction: ADD:  mem[16] + mem[17] -> mem[3]
        DUT.MEM.mem[0] = {4'b0000, 5'd16, 5'd17, 5'd3, 13'd0};

        // Instruction: MUL: mem[16] * mem[17] -> mem[4]
        DUT.MEM.mem[1] = {4'b0010, 5'd16, 5'd17, 5'd4, 13'd0};

        // Instruction: SUB: mem[16] - mem[17] -> mem[6]
        DUT.MEM.mem[2] = {4'b0001, 5'd16, 5'd17, 5'd6, 13'd0};

        // Let simulation run
        wait (done) begin
           $display("ADD result = %0d + %0di",
                $signed(DUT.MEM.mem[3][31:16]),
                $signed(DUT.MEM.mem[3][15:0]));
        end

        #100;

        wait (done) begin 
            $display("MUL result = %0d + %0di",
                $signed(DUT.MEM.mem[5][31:0]),
                $signed(DUT.MEM.mem[4][31:0]));
        end

        #100;

        wait (done) begin 
            $display("SUB result = %0d + %0di",
                $signed(DUT.MEM.mem[6][31:16]),
                $signed(DUT.MEM.mem[6][15:0]));
        end

        $finish;
    end

endmodule
