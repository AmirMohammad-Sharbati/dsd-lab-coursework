module Uart (
    input wire RstN,
    input wire clk,
    input wire start_send,
    input wire [6:0] data_to_send,
    input wire bit_in,
    output wire sending_bit,
    output wire [7:0] received_data,
    output wire receiver_done,
    output wire sender_done,
    output wire is_parity_valid
);

reg generated_clock = 0;
reg [9:0] counter = 10'd0;

always @(posedge clk) begin
    if(counter < 217) begin
        counter <= counter + 1;
    end else begin
        counter <= 10'd 0;
        generated_clock <= ~generated_clock;
    end
end


sender uart_sender(
    .RstN(RstN),
    .clk(generated_clock),
    .start(start_send),
    .data_to_send(data_to_send),
    .placing_bit(sending_bit),
    .done(sender_done)
);

receiver uart_receiver(
    .clk(generated_clock),
    .RstN(RstN),
    .bit_in(bit_in),
    .data_with_parity(received_data),
    .is_parity_correct(is_parity_valid),
    .done(receiver_done)
);
endmodule