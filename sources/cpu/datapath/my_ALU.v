`include "header.vh"

// this is behavioral model of ALU
// not very efficient, but it's easy to maintain
module my_ALU(
    input wire [31:0] A,
    input wire [3:0] ALU_operation,
    input wire [31:0] B,
    output reg [31:0] result,
    output wire zero
);
    always @(*) begin
        case (ALU_operation)
            `ALU_ADD : result = A + B;                                    // ADD
            `ALU_SUB : result = A - B;                                    // SUB
            `ALU_SLL : result = A << B[5:0];                              // SLL
            `ALU_SLT : result = ($signed(A) < $signed(B)) ? 32'b1 : 32'b0;// SLT
            `ALU_SLTU: result = (A < B) ? 32'b1 : 32'b0;                  // SLTU
            `ALU_XOR : result = A ^ B;                                    // XOR
            `ALU_SRL : result = A >> B[5:0];                              // SRL
            `ALU_SRA : result = $signed(A) >>> B[5:0];                    // SRA
            `ALU_OR  : result = A | B;                                    // OR
            `ALU_AND : result = A & B;                                    // AND
        endcase
    end

    assign zero = (result == 32'b0);

endmodule
