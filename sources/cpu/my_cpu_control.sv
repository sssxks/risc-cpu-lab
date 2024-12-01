`include "header.sv"

module my_cpu_control(
    // from instruction
    input wire [4:0] OPcode, // instruction[6:2]
    input wire [2:0] Fun3, // instruction[12:14]
    input wire Fun7, // instruction[30]

    // signals to datapath
    output reg [2:0]ImmSel,
    output reg ALUSrc_B,
    output reg [1:0]MemtoReg,
    output reg RegWrite,

    output reg Jump,
    output reg Branch,
    output reg InverseBranch,
    output reg PCOffset,
    
    output reg MemRW,
    output reg [2:0] RWType,
    
    output reg [3:0] ALU_Control
);
    always @(*) begin
        case (OPcode)
            `OPCODE_R_TYPE: begin
                ImmSel = 3'bxxx; // doesn't matter
                ALUSrc_B = 1'b0; // rs2
                MemtoReg = 2'd0; // alu result
                
                Jump = 1'b0;
                Branch = 1'b0;
                // the following doesn't matter
                InverseBranch = 1'bx;
                PCOffset = 1'bx; 

                RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                ALU_Control = {Fun7, Fun3};
            end
            `OPCODE_IMMEDIATE_CALCULATION: begin
                ImmSel = `IMMGEN_I;
                ALUSrc_B = 1'b1;
                MemtoReg = 2'd0;

                Jump = 1'b0;
                Branch = 1'b0;
                // the following doesn't matter
                InverseBranch = 1'bx;
                PCOffset = 1'bx; 

                RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                // I type format doesn't have Fun7
                // but shift right logical & shift right arithmatic 
                // has additional Fun6 as a special case of I type format
                ALU_Control = {Fun3 == `FUN3_SR ? Fun7 : 1'b0, Fun3};
            end
            `OPCODE_LOAD: begin
                ImmSel = `IMMGEN_I;
                ALUSrc_B = 1'b1;
                MemtoReg = 2'd1;

                Jump = 1'b0;
                Branch = 1'b0;
                // the following doesn't matter
                InverseBranch = 1'bx;
                PCOffset = 1'bx; 
                
                RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = Fun3;

                ALU_Control = `ALU_ADD;
            end
            `OPCODE_JALR: begin
                ImmSel = `IMMGEN_I; // i type
                ALUSrc_B = 1'b1;
                MemtoReg = 2'd2;

                Jump = 1'b1;
                Branch = 1'b0;
                InverseBranch = 1'bx;
                PCOffset = 1'b1;
                
                RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                ALU_Control = `ALU_ADD; // ADD
            end
            `OPCODE_S_TYPE: begin
                ImmSel = `IMMGEN_S;
                ALUSrc_B = 1'b1;
                MemtoReg = 2'd0;
                
                Jump = 1'b0;
                Branch = 1'b0;
                // the following doesn't matter
                InverseBranch = 1'bx;
                PCOffset = 1'bx; 
                
                RegWrite = 1'b0;

                MemRW = 1'b1;
                RWType = Fun3;

                ALU_Control = `ALU_ADD; // ADD
            end
            `OPCODE_SB_TYPE: begin // SB-type branch
                ImmSel = `IMMGEN_SB;
                ALUSrc_B = 1'b0;
                MemtoReg = 2'd0; // ALU result
                
                Jump = 1'b0;
                Branch = 1'b1;
                InverseBranch = Fun3[0]; // NE, GE, GEU
                PCOffset = 1'b0; 
                
                RegWrite = 1'b0;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

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
                ImmSel = `IMMGEN_UJ;
                ALUSrc_B = 1'bx; // doesn't matter
                MemtoReg = 2'd2; // PC + 4

                Jump = 1'b1;
                Branch = 1'b0;
                InverseBranch = 1'bx; // doesn't matter
                PCOffset = 1'b0; 
                
                RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                // this instruction doesn't use ALU
                ALU_Control = 4'bxxxx; // Undefined
            end
            `OPCODE_LUI: begin // LUI
                ImmSel = `IMMGEN_U;
                ALUSrc_B = 1'bx;
                MemtoReg = 2'd3;

                Jump = 1'b0;
                Branch = 1'b0;
                InverseBranch = 1'bx; // doesn't matter
                PCOffset = 1'b0; 

                RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                // this instruction doesn't use ALU
                ALU_Control = 4'bxxxx; // Undefined
            end
            `OPCODE_AUIPC: begin // AUIPC
                ImmSel = `IMMGEN_U;
                ALUSrc_B = 1'bx;
                MemtoReg = 2'd3;

                Jump = 1'b0;
                Branch = 1'b0;
                InverseBranch = 1'bx; // doesn't matter
                PCOffset = 1'b0;
                
                RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                // this instruction doesn't use ALU
                ALU_Control = 4'bxxxx; // Undefined
            end
            default: begin // should ignore, but for now, just set to undefined
                ImmSel = 3'bxxx;
                ALUSrc_B = 1'bx;
                MemtoReg = 2'bxx;

                Jump = 1'bx;
                Branch = 1'bx;
                InverseBranch = 1'bx; // doesn't matter
                PCOffset = 1'bx; 

                RegWrite = 1'bx;

                MemRW = 1'bx;
                RWType = 3'bxxx; // doesn't matter

                ALU_Control = 4'bxxxx;
            end
        endcase
    end
endmodule
