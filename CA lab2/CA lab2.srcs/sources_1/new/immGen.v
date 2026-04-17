`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2026 11:47:10 PM
// Design Name: 
// Module Name: immGen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// immGen: handles all RISC-V immediate formats
// For B-type and J-type: bit[0] is hardcoded 0 (already *2)
module immGen (
    input  wire [31:0] instruction,
    output reg  [31:0] imm
);
    wire [6:0] opcode = instruction[6:0];

    always @(*) begin
        case (opcode)
            // I-type: ADDI, LW, JALR
            7'b0010011,
            7'b0000011,
            7'b1100111: imm = {{20{instruction[31]}}, instruction[31:20]};

            // S-type: SW
            7'b0100011: imm = {{20{instruction[31]}},
                                instruction[31:25],
                                instruction[11:7]};

            // B-type: BEQ, BNE - LSB is already 0 (byte 1 granularity)
            7'b1100011: imm = {{19{instruction[31]}},
                                instruction[31],
                                instruction[7],
                                instruction[30:25],
                                instruction[11:8],
                                1'b0};

            // J-type: JAL - LSB already 0
            7'b1101111: imm = {{11{instruction[31]}},
                                instruction[31],
                                instruction[19:12],
                                instruction[20],
                                instruction[30:21],
                                1'b0};

            // U-type: LUI
            7'b0110111: imm = {instruction[31:12], 12'b0};

            default: imm = 32'b0;
        endcase
    end
endmodule