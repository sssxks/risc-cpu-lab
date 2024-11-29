// Generated on 2024-11-21 15:05:32
// WARNING: Do not modify this file. It is auto-generated.
`include "header.vh"
`include "debug.vh"

module my_cpu_control_tb();
    reg [31:0] inst;
    reg MIO_ready;
    
    wire [1:0] ImmSel;
    wire ALUSrc_B;
    wire [1:0] MemtoReg;
    wire Jump;
    wire Branch;
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
        .RegWrite(RegWrite),
        .MemRW(MemRW),
        .ALU_Control(ALU_Control),
        .CPU_MIO(CPU_MIO)
    );

    initial begin
        
        // add x1, x2, x3
        inst = 32'h003100B3;
        MIO_ready = 1'b1;
        #5;
        `assert(ImmSel, 2'bxx);
        `assert(ALUSrc_B, 1'b0);
        `assert(MemtoReg, 2'b00);
        `assert(Jump, 1'b0);
        `assert(Branch, 1'b0);
        `assert(RegWrite, 1'b1);
        `assert(MemRW, 1'b0);
        `assert(ALU_Control, 3'b010);
        `assert(CPU_MIO, 1'b0);
        #5;


        // addi x2, x1, 1
        inst = 32'h00108113;
        MIO_ready = 1'b1;
        #5;
        `assert(ImmSel, 2'b00);
        `assert(ALUSrc_B, 1'b1);
        `assert(MemtoReg, 2'b00);
        `assert(Jump, 1'b0);
        `assert(Branch, 1'b0);
        `assert(RegWrite, 1'b1);
        `assert(MemRW, 1'b0);
        `assert(ALU_Control, 3'b010);
        `assert(CPU_MIO, 1'b0);
        #5;


        // lw x2, 0(x1)
        inst = 32'h0000A103;
        MIO_ready = 1'b1;
        #5;
        `assert(ImmSel, 2'b00);
        `assert(ALUSrc_B, 1'b1);
        `assert(MemtoReg, 2'b01);
        `assert(Jump, 1'b0);
        `assert(Branch, 1'b0);
        `assert(RegWrite, 1'b1);
        `assert(MemRW, 1'b0);
        `assert(ALU_Control, 3'b010);
        `assert(CPU_MIO, 1'b1);
        #5;


        // sw x2, 0(x1)
        inst = 32'h0020A023;
        MIO_ready = 1'b1;
        #5;
        `assert(ImmSel, 2'b01);
        `assert(ALUSrc_B, 1'b1);
        `assert(MemtoReg, 2'b00);
        `assert(Jump, 1'b0);
        `assert(Branch, 1'b0);
        `assert(RegWrite, 1'b0);
        `assert(MemRW, 1'b1);
        `assert(ALU_Control, 3'b010);
        `assert(CPU_MIO, 1'b1);
        #5;


        // beq x5, x6, -8
        inst = 32'hFE628CE3;
        MIO_ready = 1'b1;
        #5;
        `assert(ImmSel, 2'b10);
        `assert(ALUSrc_B, 1'b0);
        `assert(MemtoReg, 2'b00);
        `assert(Jump, 1'b0);
        `assert(Branch, 1'b1);
        `assert(RegWrite, 1'b0);
        `assert(MemRW, 1'b0);
        `assert(ALU_Control, 3'b110);
        `assert(CPU_MIO, 1'b0);
        #5;


        // jalr x1, x5, 100
        inst = 32'h064280E7;
        MIO_ready = 1'b1;
        #5;
        `assert(ImmSel, 2'b01);
        `assert(ALUSrc_B, 1'b1);
        `assert(MemtoReg, 2'b10);
        `assert(Jump, 1'b1);
        `assert(Branch, 1'b0);
        `assert(RegWrite, 1'b1);
        `assert(MemRW, 1'b0);
        `assert(ALU_Control, 3'b010);
        `assert(CPU_MIO, 1'b0);
        #5;

        $stop();
    end
endmodule
