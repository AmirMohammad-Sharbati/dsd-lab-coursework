`timescale 1ns/1ps

module tcam_tb;

    // Parameters
    localparam int WIDTH = 16;
    localparam int DEPTH = 16;

    // DUT signals
    reg  [WIDTH-1:0] search_data;
    reg  [WIDTH-1:0] value [DEPTH-1:0];
    reg  [WIDTH-1:0] mask  [DEPTH-1:0];
    wire [DEPTH-1:0] match;

    // Reference model result
    reg  [DEPTH-1:0] expected_match;

    integer i, b, test;

    // Instantiate DUT
    tcam #(
        .WIDTH(WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .search_data(search_data),
        .value(value),
        .mask(mask),
        .match(match)
    );

    // --------------------------------------------------
    // Reference TCAM model (golden model)
    // --------------------------------------------------
    task compute_expected;
        begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                expected_match[i] = 1'b1;
                for (b = 0; b < WIDTH; b = b + 1) begin
                    if (mask[i][b] == 1'b0 && search_data[b] != value[i][b])
                        expected_match[i] = 1'b0;
                end
            end
        end
    endtask

    // --------------------------------------------------
    // Directed tests
    // --------------------------------------------------
    initial begin
        $display("=== TCAM TESTBENCH START ===");

        // Initialize
        for (i = 0; i < DEPTH; i = i + 1) begin
            value[i] = '0;
            mask[i]  = '0;
        end
        search_data = '0;
        #10;

        // Test 1: Exact match
        value[0] = 16'hA55A;
        mask[0]  = 16'h0000; // no X
        search_data = 16'hA55A;
        compute_expected();
        #1;
        if (match !== expected_match)
            $fatal("ERROR: Exact match failed");
        else
            $display("PASS: Exact match");

        // Test 2: Masked match
        value[1] = 16'b0110_1100_1010_1111;
        mask[1]  = 16'b0000_1111_0000_1111; // X bits
        search_data = 16'b0110_0000_1010_0000;
        compute_expected();
        #1;
        if (match !== expected_match)
            $fatal("ERROR: Masked match failed");
        else
            $display("PASS: Masked match");

        // Test 3: Guaranteed mismatch
        value[2] = 16'hFFFF;
        mask[2]  = 16'h0000;
        search_data = 16'h0000;
        compute_expected();
        #1;
        if (match !== expected_match)
            $fatal("ERROR: Mismatch test failed");
        else
            $display("PASS: Mismatch");

        // --------------------------------------------------
        // Random tests
        // --------------------------------------------------
        $display("Running random tests...");
        for (test = 0; test < 200; test = test + 1) begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                value[i] = $random;
                mask[i]  = $random; // random X locations
            end

            search_data = $random;

            compute_expected();
            #1;

            if (match !== expected_match) begin
                $display("FAIL at random test %0d", test);
                $display("search_data = %h", search_data);
                for (i = 0; i < DEPTH; i = i + 1) begin
                    $display("Entry %0d: value=%h mask=%h match=%b exp=%b",
                             i, value[i], mask[i], match[i], expected_match[i]);
                end
                $fatal;
            end
        end

        $display("=== ALL TCAM TESTS PASSED SUCCESSFULLY ===");
        $finish;
    end

endmodule
