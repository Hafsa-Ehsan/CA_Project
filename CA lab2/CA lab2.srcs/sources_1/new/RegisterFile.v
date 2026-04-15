`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/24/2026 09:41:44 AM
// Design Name: 
// Module Name: RegisterFile
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

module RegisterFile (
    input  wire clk,
    input  wire rst,          
    input  wire WriteEnable,
    input  wire [4:0]  WriteReg,
    input  wire [31:0] WriteData,
    input  wire [4:0]  ReadReg1,
    output wire [31:0] ReadData1,
    input  wire [4:0]  ReadReg2,
    output wire [31:0] ReadData2
);

    // 32 registers, each 32 bits
    reg [31:0] regs [31:0];
    integer i;

    // reset + write
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end else if (WriteEnable && (WriteReg != 5'd0)) begin
            regs[WriteReg] <= WriteData;
        end
    end

    // x0 always reads as 0 
    assign ReadData1 = (ReadReg1 == 5'd0) ? 32'b0 : regs[ReadReg1];
    assign ReadData2 = (ReadReg2 == 5'd0) ? 32'b0 : regs[ReadReg2];

endmodule