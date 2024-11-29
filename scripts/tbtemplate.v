`include "header.vh"
`include "debug.vh"
`include "vga_macro.vh"

module my_cpu_control_tb();
    reg [31:0] inst;
    reg MIO_ready;
    
    wire [1:0] ImmSel;
    wire ALUSrc_B;
    wire [1:0] MemtoReg;
    wire Jump;
    wire Branch;
    wire InverseBranch;
    wire RegWrite;
    wire MemRW;
    wire [2:0] ALU_Control;
    wire CPU_MIO;

    my_cpu_control ctl_unit(
        .OPcode(inst[6:2]),
        .Fun3(inst[14:12]),
        .Fun7(inst[30]),
        .MIO_ready(MIO_ready),
        .ImmSel(ImmSel),
        .ALUSrc_B(ALUSrc_B),
        .MemtoReg(MemtoReg),
        .Jump(Jump),
        .Branch(Branch),
        .InverseBranch(InverseBranch),
        .RegWrite(RegWrite),
        .MemRW(MemRW),
        .ALU_Control(ALU_Control),
        .CPU_MIO(CPU_MIO)
    );

    initial begin
        {testcases}
        $stop();
    end
endmodule
