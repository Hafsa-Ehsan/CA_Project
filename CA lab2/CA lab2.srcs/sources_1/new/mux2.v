`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2026 11:42:22 PM
// Design Name: 
// Module Name: mux2
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


module mux2 (
    input  wire [31:0] in0, // input 0: PC + 4
    input  wire [31:0] in1, // input 1: branch target
    input  wire sel,   // PCSrc control signal
    output wire [31:0] out // selected next PC
);

    assign out = (sel) ? in1 : in0;

endmodule


