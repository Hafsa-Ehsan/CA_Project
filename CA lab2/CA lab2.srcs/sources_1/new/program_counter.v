`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/31/2026 11:17:07 PM
// Design Name: 
// Module Name: program_counter
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

module program_counter(
    input wire clk,
    input wire rst,
    input wire [31:0] nextPC,
    output reg [31:0] PC
);
    always @(posedge clk or posedge rst) begin
        if (rst) PC <= 32'b0;
        else PC <= nextPC;
    end
endmodule

