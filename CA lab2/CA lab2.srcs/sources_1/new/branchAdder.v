`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2026 11:26:17 PM
// Design Name: 
// Module Name: branchAdder
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


module branchAdder (
    input  wire [31:0] PC,
    input  wire [31:0] imm,
    output wire [31:0] branchTarget
);
    // immGen already includes the LSB 0 for B-type and J-type.
    // Do NOT shift again here - just add directly.
    assign branchTarget = PC + imm;
 
endmodule
 


