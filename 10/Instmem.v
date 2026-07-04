module Instmem (
    input [4:0] PC,
    output reg [11:0] instruction
);
    always @(*) begin
        case (PC)
            5'd0: instruction <= 12'h1F8; //PUSHM F8 (X is stored in address F8 of memory)
            5'd1: instruction <= 12'h000; //PUSHC 0 (preparing to add X with zero to have sign of X in flag S)
            5'd2: instruction <= 12'h600; //ADD (now X is at the top of the stack and its sign is stored in S)
            5'd3: instruction <= 12'h01A; //PUSHC 26 (if error we should jump to error handling address)
            5'd4: instruction <= 12'h500; //JS (if X is negative, jump to address for error handling)
            5'd5: instruction <= 12'h400; //JZ (also, if X is zero, jump to address for error handling)
            5'd6: instruction <= 12'h2F0; //If X is positive, we don't jump, this will be executed and X will be at the top of the stack again
            5'd7: instruction <= 12'h017; //PUSHC 23
            5'd8: instruction <= 12'h600; //ADD
            5'd9: instruction <= 12'h01A; // PUSHC 26 (if X + 23 is out of range, we should jump to error, so we should place error handling address at the top of the stack)
            5'd10: instruction <= 12'h500; //JS (jump if overflow occured in the addition X+23)
            5'd11: instruction <= 12'h2F0; //POP (Pop the error handling address so that X+23 become the top)
            5'd12: instruction <= 12'h1F8; //PUSHM X (now, we know X is non-negative)
            5'd13: instruction <= 12'h017; //PUSHC 23
            5'd14: instruction <= 12'h600; //ADD (now, we know X+23 doesn't overflow)
            5'd15: instruction <= 12'h0F4; //PUSHC -12 (first, we want to add -12 to X+23)
            5'd16: instruction <= 12'h600; //ADD (computes (X+23) + (-12) that now, we know doesn't cause an overflow)
            5'd17: instruction <= 12'h600; //ADD (computes Y = 2*(X+23) - 12)
            5'd18: instruction <= 12'h01A; //PUSHC 26 (if error we should jump to error handling address)
            5'd19: instruction <= 12'h500; //JS (if computing the result caused an overflow, jump to address for error handling)
            5'd20: instruction <= 12'h2F0; //POP (POP the error handling address)
            5'd21: instruction <= 12'h2FE; //POP (POP the result into the Memory cell allocated for the result)
            5'd22: instruction <= 12'h000; //PUSHC 0 (the return value)
            5'd23: instruction <= 12'h2FF; //POP (store the return value to the location allocated for the return vlue)
            5'd24: instruction <= 12'h01C; //PUSHC 28 (preparing to JUMP to finish)
            5'd25: instruction <= 12'h300; //JUMP to finish
            //---------------------------------------------ERROR--------------------------------
            5'd26: instruction <= 12'h001; //PUSHC 1 (the return value)
            5'd27: instruction <= 12'h2FF; //store the return value
            //---------------------------------------------FINISHED-----------------------------
            5'd28: instruction <= 12'h01C; //PUSHC28;
            5'd29: instruction <= 12'h300; //with this, we create an infinite loop, preventing PC from overflow and doing the function again.
            default:
                instruction <= 12'hF00;
        endcase
    end
endmodule