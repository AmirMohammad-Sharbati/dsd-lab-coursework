// module complex_number_ALU(
//     input clk, rstN,
//     output reg done
// );

//     reg [4:0] pc;

//     // pipeline registers
//     reg [31:0] IF_instr;
//     reg [31:0] ID_instr;

//     // Decode fields
//     reg [3:0] opcode;
//     reg [4:0] srcA_addr, srcB_addr, dst_addr;

    
//     // Operands & results  
//     reg  [31:0] opA, opB;
//     wire [31:0] addsub_result;
//     wire [63:0] mul_result;

//     reg start_addsub, start_mul;
//     wire done_addsub, done_mul;

//     reg busy;   // stall control

//     // memory control
//     reg mem_wr, mem_re;
//     reg [4:0] mem_addr;
//     reg [31:0] mem_wdata;
//     wire [31:0] mem_rdata;

    
//     memory MEM (
//         .clk(clk),
//         .write_enable(mem_wr),
//         .read_enable(mem_re),
//         .address(mem_addr),
//         .write_data(mem_wdata),
//         .read_data(mem_rdata)
//     );

    
//     complex_adder ADD_SUB (
//         .clk(clk), .resetNot(rstN), .start(start_addsub),
//         .A(opA), .B(opB),
//         .op(opcode[0]),
//         .result(addsub_result),
//         .done(done_addsub)
//     );

    
//     complex_mult MUL (
//         .clk(clk), .resetNot(rstN), .start(start_mul),
//         .A(opA), .B(opB),
//         .result (mul_result),
//         .done(done_mul)
//     );

    
//     always @(posedge clk or negedge rstN) begin
//         if (!rstN) begin
//             pc <= 0;
//             busy <= 0;
//             start_addsub <= 0;
//             start_mul <= 0;
//         end else begin

//             /* ========= IF STAGE ========= */
//             if (!busy) begin
//                 mem_addr <= pc;
//                 mem_re <= 1'b1;
//                 IF_instr <= mem_rdata;
//                 pc <= pc + 1;
//             end

//             /* ========= ID STAGE ========= */
//             if (!busy) begin
//                 ID_instr  <= IF_instr;
//                 opcode    <= IF_instr[31:28];
//                 srcA_addr <= IF_instr[27:23];
//                 srcB_addr <= IF_instr[22:18];
//                 dst_addr  <= IF_instr[17:13];

//                 // read operand A
//                 mem_addr <= srcA_addr;
//                 mem_re <= 1'b1;
//                 opA <= mem_rdata;

//                 // read operand B
//                 mem_addr <= srcB_addr;
//                 mem_re <= 1'b1;
//                 opB <= mem_rdata;
//             end

//             // Execution step (EX)
//             if (!busy) begin
//                 case (opcode)
//                     4'b0000, 4'b0001: begin // ADD or SUB
//                         start_addsub <= 1'b1;
//                         busy <= 1'b1;
//                     end
//                     4'b0010: begin          // MUL
//                         start_mul <= 1'b1;
//                         busy      <= 1'b1;
//                     end
//                 endcase
//             end

//             // Wait for done
//             if (busy) begin
//                 if (done_addsub) begin
//                     start_addsub <= 1'b0;
//                     busy <= 1'b0;
//                 end
//                 else if (done_mul) begin
//                     start_mul <= 1'b0;
//                     busy <= 1'b0;
//                 end
//             end

//             // write back stage
//             if (!busy && done_addsub) begin
//                 mem_addr <= dst_addr;
//                 mem_wdata <= addsub_result;
//                 mem_wr <= 1'b1;
//                 done <= 1;
//             end else if (!busy && done_mul) begin
//                 mem_addr <= dst_addr;
//                 mem_wdata <= mul_result[31:0];
//                 mem_addr <= dst_addr + 1;
//                 mem_wdata <= mul_result[63:32];
//                 mem_wr <= 1'b1;
//                 done <= 1;
//             end else begin
//                 mem_wr <= 1'b0;
//             end

//         end
//     end

// endmodule



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
              WRITEBACK = 4'd10,
              DONE = 4'd11;

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

                FETCH_WAIT_1: begin // Delay one clock cycle for reading from memory (This is also used for load instruction)
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
                    if (done_addsub || done_mul) begin 
                        state <= WRITEBACK;
                    end
                end

                WRITEBACK: begin
                    start_addsub <= 0;
                    start_mul <= 0;
                    mem_wr <= 1'b1;

                    if (done_addsub) begin
                        mem_addr <= dst_addr;
                        mem_wdata <= addsub_result;
                    end else if (done_mul) begin
                        mem_addr <= dst_addr;
                        mem_wdata <= mul_result;
                    end

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
