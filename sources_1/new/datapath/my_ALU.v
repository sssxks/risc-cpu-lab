`timescale 1ns / 1ps
`default_nettype none

module my_ALU(
    input [31:0] A,
    input [2:0] ALU_operation,
    input [31:0] B,
    output reg [31:0] res,  // Declare res as reg
    output reg zero         // Declare zero as reg
);
    always @ (*) begin
        case (ALU_operation)
            3'b000: res = A & B;  // and
            3'b001: res = A | B;  // or
            3'b010: res = A + B;  // add
            3'b011: res = A ^ B;  // xor
            3'b100: res = ~(A | B);  // nor
            3'b101: res = A >> B[4:0];  // srl (logical right shift)
            3'b110: res = A - B;  // sub
            3'b111: res = A < B;  // sltu
            default: res = 32'b0;  // Default case
        endcase
        
        zero = (res == 32'b0);  // Set zero flag if result is 0
    end
endmodule
