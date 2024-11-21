`timescale 1ns / 1ps

module test_soc;

    // Inputs
    reg clk;
    reg rst;
    reg [31:0] inst_in;
    reg [31:0] Data_in;
    reg MIO_ready;

    // Outputs
    wire MemRW;
    wire CPU_MIO;
    wire [31:0] Addr_out;
    wire [31:0] Data_out;
    wire [31:0] PC_out;

    // Instantiate the SCPU
    SCPU uut (
        .clk(clk),
        .rst(rst),
        .inst_in(inst_in),
        .Data_in(Data_in),
        .MIO_ready(MIO_ready),
        .MemRW(MemRW),
        .CPU_MIO(CPU_MIO),
        .Addr_out(Addr_out),
        .Data_out(Data_out),
        .PC_out(PC_out)
    );

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 0;
        inst_in = 0;
        Data_in = 0;
        MIO_ready = 1;

        // Apply reset
        rst = 1;
        #10;
        rst = 0;

        // Add stimulus here
        // Example instruction and data inputs
        inst_in = 32'h00000013; // NOP instruction
        Data_in = 32'h00000000;

        // Wait for a few clock cycles
        #100;

        // Add more test cases as needed
        // ...

        // Finish simulation
        $finish;
    end

    // Clock generation
    always #5 clk = ~clk;

endmodule
