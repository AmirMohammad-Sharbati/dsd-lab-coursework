module tb;

reg Clk, RstN;
reg signed [7:0] temp;
wire is_heater_on;
wire [3:0] cooler_RPS;
reg[4:0] failed;
reg[4:0] test_number;

initial begin
    $dumpfile("wave1.vcd");
    $dumpvars(0, tb);
end

Incubator dut(
    .Clk(Clk),
    .RstN(RstN),
    .temp(temp),
    .is_heater_on(is_heater_on),
    .cooler_RPS(cooler_RPS)
);

task show_cooler_state(input [3:0] cooler_round_per_second);
    begin
        case(cooler_round_per_second)
            4'd0: $display("Cooler is off!");
            4'd4: $display("Cooler is on and RPS = 4");
            4'd6: $display("Cooler is on and RPS = 6");
            4'd8: $display("Cooler is on and RPS = 8");
        endcase
    end
endtask

task show_heater_state(input heater_state);
    begin
        case(heater_state)
            1'd0: $display("Heater is off!");
            1'd1: $display("Heater is on!");
        endcase
    end
endtask

task set_temp_and_show_stat(input signed [7:0] temperature, input correct_heater, input [3:0] correct_cooler);
    begin
        RstN = 1;
        temp = temperature;
        @(posedge Clk);
        #1;
        show_cooler_state(cooler_RPS);
        show_heater_state(is_heater_on);
        if(is_heater_on == correct_heater && cooler_RPS == correct_cooler) $display("Test Passed!");
        else begin
            $display("Test Failed!");
            failed = failed + 1;
        end
        $display("-------------------------------\n");
        test_number = test_number + 1;
    end
endtask

always begin
    Clk = 1'b0;
    #50;
    Clk = 1'b1;
    #50;
end


initial begin
    failed = 5'd0;
    test_number = 5'd0;
    RstN = 0;
    @(posedge Clk);
    #1;
    show_cooler_state(cooler_RPS);
    show_heater_state(is_heater_on);
    if(is_heater_on == 1'd0 && cooler_RPS == 1'd0) $display("Reset was successful!");
    else $display("Reset Failed!");
    $display("-------------------------------\n");
    
    $display("Making the weather cold!");
    set_temp_and_show_stat(12, 1'd1, 4'd0);

    $display("Making the weather colder! You shouldn't change anything.");
    set_temp_and_show_stat(-10, 1'd1, 4'd0);

    $display("Got warm! nothing should be on!");
    set_temp_and_show_stat(31, 1'd0, 4'd0);

    $display("Got warmer! Turn the cooler on with RPS = 4.");
    set_temp_and_show_stat(36, 1'd0, 4'd4);

    $display("Got cold! Turn the cooler of.");
    set_temp_and_show_stat(24, 1'd0, 4'd0);
    
    $display("Got warm again. turn the cooler on with RPS = 4");
    set_temp_and_show_stat(41, 1'd0, 4'd4);

    $display("Still warm! increase the RPS to 6.");
    set_temp_and_show_stat(41, 1'd0, 4'd6);

    $display("Suddenly, got too cold! Turn the cooler off.");
    set_temp_and_show_stat(22, 1'd0, 4'd0);

    $display("Got warm! turn the cooler on again with RPS = 4");
    set_temp_and_show_stat(46, 1'd0, 4'd4);

    $display("Still too warm! increase the RPS to 6");
    set_temp_and_show_stat(46, 1'd0, 4'd6);

    $display("Still too warm! increase the RPS to 8");
    set_temp_and_show_stat(46, 1'd0, 4'd8);

    $display("Suddenly, it Got cold. Turn the cooler of!");
    set_temp_and_show_stat(-1, 1'd0, 4'd0);

    $display("Got warm fot the fourth time!! turn the cooler on with RPS = 4.");
    set_temp_and_show_stat(50, 1'd0, 4'd4);

    $display("Still warm! increase RPS to 6.");
    set_temp_and_show_stat(50, 1'd0, 4'd6);

    $display("Still warm! increase RPS to 8.");
    set_temp_and_show_stat(50, 1'd0, 4'd8);

    $display("Better but still warm. decrease RPS to 6");
    set_temp_and_show_stat(35, 1'd0, 4'd6);

    $display("Better but still warm. decrease RPS to 4");
    set_temp_and_show_stat(30, 1'd0, 4'd4);
	 #30;

     if (failed == 0)
        $display("RESULT: PASSED");
    else
        $display("RESULT: FAILED (%0d out of %0d failed)", failed, test_number);

    $finish();
end

endmodule