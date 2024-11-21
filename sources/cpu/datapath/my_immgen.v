`default_nettype none
`timescale 1ns/1ps

module my_immgen(
    input wire [1:0] ImmSel,
    input wire [31:0] instr, // raw instruction
    output reg [31:0] imm_out
);
    always @(*) begin
        case(ImmSel)
            2'b00:imm_out = {{20{instr[31]}},instr[31:20]}; //addi\lw(I) i type
            2'b01:imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]}; //sw(s) s type
            2'b10:imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0}; //beq(b) sb type
            2'b11:imm_out = {instr[31], instr[19:12], instr[20], instr[30:21], 1'b0}; //jal(j) uj type
        // u type handled manually
        endcase
    end
    // always @(*) begin
    //     case (instr[6:0])
    //         7'b0010011, 7'b0000011, 7'b1100111: // I-type
    //             imm_out = {{20{instr[31]}}, instr[31:20]};
    //         7'b0100011: // S-type
    //             imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
    //         7'b1100011: // B-type
    //             imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
    //         7'b0110111, 7'b0010111: // U-type
    //             imm_out = {instr[31:12], 12'b0};
    //         7'b1101111: // J-type
    //             imm_out = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
    //         default:
    //             imm_out = 32'b0;
    //     endcase
    // end
endmodule