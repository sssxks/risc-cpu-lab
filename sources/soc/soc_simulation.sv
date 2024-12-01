`include "header.sv"
`include "debug.vh"

module soc_simulation(
    input wire clk,
    input wire rst,

    input wire ext_int
);
    wire [31:0] instruction;
    wire [31:0] program_counter;
    
    data_memory_face mem_if();

    SCPU uut (
        .clk(clk),
        .rst(rst),

        .ext_int(ext_int),

        .inst_in(instruction),
        .PC_out(program_counter),
        
        .mem_if(mem_if.cpu)
    );

    instruction_memory U2(
        .a(program_counter[11:2]),
        .spo(instruction)
    );

    my_data_memory U3 (
        .clk(clk),
        .mem_if(mem_if.mem)
    );

endmodule


module soc_simulation_tb;
    reg clk;
    reg rst;
    reg ext_int;

    soc_simulation m0(.clk(clk), .rst(rst), .ext_int(ext_int));

    initial begin
        clk = 1'b0;
        rst = 1'b1;
        ext_int = 1'b0;
        #5;
        rst = 1'b0;
    end

    always #50 clk = ~clk;
endmodule
