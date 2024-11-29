`include "header.vh"

module my_cpu_control(
    // from instruction
    input wire [4:0] OPcode, // instruction[6:2]
    input wire [2:0] Fun3, // instruction[12:14]
    input wire Fun7, // instruction[30]

    input wire MIO_ready, 
    output wire CPU_MIO,

    // signals to datapath
    output reg [1:0]ImmSel,
    output reg ALUSrc_B,
    output reg [1:0]MemtoReg,
    output reg Jump,
    output reg Branch,
    output reg InverseBranch,
    output reg RegWrite,
    output reg MemRW,
    output reg [3:0]ALU_Control
);
    assign CPU_MIO = 1'b1; // not used so far

    always @(*) begin
        case (OPcode)
            `OPCODE_R_TYPE: begin
                ImmSel = 2'bxx; // doesn't matter
                ALUSrc_B = 1'b0; // rs2
                MemtoReg = 2'b00; // alu result
                Jump = 1'b0;
                Branch = 1'b0;
                RegWrite = 1'b1;
                MemRW = 1'b0;
                InverseBranch = 1'bx; // doesn't matter

                ALU_Control = {Fun7, Fun3};
            end
            `OPCODE_IMMEDIATE_CALCULATION: begin
                ImmSel = 2'b00;
                ALUSrc_B = 1'b1;
                MemtoReg = 2'b00;
                Jump = 1'b0;
                Branch = 1'b0;
                RegWrite = 1'b1;
                MemRW = 1'b0;
                InverseBranch = 1'bx; // doesn't matter

                // I type format doesn't have Fun7
                // but shift right logical & shift right arithmatic 
                // has additional Fun6 as a special case of I type format
                ALU_Control = {Fun3 == `FUN3_SR ? Fun7 : 0, Fun3};
            end
            `OPCODE_LOAD: begin
                ImmSel = 2'b00;
                ALUSrc_B = 1'b1;
                MemtoReg = 2'b01;
                Jump = 1'b0;
                Branch = 1'b0;
                RegWrite = 1'b1;
                MemRW = 1'b0;
                InverseBranch = 1'bx; // doesn't matter


                ALU_Control = `ALU_ADD;

                // right now, only support lw
                // case (Fun3)
                //     FUN3_LW:
                //     FUN3_LH:
                //     FUN3_LHU
                //     FUN3_LB: 
                //     FUN3_LBU:
                //     default: 
                // endcase
            end
            `OPCODE_JALR: begin
                ImmSel = 2'b01; // i type
                ALUSrc_B = 1'b1;
                MemtoReg = 2'b10;
                Jump = 1'b1;
                Branch = 1'b0;
                RegWrite = 1'b1;
                MemRW = 1'b0;
                InverseBranch = 1'bx; // doesn't matter

                ALU_Control = `ALU_ADD; // ADD
            end
            `OPCODE_S_TYPE: begin
                ImmSel = 2'b01;
                ALUSrc_B = 1'b1;
                MemtoReg = 2'b00;
                Jump = 1'b0;
                Branch = 1'b0;
                RegWrite = 1'b0;
                MemRW = 1'b1;
                InverseBranch = 1'bx; // doesn't matter

                ALU_Control = `ALU_ADD; // ADD

                // right now, only support sw
                // case (Fun3)
                //     FUN3_SW:
                //     FUN3_SH:
                //     FUN3_SB:
                //     default: 
                // endcase
            end
            `OPCODE_SB_TYPE: begin // SB-type branch
                ImmSel = 2'b10;
                ALUSrc_B = 1'b0;
                MemtoReg = 2'b00;
                Jump = 1'b0;
                Branch = 1'b1;
                RegWrite = 1'b0;
                MemRW = 1'b0;
                InverseBranch = Fun3[0]; // NE, GE, GEU

                case (Fun3)
                    `FUN3_BEQ: ALU_Control = `ALU_EQ;
                    `FUN3_BNE: ALU_Control = `ALU_NE;
                    `FUN3_BLT: ALU_Control = `ALU_LT;
                    `FUN3_BGE: ALU_Control = `ALU_GE;
                    `FUN3_BLTU: ALU_Control = `ALU_LTU;
                    `FUN3_BGEU: ALU_Control = `ALU_GEU;
                    default: ALU_Control = 4'bxxxx; // Undefined
                endcase
            end
            `OPCODE_UJ_TYPE: begin // UJ-type JAL
                ImmSel = 2'b11;
                ALUSrc_B = 1'b0;
                MemtoReg = 2'b10;
                Jump = 1'b1;
                Branch = 1'b0;
                RegWrite = 1'b1;
                MemRW = 1'b0;
                InverseBranch = 1'bx; // doesn't matter

                // this instruction doesn't use ALU
                ALU_Control = 4'bxxxx; // Undefined
            end
            default: begin // should ignore, but for now, just set to undefined
                ImmSel = 2'bxx;
                ALUSrc_B = 1'bx;
                MemtoReg = 2'bxx;
                Jump = 1'bx;
                Branch = 1'bx;
                RegWrite = 1'bx;
                MemRW = 1'bx;
                InverseBranch = 1'bx; // doesn't matter

                ALU_Control = 4'bxxxx;
            end
        endcase
    end
endmodule
