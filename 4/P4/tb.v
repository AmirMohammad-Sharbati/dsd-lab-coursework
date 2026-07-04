module tb;
    reg Clk, RstN,Push,Pop;
    reg[3:0] Data_In;
    wire Full, Empty;
    wire[3:0] Data_out;
	 
	 initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb);
    end

    stack dut(
        .Clk(Clk),
        .RstN(RstN),
        .Data_In(Data_In),
        .Push(Push),
        .Pop(Pop),
        .Data_out(Data_out),
        .Full(Full),
        .Empty(Empty)
    );

    always begin
        Clk = 1'b0;
        #50;
        Clk = 1'b1;
        #50;
    end

    task make_a_push(input [3:0] value_to_push);
        begin
            @(posedge Clk);
            Data_In = value_to_push;
            Push = 1; Pop = 0;
            @(posedge Clk);
            Push = 0;
        end
    endtask

    
    task make_a_pop();
        begin
            @(posedge Clk);
            Push = 0; Pop = 1;
            @(posedge Clk);
            Pop = 0;
        end
    endtask

    integer failed;
	 
    initial begin
        RstN = 1'b0;
        @(posedge Clk);
		  #1;
        $display("Data_out = %0d", Data_out);
        $display("Full = %0d", Full);
        $display("Empty = %0d", Empty);
        if(Empty == 1'b0 && Full == 1'b0 && Data_out == 0) $display("reset was Sucessful!");
        else $display("reset Failed!");
        $display("-----------------------------------");
        //---------------------------------------------------------
        $display("Pushing while RstN = 0 ...");
        Push = 1;
        Data_In = 4'd7;
        @(posedge Clk);
        //---------------------------------------------------------
        RstN = 1'b1;
        Pop = 1'b1;
        Push = 1'b0;
        @(posedge Clk);
		  #1;
        $write("Reset was 0 while pushing and Data_out = %0d, so your stack ", Data_out);
        if(Data_out == 0) $display("passed this test!");
        else $display("failed this test");
        $display("-----------------------------------");
        //----------------------------------------------------------
        $display("Pushing number 7 into stack...");
        make_a_push(4'd7);
        $display("now Popping it...");
        make_a_pop();
		  #1;
        $display("Data_out = %0d", Data_out);
        if(Data_out == 4'd7) $display("Passed the single push -> pop task!");
        else $display("Failed the single push -> pop task!");
        $display("-----------------------------------");
        //----------------------------------------------------------
        $display("pushing 8 values to the stack....");
        $display("pushing 1...");
        make_a_push(4'd1);
		  #1;
        $display("Full = %0d\n", Full);
        if(Full == 1'b1) failed = 1;

        $display("pushing 3...");
        make_a_push(4'd3);
		  #1;
        $display("Full = %0d\n", Full);
        if(Full == 1'b1) failed = 1;

        $display("pushing 5...");
        make_a_push(4'd5);
		  #1;
        $display("Full = %0d\n", Full);
        if(Full == 1'b1) failed = 1;

        $display("pushing 7...");
        make_a_push(4'd7);
		  #1;
        $display("Full = %0d\n", Full);
        if(Full == 1'b1) failed = 1;
        
        $display("pushing 9...");
        make_a_push(4'd9);
		  #1;
        $display("Full = %0d\n", Full);
        if(Full == 1'b1) failed = 1;

        $display("pushing 11...");
        make_a_push(4'd11);
		  #1;
        $display("Full = %0d\n", Full);
        if(Full == 1'b1) failed = 1;

        $display("pushing 13...");
        make_a_push(4'd13);
		  #1;
        $display("Full = %0d\n", Full);
        if(Full == 1'b1) failed = 1;
        if(failed) $display("You made the stack full too early!");

        $display("pushing 15...");
        make_a_push(4'd15);
		  #1;
        $display("now you should make the Full signal true!");
        $display("Full = %0d\n", Full);
        if(Full == 1) $display("You made that successfully!");
        else $display("Failed!");
        $display("-----------------------------------");
        //------------------------------------------------------
        $display("pushing 8 as an extra number!(should not affect the stack)");
        make_a_push(4'd8);
        $display("-----------------------------------");
        //-------------------------------------------------------
        failed = 0;
        $display("Popping ....");
        make_a_pop();
		  #1;
        $display("Data_out = %0d", Data_out);
        $display("Empty = %0d\n", Empty);
        if(Empty == 1'b0 || Data_out != 4'd15) failed = 1;

        $display("Popping ....");
        make_a_pop();
		  #1;
        $display("Data_out = %0d", Data_out);
        $display("Empty = %0d\n", Empty);
        if(Empty == 1'b0 || Data_out != 4'd13) failed = 1;

        $display("Popping ....");
        make_a_pop();
		  #1;
        $display("Data_out = %0d", Data_out);
        $display("Empty = %0d\n", Empty);
        if(Empty == 1'b0 || Data_out != 4'd11) failed = 1;

        $display("Popping ....");
        make_a_pop();
		  #1;
        $display("Data_out = %0d", Data_out);
        $display("Empty = %0d\n", Empty);
        if(Empty == 1'b0 || Data_out != 4'd9) failed = 1;

        $display("Popping ....");
        make_a_pop();
		  #1;
        $display("Data_out = %0d", Data_out);
        $display("Empty = %0d\n", Empty);
        if(Empty == 1'b0 || Data_out != 4'd7) failed = 1;

        $display("Popping ....");
        make_a_pop();
		  #1;
        $display("Data_out = %0d", Data_out);
        $display("Empty = %0d\n", Empty);
        if(Empty == 1'b0 || Data_out != 4'd5) failed = 1;

        $display("Popping ....");
        make_a_pop();
		  #1;
        $display("Data_out = %0d", Data_out);
        $display("Empty = %0d\n", Empty);
        if(Empty == 1'b0 || Data_out != 4'd3) failed = 1;

        $display("Popping...");
        $display("now you should make Empty zero");
        make_a_pop();
		  #1;
        $display("Data_out = %0d", Data_out);
        $display("Empty = %0d\n", Empty);
        if(Empty == 1'b1 || Data_out != 4'd1) failed = 1;

        if(!failed) $display("Passed the 8 push -> pop test!");
        else $display("Failed the 8 push -> pop test!");
        $display("-----------------------------------");
        $display("popping one time more!");
        make_a_pop();
		  #1;
        $display("Data out = %0d", Data_out);
        if(Data_out == 4'd1) $display("Passed! the extra Pop didn't affect!");
        else $display("Failed! the extra pop affected the stack!");
		  //-----------------------------------------------------------------------------------
        $display("-----------------------------------");
        failed = 0;
        $display("Random Push and pop test...\n");
        $display("Pushing 8...");
        make_a_push(4'd8);

        $display("Pushing 10...");
        make_a_push(10);

        $display("Pushing 12...");
        make_a_push(12);

        $display("Pushing 5...");
        make_a_push(5);

        $display("Popping...");
        make_a_pop();
		  #1;
        $display("Data_out = %0d\n", Data_out);
        if(Data_out != 4'd5) failed = 1;

        $display("Popping...");
        make_a_pop();
		  #1;
        $display("Data_out = %0d\n", Data_out);
        if(Data_out != 4'd12) failed = 1;

        $display("Pushing 14...");
        make_a_push(14);

        $display("Popping...");
        make_a_pop();
		  #1;
        $display("Data_out = %0d\n", Data_out);
        if(Data_out != 4'd14) failed = 1;

        $display("Popping...");
        make_a_pop();
		  #1;
        $display("Data_out = %0d\n", Data_out);
        if(Data_out != 4'd10) failed = 1;

        $display("Pushing 13...");
        make_a_push(13);

        $display("Popping...");
        make_a_pop();
		  #1;
        $display("D_out = %0d\n", Data_out);
        if(Data_out != 4'd13) failed = 1;

        $display("Popping...");
        make_a_pop();
		  #1;
        $display("D_out = %0d\n",Data_out);
        if(Data_out != 4'd8) failed = 1;


        $display("Empty = %0d", Empty);
        if(Empty != 1'd0) failed = 1;

        if(!failed) $display("random push-pop test was successful!");
        else $display("random push-pop test Failed!");
      
        $finish();
    end

endmodule
