`timescale 1ns / 1ps
`default_nettype none

module my_cpu_control(
    // from instruction
    input wire [4:0]OPcode,
    input wire [2:0]Fun3,
    input wire Fun7,

    input wire MIO_ready,

    // signals to cpu
    output wire [1:0]ImmSel,
    output wire ALUSrc_B,
    output wire [1:0]MemtoReg,
    output wire Jump,
    output wire Branch,
    output wire RegWrite,
    output wire MemRW,
    output wire [2:0]ALU_Control,
    output wire CPU_MIO
);

endmodule
