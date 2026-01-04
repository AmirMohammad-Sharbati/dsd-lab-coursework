module tcam_tb;

    // Parameters
    parameter WIDTH = 16;
    parameter DEPTH = 16;
    parameter ADDR_WIDTH = 4;

    // DUT signals
    reg clk, write_enable, reset;
    reg [ADDR_WIDTH-1:0] write_addr;
    reg [WIDTH-1:0] write_value;
    reg [WIDTH-1:0] write_mask;
    reg [WIDTH-1:0] search_data;
    wire [DEPTH-1:0] match;

    // Reference model storage
    reg [WIDTH-1:0] ref_value [0:DEPTH-1];
    reg [WIDTH-1:0] ref_mask  [0:DEPTH-1];

    reg [DEPTH-1:0] expected_match;

    integer i, b, test;

    // Instantiate DUT
    tcam #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .write_addr(write_addr),
        .write_value(write_value),
        .write_mask(write_mask),
        .search_data(search_data),
        .match(match)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;
    reg error_flag;


    task write_entry;
        input [ADDR_WIDTH-1:0] addr;
        input [WIDTH-1:0] value;
        input [WIDTH-1:0] mask;
        begin
            @(posedge clk);
            write_enable = 1'b1;
            write_addr = addr;
            write_value = value;
            write_mask = mask;
            #1; // small delay to ensure write occurs
            // update reference model
            ref_value[addr] = value;
            ref_mask [addr] = mask;

            @(posedge clk);
            write_enable = 1'b0;
        end
    endtask

    function [DEPTH-1:0] compute_match;
        input [WIDTH-1:0] key;
        integer r, c;
        begin
            for (r = 0; r < DEPTH; r = r + 1) begin
                compute_match[r] = 1'b1;
                for (c = 0; c < WIDTH; c = c + 1) begin
                    if (ref_mask[r][c] == 1'b0 &&
                        key[c] != ref_value[r][c])
                        compute_match[r] = 1'b0;
                end
            end
        end
    endfunction


    task check_search;
        input [WIDTH-1:0] key;
        begin
            search_data = key;
            #1; 

            expected_match = compute_match(key);

            if (match !== expected_match) begin
                error_flag = 1;
                $display("---- ERROR! --- search_data = %h || expected = %b || got = %b", key, expected_match, match);
            end
        end
    endtask


    initial begin
        $dumpfile("tcam.vcd");
        $dumpvars(0, tcam_tb);

        $display("========= TCAM TEST START =========");

        // Initialize
        reset = 1;
        error_flag = 0;
        write_enable = 0;
        search_data  = 0;
        for (i = 0; i < DEPTH; i = i + 1) begin
            ref_value[i] = 0;
            ref_mask [i] = 0;
        end
        #10;

        reset = 0;
        @(posedge clk);

        // Directed tests
        $display("Running directed tests...");
        write_entry(0, 16'hA55A, 16'h0000); // exact
        write_entry(1, 16'h0F0F, 16'h00FF); // masked
        write_entry(3, 16'h0A12, 16'h0FFF); // masked
        write_entry(2, 16'hFFFF, 16'h0000); // exact
        write_entry(4, 16'h1234, 16'h1000); // masked

        check_search(16'hA55A);
        check_search(16'h0F55);
        check_search(16'h0000);
        check_search(16'h1234);


        // Random tests
        $display("Running random tests...");
        for (test = 0; test < 300; test = test + 1) begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                write_entry(i, $random, $random);
            end
            check_search($random);
        end

        // Final result
        if (error_flag) begin
            $display("========= TCAM TEST FAILED =========");
            $finish;
        end else begin
            $display("========= ALL TCAM TESTS PASSED =========");
        end

        $finish;
    end

endmodule
