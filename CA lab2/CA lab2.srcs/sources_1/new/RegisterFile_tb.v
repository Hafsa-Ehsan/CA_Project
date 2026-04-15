`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2026 10:13:22 AM
// Design Name: 
// Module Name: RegisterFile_tb
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

module RegisterFile_tb;
    reg clk;
    reg rst;
    reg WriteEnable;
    reg [4:0] WriteReg;
    reg [31:0] WriteData;
    reg [4:0] ReadReg1;
    reg [4:0] ReadReg2;
    wire [31:0] ReadData1;
    wire [31:0] ReadData2;

    RegisterFile regf_inst (
        .clk(clk), 
        .rst(rst),
        .WriteEnable(WriteEnable),
        .WriteReg(WriteReg), 
        .WriteData(WriteData),
        .ReadReg1(ReadReg1), 
        .ReadData1(ReadData1),
        .ReadReg2(ReadReg2), 
        .ReadData2(ReadData2)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("RegisterFile_tb.vcd");
        $dumpvars(0, RegisterFile_tb);

        // Initialize + Reset
        rst = 1; WriteEnable = 0; WriteReg = 0; WriteData = 0;
        ReadReg1 = 0; ReadReg2 = 0;
        #10; rst = 0; #10;

        // Writes x5 = 0xDEADBEEF, read back next cycle
        WriteEnable = 1; WriteReg = 5'd5; WriteData = 32'hDEADBEEF;
        ReadReg1 = 5'd5;
        #10;
        WriteEnable = 0;
        #10;

        // Write to x0, must remain 0
        WriteEnable = 1; WriteReg = 5'd0; WriteData = 32'hCAFEBABE;
        ReadReg1 = 5'd0;
        #10; WriteEnable = 0; #10;

        // Write x1 and x2, read simultaneously
        WriteEnable = 1; WriteReg = 5'd1; WriteData = 32'hAAAAAAAA; #10;
        WriteReg = 5'd2; WriteData = 32'h55555555; #10;
        WriteEnable = 0;
        ReadReg1 = 5'd1; ReadReg2 = 5'd2;
        #10;

        // Overwrite x5 with 0x12345678
        WriteEnable = 1; WriteReg = 5'd5; WriteData = 32'h12345678;
        ReadReg1 = 5'd5;
        #10; WriteEnable = 0; #10;

        //  Reset clears registers
        rst = 1; #10; rst = 0;
        ReadReg1 = 5'd1; ReadReg2 = 5'd2;
        #10;

        #20 $finish;
    end
endmodule