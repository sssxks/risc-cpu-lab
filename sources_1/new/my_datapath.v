`timescale 1ns / 1ps
`default_nettype none

module my_datapath (
    input wire clk,
    input wire rst,
    input wire [31:0]inst_field,
    input wire [31:0]Data_in,

    input wire [2:0]ALU_Control,
    input wire [1:0]ImmSel,
    input wire [1:0]MemtoReg,
    input wire ALUSrc_B,
    input wire Jump,
    input wire Branch,
    input wire RegWrite,
    
    output wire [31:0]PC_out,
    output wire [31:0]Data_out,
    output wire [31:0]ALU_out,
);

endmodule