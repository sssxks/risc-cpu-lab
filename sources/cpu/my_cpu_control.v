`timescale 1ns / 1ps
`default_nettype none

module my_cpu_control(
    // from instruction
    input wire [4:0]OPcode, // instruction[6:2]
    input wire [2:0]Fun3, // instruction[12:14]
    input wire Fun7, // instruction[30]

    input wire MIO_ready, 

    // signals to datapath
    output reg [1:0]ImmSel,
    output reg ALUSrc_B,
    output reg [1:0]MemtoReg,
    output reg Jump,
    output reg Branch,
    output reg RegWrite,
    output reg MemRW,
    output reg CPU_MIO,
    output reg [2:0]ALU_Control
);
    always @(*) begin
        CPU_MIO = 1'b1;
        case (OPcode)
            5'b01100: begin // R-type
                ImmSel = 2'bxx; // doesn't matter
                ALUSrc_B = 1'b0; // rs2
                MemtoReg = 2'b00; // alu result
                Jump = 1'b0;
                Branch = 1'b0;
                RegWrite = 1'b1;
                MemRW = 1'b0;

                case ({Fun7, Fun3})
                    4'b0_000: ALU_Control = 3'b010; // ADD
                    4'b1_000: ALU_Control = 3'b110; // SUB
                    4'b0_001: ALU_Control = 3'b001; // SLL // TODO no sll
                    4'b0_010: ALU_Control = 3'b111; // SLT
                    4'b0_011: ALU_Control = 3'b011; // SLTU
                    4'b0_100: ALU_Control = 3'b000; // XOR
                    4'b0_101: ALU_Control = 3'b101; // SRL
                    4'b1_101: ALU_Control = 3'b100; // SRA
                    4'b0_110: ALU_Control = 3'b100; // OR
                    4'b0_111: ALU_Control = 3'b111; // AND
                    default: ALU_Control = 3'bxxx; // Undefined
                endcase
            end
            5'b00100: begin // I-type w/o load, jalr
                ImmSel = 2'b00;
                ALUSrc_B = 1'b1;
                MemtoReg = 2'b00;
                Jump = 1'b0;
                Branch = 1'b0;
                RegWrite = 1'b1;
                MemRW = 1'b0;

                case (Fun3)
                    3'b000: ALU_Control = 3'b010; // ADDI
                    3'b010: ALU_Control = 3'b111; // SLTI
                    3'b011: ALU_Control = 3'b011; // SLTIU
                    3'b100: ALU_Control = 3'b000; // XORI
                    3'b110: ALU_Control = 3'b100; // ORI
                    3'b111: ALU_Control = 3'b111; // ANDI
                    3'b001: ALU_Control = 3'b001; // SLLI
                    // shift right arithematic & shift right arithematic uses additional
                    // func6 in the immediate part (special case of I type)
                    3'b101: ALU_Control = Fun7 ? 3'b100 : 3'b101; // SRAI/SRLI
                    default: ALU_Control = 3'bxxx; // Undefined
                endcase
            end
            5'b00000: begin // I-type Load
                ImmSel = 2'b00;
                ALUSrc_B = 1'b1;
                MemtoReg = 2'b01;
                Jump = 1'b0;
                Branch = 1'b0;
                RegWrite = 1'b1;
                MemRW = 1'b0;

                ALU_Control = 3'b010; // ADD
            end
            5'b01000: begin // S-type (store)
                ImmSel = 2'b01;
                ALUSrc_B = 1'b1;
                MemtoReg = 2'b00;
                Jump = 1'b0;
                Branch = 1'b0;
                RegWrite = 1'b0;
                MemRW = 1'b1;

                ALU_Control = 3'b010; // ADD
            end
            5'b11000: begin // SB-type branch
                ImmSel = 2'b10;
                ALUSrc_B = 1'b0;
                MemtoReg = 2'b00;
                Jump = 1'b0;
                Branch = 1'b1;
                RegWrite = 1'b0;
                MemRW = 1'b0;

                case (Fun3)
                    3'b000: ALU_Control = 3'b110; // BEQ
                    3'b001: ALU_Control = 3'b110; // BNE
                    3'b100: ALU_Control = 3'b111; // BLT
                    3'b101: ALU_Control = 3'b111; // BGE
                    3'b110: ALU_Control = 3'b011; // BLTU
                    3'b111: ALU_Control = 3'b011; // BGEU
                    default: ALU_Control = 3'bxxx; // Undefined
                endcase
            end
            5'b11011: begin // UJ-type JAL
                ImmSel = 2'b11;
                ALUSrc_B = 1'b0;
                MemtoReg = 2'b10;
                Jump = 1'b1;
                Branch = 1'b0;
                RegWrite = 1'b1;
                MemRW = 1'b0;

                ALU_Control = 3'bxxx; // Undefined
            end
            5'b11001: begin // I-type: JALR
                ImmSel = 2'b01; // i type
                ALUSrc_B = 1'b1;
                MemtoReg = 2'b10;
                Jump = 1'b1;
                Branch = 1'b0;
                RegWrite = 1'b1;
                MemRW = 1'b0;

                ALU_Control = 3'b010; // ADD
            end
            default: begin
                ImmSel = 2'bxx;
                ALUSrc_B = 1'bx;
                MemtoReg = 2'bxx;
                Jump = 1'bx;
                Branch = 1'bx;
                RegWrite = 1'bx;
                MemRW = 1'bx;

                ALU_Control = 3'bxxx;
            end
        endcase
    end
endmodule
