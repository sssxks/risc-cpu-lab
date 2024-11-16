`timescale 1ns / 1ps
`default_nettype none

module Regs(
    input clk, rst, RegWrite,
    input [4:0] Rs1_addr, Rs2_addr, Wt_addr,
    input [31:0] Wt_data,
    output [31:0] Rs1_data, Rs2_data
);
    reg [31:0] register [1:31]; // x1 - x31, r0 is hard wired to 0
    
    assign Rs1_data = (Rs1_addr == 0) ? 0 : register[Rs1_addr];
    assign Rs2_data = (Rs2_addr == 0) ? 0 : register[Rs2_addr];

	integer i;
    always @(posedge clk or posedge rst) begin
        if (rst==1) begin
            for (i=1; i<32; i=i+1)
				register[i] <= 0; // reset
		end else if ((Wt_addr != 0) && (RegWrite == 1))
            register[Wt_addr] <= Wt_data; // write
    end
endmodule