`include "cpu_control_signals.sv"
`include "header.sv"
`include "vga_macro.vh"

module my_datapath (
    input wire clk,
    input wire rst,

    input wire [31:0] inst_field, // 32-bit instruction
    input wire [31:0] Data_in, // 32-bit data from data memory
    
    cpu_control_signals.datapath signals_if,

    output wire [31:0] PC_out, // current PC to instruction memory
    output wire [31:0] Data_out, // 32-bit data to data memory
    output wire [31:0] Addr_out, // 32-bit address to data memory (ALU result)
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

        .RegWrite(signals_if.RegWrite),
        
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
        .ImmSel(signals_if.ImmSel), // type of the instruction
        .instr(inst_field), // raw instruction
        .imm_out(imm_out) // 32 bit immediate value
    );

    wire [31:0] ALU_out;
    wire zero;
    my_ALU ALU (
        .A(rs1_data),
        .ALU_operation(signals_if.ALU_Control),
        .B(signals_if.ALUSrc_B ? imm_out : rs2_data),
        .result(ALU_out),
        .zero(zero)
    );

    assign Addr_out = ALU_out;

    wire [31:0] PC_incr = PC_out + 4;
    wire [31:0] PC_offset = signals_if.PCOffset ? ALU_out : PC_out + imm_out; // for jalr

    always @(*) begin
        case (signals_if.MemtoReg)
            2'd0: reg_write_data = ALU_out;
            2'd1: reg_write_data = Data_in;
            2'd2: reg_write_data = signals_if.Jump ? PC_incr : PC_offset; // jump=1 -> jalr, jump=0 -> auipc
            2'd3: reg_write_data = imm_out;
            default: reg_write_data = 32'bx;
        endcase
    end

    assign Data_out = rs2_data; // sw rs2, 123(rs1): reg[rs2] -> mem[rs1 + 123]

    wire if_pc_target = signals_if.Jump || (signals_if.Branch && (signals_if.InverseBranch ? ~zero : zero));

    assign pc_next = if_pc_target ? PC_offset : PC_incr;
endmodule