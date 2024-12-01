`include "header.sv"
`include "vga_macro.vh"

module SCPU(
    input wire clk,          // Clock signal
    input wire rst,          // Reset signal

    input wire [31:0] inst_in, // Instruction input
    output wire [31:0] PC_out,   // Program counter output

    input wire ext_int,    // External interrupt signal

    data_memory_face.cpu mem_if,

    `RegFile_Regs_output
);

    // Control signals interface
    cpu_control_signals signals_if();

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
        .instruction(inst_in), // Instruction input (right now for system instructions)

        .ext_int(ext_int),     // External interrupt signal
        
        // signals to datapath
        .signals_if(signals_if.control_unit),

        // Memory signals
        .MemRW(MemRW),         // Memory read/write signal
        .RWType(RWType)        // Read/write type signal
    );

    // Instantiate the data path
    my_datapath data_path (
        .clk(clk),             // Clock signal
        .rst(rst),             // Reset signal
        
        .signals_if(signals_if.datapath),
        
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
