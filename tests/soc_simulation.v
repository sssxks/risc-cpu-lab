`include "header.vh"
`include "debug.vh"

module soc_simulation(
    input wire clk,
    input wire rst
);
    wire [31:0] instruction;
    wire [31:0] datamem2cpu;
    wire [31:0] cpu2datamem;
    wire data_memory_write_enable;
    wire [31:0] cpu2datamem_addr;
    wire [31:0] program_counter;
    
    
    SCPU uut (
        .clk(clk),
        .rst(rst),

        .inst_in(instruction),
        .Data_in(datamem2cpu),
        .MIO_ready(1'b1),
        .MemRW(data_memory_write_enable),
        .CPU_MIO(), // unused
        .Addr_out(cpu2datamem_addr),
        .Data_out(cpu2datamem),
        .PC_out(program_counter)
    );

    instruction_memory U2(
        .clka(clk),

        .addra(program_counter[11:2]),
        .douta(instruction)
    );

    data_memory U3 (
        .clka(~clk), 
        .wea(data_memory_write_enable), 
        .addra(cpu2datamem_addr[9:0]), 
        .dina(cpu2datamem), 
        .douta(datamem2cpu) 
    );
endmodule


module soc_simulation_tb;
    reg clk;
    reg rst;

    soc_simulation m0(.clk(clk), .rst(rst));

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        #5;
        rst = 1'b0;
    end

    always #10 clk = ~clk;

endmodule
