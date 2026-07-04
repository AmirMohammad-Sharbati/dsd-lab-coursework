module tb;

    reg clk;
    reg RstN;


    reg start_A;
    reg [6:0] data_in_A;
    wire tx_A;          
    wire [7:0] data_out_A;
    wire rx_done_A;
    wire tx_done_A;
    wire parity_valid_A;

    reg start_B;
    reg [6:0] data_in_B;
    wire tx_B;      
    wire [7:0] data_out_B;
    wire rx_done_B;
    wire tx_done_B;
    wire parity_valid_B;

    initial begin
        clk = 0;
        forever #10 clk = ~clk; 
    end

    

    Uart uart_A (
        .clk(clk),
        .RstN(RstN),
        .start_send(start_A),
        .data_to_send(data_in_A),
        .bit_in(tx_B),        
        .sending_bit(tx_A),    
        .received_data(data_out_A),
        .receiver_done(rx_done_A),
        .sender_done(tx_done_A),
        .is_parity_valid(parity_valid_A)
    );


    Uart uart_B (
        .clk(clk),
        .RstN(RstN),
        .start_send(start_B),
        .data_to_send(data_in_B),
        .bit_in(tx_A),         
        .sending_bit(tx_B),     
        .received_data(data_out_B),
        .receiver_done(rx_done_B),
        .sender_done(tx_done_B),
        .is_parity_valid(parity_valid_B)
    );


    initial begin
  
        RstN = 0;
        start_A = 0;
        start_B = 0;
        data_in_A = 0;
        data_in_B = 0;

     
        #100;
        RstN = 1;
        #100;

 
        $display("Test 1: A is sending to B...");
        data_in_A = 7'b1101001; 
        

        start_A = 1;
        @(posedge uart_A.generated_clock); 
        @(posedge uart_A.generated_clock); 
        start_A = 0;

        $display("A started sending %b...", data_in_A);


        wait(rx_done_B == 1);
        
        #100; 

    
        if (data_out_B[6:0] === data_in_A)
            $display("SUCCESS: B received correct data: %b", data_out_B);
        else
            $display("FAILED: B received wrong data: %b", data_out_B);

        if (parity_valid_B)
            $display("Parity Check: OK");
        else
            $display("Parity Check: ERROR");
        
        $display("----------------------------------------");



        #2000;
        $display("Test2: A and B are sending to each other simulatniously");
        
        data_in_A = 7'b0001111; 
        data_in_B = 7'b1110000; 

      
        start_A = 1;
        start_B = 1;
        
        
        @(posedge uart_A.generated_clock);
        @(posedge uart_A.generated_clock);
        
        start_A = 0;
        start_B = 0;

        $display("Both UARTs started transmission...");

       
        fork
            wait(rx_done_A == 1);
            wait(rx_done_B == 1);
        join

        #100;

      
        if (data_out_A[6:0] === 7'b1110000)
            $display("SUCCESS: A received correct data from B: %b", data_out_A);
        else
            $display("FAILED: A data mismatch. Got: %b", data_out_A);

      
        if (data_out_B[6:0] === 7'b0001111)
            $display("SUCCESS: B received correct data from A: %b", data_out_B);
        else
            $display("FAILED: B data mismatch. Got: %b", data_out_B);

        #1000;
        $display("\nTestbench Completed.");
        $finish;
    end

endmodule