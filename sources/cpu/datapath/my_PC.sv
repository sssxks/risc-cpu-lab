`timescale 1ns / 1ps
`default_nettype none

module my_PC (
    input wire clk,
    input wire rst,
    input wire [31:0] pc_in, // pc to next instruction
    output reg [31:0] pc_out, // current pc

    // interrupt signals
    input wire [1:0] int_cause,
    input wire mret
);
    // currently not supporting read/write to CSR
    reg [31:0] mepc;
    reg [31:0] mtvec[3:0];
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_out <= 32'b0;
            mepc <= 32'b0;
            mtvec[0] <= 32'h0;
            mtvec[1] <= 32'h4;
            mtvec[2] <= 32'h8;
            mtvec[3] <= 32'hc;
        end if (int_cause != 2'b00) begin
            mepc <= pc_out;
            pc_out <= mtvec[int_cause];
        end else if (mret) begin
            pc_out <= mepc;
        end else begin
            pc_out <= pc_in;
        end
end

endmodule