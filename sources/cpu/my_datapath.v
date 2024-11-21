`timescale 1ns / 1ps
`default_nettype none

module my_datapath (
    input wire clk,
    input wire rst,

    input wire [31:0] inst_field, // 32-bit instruction
    input wire [31:0] Data_in, // 32-bit data from data memory

    input wire [2:0] ALU_Control, // ALU control signals
    input wire [1:0] ImmSel, // TODO
    input wire [1:0] MemtoReg, // mem2reg(load) / alu2reg(R-type)
    input wire ALUSrc_B, // 0: rs2, 1: imm
    input wire Jump, // TODO
    input wire Branch, // Branch instruction
    input wire RegWrite, // 1: write to register
    
    output wire [31:0] PC_out, // current PC to instruction memory
    output wire [31:0] Data_out, // 32-bit data to data memory
    output wire [31:0] ALU_out // 32-bit ALU output (for debugging)
);
    // PC
    wire [31:0] pc_next;
    my_PC PC (
        .clk(clk),
        .rst(rst),

        .pc_in(pc_next),
        .pc_out(PC_out)
    );
    
    // Register File
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    Regs Regs (
        .clk(clk),
        .rst(rst),
        
        .RegWrite(RegWrite),
        
        .Rs1_addr(inst_field[19:15]),
        .Rs2_addr(inst_field[24:20]),
        .Wt_addr(inst_field[11:7]),

        .Wt_data(ALU_out),
        .Rs1_data(rs1_data),
        .Rs2_data(rs2_data)
    );

    // ALU
    wire [31:0] imm_out;
    my_immgen immgen(
        .ImmSel(ImmSel), // type of the instruction
        .instr(inst_field), // raw instruction
        .imm_out(imm_out) // 32 bit immediate value
    );

    wire [31:0] alu_input_B = ALUSrc_B ? imm_out : rs2_data;
    wire zero;
    my_ALU ALU (
        .A(rs1_data),
        .ALU_operation(ALU_Control),
        .B(alu_input_B),
        .res(ALU_out),
        .zero(zero)
    );

    assign pc_next = Jump || (Branch && zero) ? PC_out + imm_out : PC_out + 4;
endmodule