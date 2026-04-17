`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2026 11:40:36 AM
// Design Name: 
// Module Name: ALU
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


module ALU(
    input  wire [31:0] A,
    input  wire [31:0] B,
    input  wire [3:0]  ALUControl,
    output reg  [31:0] ALUResult,
    output wire Zero,
    output wire LessThan //  for BLT
);
    assign Zero     = (ALUResult == 32'b0);
    assign LessThan = ALUResult[0];  // SLT/SLTI result is 1 or 0 in bit[0]

    always @(*) begin
        case (ALUControl)
            4'b0000: ALUResult = A & B;
            4'b0001: ALUResult = A | B;  // OR / ORI
            4'b0010: ALUResult = A ^ B;
            4'b0011: ALUResult = A + B;
            4'b0100: ALUResult = A - B;
            4'b0101: ALUResult = A << B[4:0];
            4'b0110: ALUResult = A >> B[4:0];
            4'b0111: ALUResult = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT NEW
            default: ALUResult = 32'bx;
        endcase
    end
endmodule
