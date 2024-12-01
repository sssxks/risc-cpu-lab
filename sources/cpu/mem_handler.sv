`include "header.sv"

// wrapper for memory, providing endianess and sign extension
module mem_handler (
    // input from CPU
    input wire [31:0] Addr_out,
    input wire MemRW,
    input wire [2:0] RWType, // FUN3 of load/store instruction
    input wire [31:0] Data_out,
    // input from data memory
    input wire [31:0] Data_in,

    // output to CPU
    output reg [31:0] Data_in_processed,
    // output to data memory
    output reg [3:0] MemWriteEnable,
    output reg [31:0] Data_out_processed,
    output reg [31:0] Addr_out_aligned
);
    assign Addr_out_aligned = {Addr_out[31:2], 2'b00}; // Align address to 4 bytes
    wire [1:0] where = Addr_out[1:0]; // word offset

    always @(*) begin
        if (MemRW == 1'b0) begin // read
            case (RWType)
                `BYTE: begin
                    case (where)
                        2'b00: Data_in_processed = {{24{Data_in[7]}}, Data_in[7:0]};
                        2'b01: Data_in_processed = {{24{Data_in[15]}}, Data_in[15:8]};
                        2'b10: Data_in_processed = {{24{Data_in[23]}}, Data_in[23:16]};
                        2'b11: Data_in_processed = {{24{Data_in[31]}}, Data_in[31:24]};
                    endcase
                end
                `BYTE_U: begin
                    case (where)
                        2'b00: Data_in_processed = {24'b0, Data_in[7:0]};
                        2'b01: Data_in_processed = {24'b0, Data_in[15:8]};
                        2'b10: Data_in_processed = {24'b0, Data_in[23:16]};
                        2'b11: Data_in_processed = {24'b0, Data_in[31:24]};
                    endcase
                end
                `HALF: begin
                    case (where[1])
                        1'b0: Data_in_processed = {{16{Data_in[15]}}, Data_in[15:0]};
                        1'b1: Data_in_processed = {{16{Data_in[31]}}, Data_in[31:16]};
                    endcase
                end
                `HALF_U: begin
                    case (where[1])
                        1'b0: Data_in_processed = {16'b0, Data_in[15:0]};
                        1'b1: Data_in_processed = {16'b0, Data_in[31:16]};
                    endcase
                end
                `WORD: Data_in_processed = Data_in;
                default: Data_in_processed = 32'bx;
            endcase
            Data_out_processed = 32'b0;
            MemWriteEnable = 4'b0;
        end else begin // write
            case (RWType)
                `BYTE: begin // sb
                    Data_out_processed = {4{Data_out[7:0]}};
                    MemWriteEnable = 4'b0001 << where;
                end
                `HALF: begin // sh
                    Data_out_processed = {2{Data_out[15:0]}};
                    MemWriteEnable = 4'b0011 << where;
                end
                `WORD: begin // sw
                    Data_out_processed = Data_out;
                    MemWriteEnable = 4'b1111;
                end
                default: begin
                    Data_out_processed = 32'bx;
                    MemWriteEnable = 4'b0;
                end
            endcase
            Data_in_processed = 32'b0;
        end
    end
endmodule