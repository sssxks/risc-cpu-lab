`timescale 1ns / 1ps
`default_nettype none

module SCPU(
    input wire clk,          // Clock signal
    input wire rst,          // Reset signal

    input wire [31:0] inst_in, // Instruction input
    input wire [31:0] Data_in, // Data input from memory
    input wire MIO_ready,      // Memory I/O ready signal

    output wire MemRW,         // Memory read/write signal
    output wire CPU_MIO,       // CPU to Memory I/O signal
    output wire [31:0] Addr_out, // Address output to memory
    output wire [31:0] Data_out, // Data output to memory
    output wire [31:0] PC_out   // Program counter output
);

    // Control signals
    wire [1:0] ImmSel;         // Immediate selection
    wire ALUSrc_B;             // ALU source B selection
    wire [1:0] MemtoReg;       // Memory to register selection
    wire Jump;                 // Jump signal
    wire Branch;               // Branch signal
    wire RegWrite;             // Register write enable
    wire [2:0] ALU_Control;    // ALU control signals

    // Instantiate the control unit
    SCPU_ctrl control_unit (
        // from instruction
        .OPcode(inst_in[6:2]), // Opcode from instruction
        .Fun3(inst_in[14:12]), // Funct3 from instruction
        .Fun7(inst_in[30]),    // Funct7 from instruction
        
        // signals to datapath
        .MIO_ready(MIO_ready), // Memory I/O ready signal
        .ImmSel(ImmSel),       // Immediate selection
        .ALUSrc_B(ALUSrc_B),   // ALU source B selection
        .MemtoReg(MemtoReg),   // Memory to register selection
        .Jump(Jump),           // Jump signal
        .Branch(Branch),       // Branch signal
        .RegWrite(RegWrite),   // Register write enable
        .MemRW(MemRW),         // Memory read/write signal
        .ALU_Control(ALU_Control), // ALU control signals
        .CPU_MIO(CPU_MIO)      // CPU to Memory I/O signal
    );

    // Instantiate the data path
    my_datapath data_path (
        .clk(clk),             // Clock signal
        .rst(rst),             // Reset signal
        .inst_field(inst_in),  // Instruction input
        .Data_in(Data_in),     // Data input from memory
        
        .ALU_Control(ALU_Control), // ALU control signals
        .ImmSel(ImmSel),       // Immediate selection
        .MemtoReg(MemtoReg),   // Memory to register selection
        .ALUSrc_B(ALUSrc_B),   // ALU source B selection
        .Jump(Jump),           // Jump signal
        .Branch(Branch),       // Branch signal
        .RegWrite(RegWrite),   // Register write enable
        
        .PC_out(PC_out),       // Program counter output
        .Data_out(Data_out),   // Data output to memory
        .ALU_out(Addr_out)     // Address output to memory
    );

endmodule
