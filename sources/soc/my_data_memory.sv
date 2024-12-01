`include "header.sv"

module my_data_memory (
    input wire clk,
    data_memory_face.mem mem_if
);
    data_memory U3 (
        .clka(~clk), 
        .wea(mem_if.MemWriteEnable), 
        .addra(mem_if.Addr_out[11:2]),
        .dina(mem_if.Data_out), 
        .douta(mem_if.Data_in) 
    );
endmodule