module complex_number_ALU(
    input clk,
    input rstN,
    output reg done
);

    reg [4:0] pc;

    /* ========= STATE MACHINE ========= */
    reg [3:0] state;
    parameter FETCH = 3'd0,
              FETCH_WAIT_1 = 3'd1,
              FETCH_WAIT_2 = 3'd2,
              DECODE = 3'd3,
              READ_A = 3'd4,
              WAIT_READ_A = 3'd5,
              READ_B = 4'd6,
              WAIT_READ_B = 4'd7,
              EXECUTE = 4'd8,
              ALU_WAIT = 4'd9,
              ADD_WRITE = 4'd10,
              MUL_WRITE = 4'd11,
              MUL_COMPLETE_WB = 4'd12,
              DONE = 4'd13;

    /* ========= REGISTERS ========= */
    reg [31:0] instruction;
    reg [3:0] opcode;
    reg [4:0] srcA_addr, srcB_addr, dst_addr;

    reg [31:0] opA, opB;
    reg [31:0] result;

    /* ========= MEMORY ========= */
    reg mem_wr, mem_re;
    reg [4:0] mem_addr;
    reg [31:0] mem_wdata;
    wire [31:0] mem_rdata;


    memory MEM (
        .clk(clk),
        .write_enable(mem_wr),
        .read_enable(mem_re),
        .address(mem_addr),
        .write_data(mem_wdata),
        .read_data(mem_rdata)
    );


    /* ========= ALU UNITS ========= */
    reg start_addsub, start_mul;
    wire done_addsub, done_mul;
    wire [31:0] addsub_result;
    wire [63:0] mul_result;

    complex_adder ADD_SUB (
        .clk(clk), .resetNot(rstN), .start(start_addsub),
        .A(opA), .B(opB),
        .op(opcode[0]),
        .result(addsub_result),
        .done(done_addsub)
    );

    
    complex_mult MUL (
        .clk(clk), .resetNot(rstN), .start(start_mul),
        .A(opA), .B(opB),
        .result (mul_result),
        .done(done_mul)
    );

    /* ========= CONTROL ========= */
    always @(posedge clk or negedge rstN) begin
        if (!rstN) begin
            pc <= 0;
            state <= FETCH;
            mem_wr <= 0;
            mem_re <= 0;
            start_addsub <= 0;
            start_mul <= 0;
            done <= 0;
        end else begin
            case (state)

                FETCH: begin
                    mem_wr <= 0;
                    done <= 0;
                    mem_addr <= pc;
                    mem_re <= 1'b1;
                    state <= FETCH_WAIT_1;
                end

                FETCH_WAIT_1: begin // Delay one clock cycle for reading from memory 
                    state <= FETCH_WAIT_2;
                end

                FETCH_WAIT_2: begin
                    instruction <= mem_rdata;
                    state <= DECODE;
                end
                
                DECODE: begin
                    opcode <= instruction[31:28];
                    srcA_addr <= instruction[27:23];
                    srcB_addr <= instruction[22:18];
                    dst_addr <= instruction[17:13];
                    state <= READ_A;
                end

                READ_A: begin
                    mem_addr <= srcA_addr;
                    mem_re <= 1'b1;
                    state <= WAIT_READ_A;
                end

                WAIT_READ_A: begin
                    state <= READ_B;
                end

                READ_B: begin
                    opA <= mem_rdata;
                    mem_addr <= srcB_addr;
                    mem_re <= 1'b1;
                    state <= WAIT_READ_B;
                end

                WAIT_READ_B: begin
                    state <= EXECUTE;
                end

                EXECUTE: begin
                    opB <= mem_rdata;
                    if (opcode == 4'b0010) begin
                        start_mul <= 1'b1;
                    end else begin
                        start_addsub <= 1'b1;
                    end
                    state <= ALU_WAIT;
                end

                ALU_WAIT: begin
                    start_mul <= 0;
                    start_addsub <= 0;
                    if (done_addsub)
                        state <= ADD_WRITE;
                    else if (done_mul)
                        state <= MUL_WRITE;
                end


                ADD_WRITE: begin
                    start_addsub <= 0;
                    mem_wr <= 1'b1;

                    mem_addr <= dst_addr;
                    mem_wdata <= addsub_result;
                    state <= DONE;
                end

                MUL_WRITE: begin
                    start_mul <= 0;
                    mem_wr <= 1'b1;

                    mem_addr <= dst_addr;
                    mem_wdata <= mul_result[31:0];
                    state <= MUL_COMPLETE_WB;
                end

                MUL_COMPLETE_WB: begin
                    mem_addr <= dst_addr + 1;
                    mem_wdata <= mul_result[63:32];
                    state <= DONE;
                end

                DONE: begin
                    done <= 1;
                    state <= FETCH;
                    pc <= pc + 1;
                end

            endcase
        end
    end

endmodule
