module complex_number_ALU(
    input clk,
    input rstN,
    input [7:0] in_number,
    output reg done, 
    output reg [31:0] mem_wdata
);

    reg [4:0] pc;
    wire [31:0] number = {{12{in_number[7]}}, {in_number[7:4]}, {12{in_number[3]}}, {in_number[3:0]}};

    /* ========= STATE MACHINE ========= */
    reg [3:0] state;
    parameter FETCH = 3'd0,
              FETCH_WAIT_1 = 3'd1,
              FETCH_WAIT_2 = 3'd2,
              DECODE = 3'd3,
              READ = 3'd4,
              WAIT_READ = 3'd5,
              EXECUTE = 4'd8,
              ALU_WAIT = 4'd9,
              ADD_WRITE = 4'd10,
              MUL_WRITE = 4'd11,
              MUL_COMPLETE_WB = 4'd12,
              DONE = 4'd13,
              PRE_DECODE = 4'd14,
              LOAD = 4'd15;

    /* ========= REGISTERS ========= */
    reg [31:0] instruction [0:2];
    reg [3:0] opcode_1, opcode_2, opcode_3;
    reg [4:0] srcA_addr, srcB_addr;
    reg [4:0] dst_addr_1, dst_addr_2,dst_addr_3,dst_addr_4,dst_addr_5,dst_addr_6,dst_addr_7,dst_addr_8,dst_addr_9;

    reg [31:0] opA, opB;
    reg [31:0] result;

    /* ========= MEMORY ========= */
    reg mem_wr, mem_re;
    reg [4:0] mem_addr1, mem_addr2, mem_inst_addr;
    
    wire [31:0] mem_rdata_1, mem_rdata_2, mem_rinst;

    memory MEM (
        .clk(clk), .rstN(rstN),
        .write_enable(mem_wr),
        .read_enable(mem_re),
        .address1(mem_addr1), .address2(mem_addr2), .inst_addr(mem_inst_addr),
        .write_data(mem_wdata),
        .read_data_1(mem_rdata_1), .read_data_2(mem_rdata_2), .read_inst(mem_rinst)
    );


    /* ========= ALU UNITS ========= */
    reg start_addsub, start_mul;
    wire done_addsub, done_mul;
    wire [31:0] addsub_result;
    wire [63:0] mul_result;

    complex_adder ADD_SUB (
        .clk(clk), .resetNot(rstN), .start(start_addsub),
        .A(opA), .B(opB),
        .op(opcode_1[0]),
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
            mem_wr <= 0;
            done <= 0;
            mem_inst_addr <= pc;
            mem_re <= 1'b1;

            instruction[0] <= mem_rinst;
            instruction[1] <= instruction[0]; 

            opcode_1 <= instruction[1][31:28];
            srcA_addr <= instruction[1][27:23];
            srcB_addr <= instruction[1][22:18];
            dst_addr_1 <= instruction[1][17:13];

            opcode_2 <= opcode_1;
            dst_addr_2 <= dst_addr_1;

            mem_addr1 <= srcA_addr;
            mem_addr2 <= srcB_addr;
            mem_re <= 1'b1;
            
            opcode_3 <= opcode_2;
            dst_addr_3 <= dst_addr_2;
            
            mem_wr <= 1'b1;
            mem_addr_1 <= instruction[1][27:23];
            mem_wdata <= number;
            dst_addr_4 <= dst_addr_3;

            opA <= mem_rdata_1;
            opB <= mem_rdata_2;
            dst_addr_5 <= dst_addr_4;
            
            if (opcode_3  == 4'b0010) begin
                start_mul <= 1'b1;
            end else begin
                start_addsub <= 1'b1;
            end

            dst_addr_6 <= dst_addr_5;
            start_mul <= 0;
            start_addsub <= 0;

            dst_addr_7 <= dst_addr_6;
            start_addsub <= 0;
            mem_wr <= 1'b1;

            mem_addr <= dst_addr_7;
            mem_wdata <= addsub_result;
        
            dst_addr_8 <= dst_addr_7;
            start_mul <= 0;
            mem_wr <= 1'b1;

            mem_addr <= dst_addr_8;
            mem_wdata <= mul_result[31:0];

            dst_addr_9 <= dst_addr_8;
            mem_addr <= dst_addr_9 + 1;
            mem_wdata <= mul_result[63:32];
            done <= 1;
            pc <= pc + 1;
        end
    end

endmodule
