`timescale 1ns / 1ps
`default_nettype none

module my_datapath (
    input wire clk,
    input wire rst,

    input wire [31:0] inst_field,
    input wire [31:0] Data_in,

    input wire [2:0] ALU_Control,
    input wire [1:0] ImmSel,
    input wire [1:0] MemtoReg,
    input wire ALUSrc_B,
    input wire Jump,
    input wire Branch,
    input wire RegWrite,
    
    output wire [31:0] PC_out,
    output wire [31:0] Data_out,
    output wire [31:0] ALU_out
);
    wire [31:0] pc_in;
    my_PC PC (
        .clk(clk),
        .reset(rst),
        .pc_in(pc_in), // TODO add pc_in
        .pc_out(PC_out)
    );
    
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    Regs Regs (
        .clk(clk),
        .rst(rst),
        .RegWrite(RegWrite),
        .Rs1_addr(), // TODO add Rs1_addr
        .Rs2_addr(), // TODO add Rs2_addr
        .Wt_addr(), // TODO add Wt_addr
        .Wt_data(), // TODO add Wt_data
        .Rs1_data(), // TODO add Rs1_data
        .Rs2_data() // TODO add Rs2_data
    );

    wire [31:0] alu_input_B = ALUSrc_B ? inst_field[19:15] : rs2_data; // TODO
    my_ALU ALU (
        .A(rs1_data),
        .ALU_operation(ALU_Control),
        .B(alu_input_B),
        .res(ALU_out),
        .zero()
    );

    assign pc_in = PC_out + 4;



endmodule