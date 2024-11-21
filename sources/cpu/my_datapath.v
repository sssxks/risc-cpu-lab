`include "header.vh"
`include "vga_macro.vh"

module my_datapath (
    input wire clk,
    input wire rst,

    input wire [31:0] inst_field, // 32-bit instruction
    input wire [31:0] Data_in, // 32-bit data from data memory

    input wire [2:0] ALU_Control, // ALU control signals
    input wire [1:0] ImmSel, // select signal to immgen. i-type / s-type / sb-type / uj-type
    input wire [1:0] MemtoReg, // mem2reg(load) / alu2reg(R-type) / PC+4 (jalr)
    input wire ALUSrc_B, // 0: rs2, 1: imm
    input wire Jump, // unconditional jump instruction
    input wire Branch, // conditional jump instruction
    input wire RegWrite, // 1: write to register
    
    output wire [31:0] PC_out, // current PC to instruction memory
    output wire [31:0] Data_out, // 32-bit data to data memory
    output wire [31:0] ALU_out, // 32-bit ALU output (for debugging)
    `RegFile_Regs_output
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
    reg [31:0] reg_write_data;
    Regs Regs(
        .clk(clk),
        .rst(rst),
        
        .RegWrite(RegWrite),
        
        .Rs1_addr(inst_field[19:15]),
        .Rs2_addr(inst_field[24:20]),
        .Wt_addr(inst_field[11:7]),

        .Wt_data(reg_write_data),
        .Rs1_data(rs1_data),
        .Rs2_data(rs2_data),
        `RegFile_Regs_Arguments
    );

    // ALU
    wire [31:0] imm_out;
    my_immgen immgen(
        .ImmSel(ImmSel), // type of the instruction
        .instr(inst_field), // raw instruction
        .imm_out(imm_out) // 32 bit immediate value
    );

    wire zero;
    my_ALU ALU (
        .A(rs1_data),
        .ALU_operation(ALU_Control),
        .B(ALUSrc_B ? imm_out : rs2_data),
        .res(ALU_out),
        .zero(zero)
    );

    wire [31:0] PC_incr = PC_out + 4;
    wire [31:0] PC_offset = PC_out + imm_out;

    always @(*) begin
        case (MemtoReg)
            2'd0: reg_write_data = ALU_out;
            2'd1: reg_write_data = Data_in;
            2'd2: reg_write_data = PC_incr;
            default: reg_write_data = 32'bx;
        endcase
    end

    assign Data_out = rs2_data; // sw rs2, 123(rs1): reg[rs2] -> mem[rs1 + 123]

    assign pc_next = Jump || (Branch && zero) ? PC_offset : PC_incr;
endmodule