`include "header.sv"
`include "cpu_control_signals.sv"

module my_cpu_control(
    // from instruction
    input wire [4:0] OPcode, // instruction[6:2]
    input wire [2:0] Fun3, // instruction[12:14]
    input wire Fun7, // instruction[30]

    // signals to datapath
    cpu_control_signals.control_unit signals_if,
    
    output reg MemRW,
    output reg [2:0] RWType
    
);
    always @(*) begin
        case (OPcode)
            `OPCODE_R_TYPE: begin
                signals_if.ImmSel = 3'bxxx; // doesn't matter
                signals_if.ALUSrc_B = 1'b0; // rs2
                signals_if.MemtoReg = 2'd0; // alu result
                
                signals_if.Jump = 1'b0;
                signals_if.Branch = 1'b0;
                // the following doesn't matter
                signals_if.InverseBranch = 1'bx;
                signals_if.PCOffset = 1'bx; 

                signals_if.RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                signals_if.ALU_Control = {Fun7, Fun3};
            end
            `OPCODE_IMMEDIATE_CALCULATION: begin
                signals_if.ImmSel = `IMMGEN_I;
                signals_if.ALUSrc_B = 1'b1;
                signals_if.MemtoReg = 2'd0;

                signals_if.Jump = 1'b0;
                signals_if.Branch = 1'b0;
                // the following doesn't matter
                signals_if.InverseBranch = 1'bx;
                signals_if.PCOffset = 1'bx; 

                signals_if.RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                // I type format doesn't have Fun7
                // but shift right logical & shift right arithmatic 
                // has additional Fun6 as a special case of I type format
                signals_if.ALU_Control = {Fun3 == `FUN3_SR ? Fun7 : 1'b0, Fun3};
            end
            `OPCODE_LOAD: begin
                signals_if.ImmSel = `IMMGEN_I;
                signals_if.ALUSrc_B = 1'b1;
                signals_if.MemtoReg = 2'd1;

                signals_if.Jump = 1'b0;
                signals_if.Branch = 1'b0;
                // the following doesn't matter
                signals_if.InverseBranch = 1'bx;
                signals_if.PCOffset = 1'bx; 
                
                signals_if.RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = Fun3;

                signals_if.ALU_Control = `ALU_ADD;
            end
            `OPCODE_JALR: begin
                signals_if.ImmSel = `IMMGEN_I; // i type
                signals_if.ALUSrc_B = 1'b1;
                signals_if.MemtoReg = 2'd2;

                signals_if.Jump = 1'b1;
                signals_if.Branch = 1'b0;
                signals_if.InverseBranch = 1'bx;
                signals_if.PCOffset = 1'b1;
                
                signals_if.RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                signals_if.ALU_Control = `ALU_ADD; // ADD
            end
            `OPCODE_S_TYPE: begin
                signals_if.ImmSel = `IMMGEN_S;
                signals_if.ALUSrc_B = 1'b1;
                signals_if.MemtoReg = 2'd0;
                
                signals_if.Jump = 1'b0;
                signals_if.Branch = 1'b0;
                // the following doesn't matter
                signals_if.InverseBranch = 1'bx;
                signals_if.PCOffset = 1'bx; 
                
                signals_if.RegWrite = 1'b0;

                MemRW = 1'b1;
                RWType = Fun3;

                signals_if.ALU_Control = `ALU_ADD; // ADD
            end
            `OPCODE_SB_TYPE: begin // SB-type branch
                signals_if.ImmSel = `IMMGEN_SB;
                signals_if.ALUSrc_B = 1'b0;
                signals_if.MemtoReg = 2'd0; // ALU result
                
                signals_if.Jump = 1'b0;
                signals_if.Branch = 1'b1;
                signals_if.InverseBranch = Fun3[0]; // NE, GE, GEU
                signals_if.PCOffset = 1'b0; 
                
                signals_if.RegWrite = 1'b0;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                case (Fun3)
                    `FUN3_BEQ: signals_if.ALU_Control = `ALU_EQ;
                    `FUN3_BNE: signals_if.ALU_Control = `ALU_NE;
                    `FUN3_BLT: signals_if.ALU_Control = `ALU_LT;
                    `FUN3_BGE: signals_if.ALU_Control = `ALU_GE;
                    `FUN3_BLTU: signals_if.ALU_Control = `ALU_LTU;
                    `FUN3_BGEU: signals_if.ALU_Control = `ALU_GEU;
                    default: signals_if.ALU_Control = 4'bxxxx; // Undefined
                endcase
            end
            `OPCODE_UJ_TYPE: begin // UJ-type JAL
                signals_if.ImmSel = `IMMGEN_UJ;
                signals_if.ALUSrc_B = 1'bx; // doesn't matter
                signals_if.MemtoReg = 2'd2; // PC + 4

                signals_if.Jump = 1'b1;
                signals_if.Branch = 1'b0;
                signals_if.InverseBranch = 1'bx; // doesn't matter
                signals_if.PCOffset = 1'b0; 
                
                signals_if.RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                // this instruction doesn't use ALU
                signals_if.ALU_Control = 4'bxxxx; // Undefined
            end
            `OPCODE_LUI: begin // LUI
                signals_if.ImmSel = `IMMGEN_U;
                signals_if.ALUSrc_B = 1'bx;
                signals_if.MemtoReg = 2'd3;

                signals_if.Jump = 1'b0;
                signals_if.Branch = 1'b0;
                signals_if.InverseBranch = 1'bx; // doesn't matter
                signals_if.PCOffset = 1'b0; 

                signals_if.RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                // this instruction doesn't use ALU
                signals_if.ALU_Control = 4'bxxxx; // Undefined
            end
            `OPCODE_AUIPC: begin // AUIPC
                signals_if.ImmSel = `IMMGEN_U;
                signals_if.ALUSrc_B = 1'bx;
                signals_if.MemtoReg = 2'd3;

                signals_if.Jump = 1'b0;
                signals_if.Branch = 1'b0;
                signals_if.InverseBranch = 1'bx; // doesn't matter
                signals_if.PCOffset = 1'b0;
                
                signals_if.RegWrite = 1'b1;

                MemRW = 1'b0;
                RWType = 3'b000; // doesn't matter

                // this instruction doesn't use ALU
                signals_if.ALU_Control = 4'bxxxx; // Undefined
            end
            default: begin // should ignore, but for now, just set to undefined
                signals_if.ImmSel = 3'bxxx;
                signals_if.ALUSrc_B = 1'bx;
                signals_if.MemtoReg = 2'bxx;

                signals_if.Jump = 1'bx;
                signals_if.Branch = 1'bx;
                signals_if.InverseBranch = 1'bx; // doesn't matter
                signals_if.PCOffset = 1'bx; 

                signals_if.RegWrite = 1'bx;

                MemRW = 1'bx;
                RWType = 3'bxxx; // doesn't matter

                signals_if.ALU_Control = 4'bxxxx;
            end
        endcase
    end
endmodule
