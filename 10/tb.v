module tb;
reg[7:0] data_in;
reg clk;
reg rstN;
reg enable;
wire [7:0] io_output;
wire error;
Cpu dut(
    .clk(clk),
    .rstN(rstN),
    .enable(enable),
    .data_in(data_in),
    .io_output(io_output),
    .error(error)
);
integer total = 0;
integer passed = 0;
integer i;

initial begin
    clk = 1'd0;
    forever #20 clk = ~clk; 
end 

initial begin
    $dumpfile("cpu.vcd");
    $dumpvars(0, tb);
end

initial begin
    $display("\n---------------Testing minimum possible invalid positive X--------------------");

    rstN = 0;
    enable = 1;
    @(posedge clk);
    #2;
    enable = 0;
    rstN = 1;
    data_in = 8'd47;
    @(posedge clk);
    #2;
    enable = 1;
    #2500;
    if(error == 1) begin
        $display("Passed, You turned the error bit on correctly!");
        passed = passed + 1;
    end
    else
        $display("Failed, 2*(X+23)-12 = %0d > 127 but error bit is off!", 2*(data_in+23)-12);
    total = total + 1;
    
    $display("\n---------------Testing Maximum valid X--------------------");
    rstN = 0;
    enable = 1;
    @(posedge clk);
    #2;
    enable = 0;
    rstN = 1;
    data_in = 8'd46;
    @(posedge clk);
    #2;
    enable = 1;
    #2500;
    $display("X = %d, 2*(X + 23) - 12 = %0d, Your result = %d, Error output = %d", data_in, 2*(data_in+23)-12, io_output, error);
    if(io_output == (2 * (data_in+23) - 12) && error == 1'd0) begin
        $display("Passed!");
        passed = passed + 1;
    end
    else 
        $display("Failed");
    total = total + 1;

    $display("\n---------------Testing edge case with X = 0--------------------");
    rstN = 0;
    enable = 1;
    @(posedge clk);
    #2;
    enable = 0;
    rstN = 1;
    data_in = 8'd0;
    @(posedge clk);
    #2;
    enable = 1;
    #2500;
    if(error == 1) begin
        $display("Passed, X was not positive and you turned the error on!");
        passed = passed + 1;
    end
    else
        $display("Failed, X was not positive, but you didn't turn the error on!");
    total = total + 1;
    
    $display("\n---------------Testing edge case with X = -1--------------------");
    rstN = 0;
    enable = 1;
    @(posedge clk);
    #2;
    enable = 0;
    rstN = 1;
    data_in = 8'hFF;
    @(posedge clk);
    #2;
    enable = 1;
    #2500;
    if(error == 1) begin
        $display("Passed, X was negative and you turned the error on!");
        passed = passed + 1;
    end
    else
        $display("Failed, X was negative, but you didn't turn the error on!");
    total = total + 1;

    $display("\n---------------Testing some valid numbers--------------------");
    for(i = 0; i < 5; i= i + 1) begin
        rstN = 0;
    enable = 1;
    @(posedge clk);
    #2;
    enable = 0;
    rstN = 1;
    data_in = $urandom_range(1,46);
    @(posedge clk);
    #2;
    enable = 1;
    #2500;
    $display("X = %0d, 2*(X + 23) - 12 = %0d, Your result = %d, Error output = %d", data_in, 2*(data_in+23)-12, io_output, error);
    if(io_output == (2 * (data_in+23) - 12) && error == 1'd0) begin
        $display("Passed!\n");
        passed = passed + 1;
    end
    else 
        $display("Failed\n");
    total = total + 1;
    end

        $display("\n---------------Testing some number with X+23 > 127--------------------");
    rstN = 0;
    enable = 1;
    @(posedge clk);
    #2;
    enable = 0;
    rstN = 1;
    data_in = 8'd110;
    @(posedge clk);
    #2;
    enable = 1;
    #2500;
    if(error == 1) begin
        $display("Passed, X was so big and you turned the error on!");
        passed = passed + 1;
    end
    else
        $display("Failed, X was so big, but you didn't turn the error on!");
    total = total + 1;

    $display("\nPassed %0d / %0d of tests",passed, total);
    if(passed == total)
        $display("Passed all the tests!");
    else
        $display("Some tests Failed!");
    
    $finish;
end
endmodule