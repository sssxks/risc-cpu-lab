`include "header.sv"
`include "vga_macro.vh"

module SCPU(
    input wire clk,          // Clock signal
    input wire rst,          // Reset signal

    input wire [31:0] inst_in, // Instruction input
    output wire [31:0] PC_out,   // Program counter output

    data_memory_face.cpu mem_if,

    `RegFile_Regs_output
);

    // Control signals
    wire [2:0] ImmSel;         // Immediate selection
    wire ALUSrc_B;             // ALU source B selection
    wire [1:0] MemtoReg;       // Memory to register selection
    wire Jump;                 // Jump signal
    wire Branch;               // Branch signal
    wire InverseBranch;        // Inverse branch signal
    wire PCOffset;             // Program counter offset
    wire RegWrite;             // Register write enable
    wire [3:0] ALU_Control;    // ALU control signals

    // Memory signals
    logic MemRW;
    logic [2:0] RWType;
    wire [31:0] Addr_out;      // Address output to memory
    wire [31:0] Data_out_raw;  // Data output to memory
    logic [31:0] Data_in;      // Data input from memory

    // Instantiate the control unit
    my_cpu_control control_unit (
        // from instruction
        .OPcode(inst_in[6:2]), // Opcode from instruction
        .Fun3(inst_in[14:12]), // Funct3 from instruction
        .Fun7(inst_in[30]),    // Funct7 from instruction
        
        // signals to datapath
        .ImmSel(ImmSel),       // Immediate selection
        .ALUSrc_B(ALUSrc_B),   // ALU source B selection
        .MemtoReg(MemtoReg),   // Memory to register selection
        .Jump(Jump),           // Jump signal
        .Branch(Branch),       // Branch signal
        .InverseBranch(InverseBranch),// Inverse branch signal
        .PCOffset(PCOffset),   // Program counter offset
        .RegWrite(RegWrite),   // Register write enable
        .ALU_Control(ALU_Control), // ALU control signals

        // Memory signals
        .MemRW(MemRW),         // Memory read/write signal
        .RWType(RWType)       // Read/write type signal
    );

    // Instantiate the data path
    my_datapath data_path (
        .clk(clk),             // Clock signal
        .rst(rst),             // Reset signal
        
        .ALU_Control(ALU_Control), // ALU control signals
        .ImmSel(ImmSel),       // Immediate selection
        .MemtoReg(MemtoReg),   // Memory to register selection
        .ALUSrc_B(ALUSrc_B),   // ALU source B selection
        .Jump(Jump),           // Jump signal
        .Branch(Branch),       // Branch signal
        .InverseBranch(InverseBranch),// Inverse branch signal
        .PCOffset(PCOffset),   // Program counter offset
        .RegWrite(RegWrite),   // Register write enable
        
        .inst_field(inst_in),  // Instruction input
        .PC_out(PC_out),       // Program counter output

        .Addr_out(Addr_out),   // Address output to memory
        .Data_out(Data_out_raw),   // Data output to memory
        .Data_in(Data_in),     // Data input from memory

        `RegFile_Regs_Arguments
    );

    mem_handler mem_handler_inst (
        .MemRW(MemRW),         // Memory read/write signal
        .RWType(RWType),       // Read/write type signal

        .Addr_out(Addr_out),    // Address input
        .Data_out(Data_out_raw),   // Data output
        .Data_in(mem_if.Data_in),// Data input

        .Data_in_processed(Data_in), // Data input processed

        .Data_out_processed(mem_if.Data_out), // Data output processed
        .Addr_out_aligned(mem_if.Addr_out), // Address output
        .MemWriteEnable(mem_if.MemWriteEnable) // Memory read/write signal
    );

endmodule
