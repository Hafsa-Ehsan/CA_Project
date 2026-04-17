`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2026 9:30:45 AM
// Design Name: 
// Module Name: TopLevelProcessor
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


module instructionMemoryC #(
    parameter OPERAND_LENGTH = 31)
    (
    input  wire clk,
    input  wire [OPERAND_LENGTH:0] instAddress,
    output reg [31:0] instruction
);
    reg [31:0] memory [0:255];

    initial begin
        
        memory[ 0] = 32'h00002137;   // lui x2, 0x2
        memory[ 1] = 32'h100002B7;   // lui x5, 0x10000
        memory[ 2] = 32'h00428293;   // addi x5, x5, 4
        memory[ 3] = 32'h0002A023;   // sw x0, 0(x5)
        memory[ 4] = 32'h100002B7;   // lui x5, 0x10000
        memory[ 5] = 32'h0002A503;   // lw x10, 0(x5)
        memory[ 6] = 32'hFE050CE3;   // beqz x10, INPUT_WAIT
        memory[ 7] = 32'h028000EF;   // jal x1, +40  
        memory[ 8] = 32'h100002B7;   // lui x5, 0x10000
        memory[ 9] = 32'h00428293;   // addi x5, x5, 4
        memory[10] = 32'h00A2A023;   // sw x10, 0(x5)
        memory[11] = 32'h100002B7;   // lui x5, 0x10000
        memory[12] = 32'h0002A303;   // lw x6, 0(x5)
        memory[13] = 32'hFE031CE3;   // bnez x6, WAIT_RELEASE
        memory[14] = 32'hFD9FF06F;   // j INPUT_WAIT
        memory[15] = 32'h00000013;   // nop (addi x0,x0,0)
        memory[16] = 32'h00000013;   // nop
        memory[17] = 32'hFF010113;   // addi x2, x2, -16
        memory[18] = 32'h00112623;   // sw   x1,  12(x2)
        memory[19] = 32'h00812423;   // sw   x8,   8(x2)
        memory[20] = 32'h00912223;   // sw   x9,   4(x2)
        memory[21] = 32'h01212023;   // sw   x18,  0(x2)
        memory[22] = 32'h00100293;   // addi x5, x0, 1
        memory[23] = 32'h02A54663;   // blt x10, x5, +44 
        memory[24] = 32'h02550463;   // beq x10, x5, +40 
        memory[25] = 32'h00050413;   // add  x8,  x10, x0   (s0 = N)
        memory[26] = 32'h00000493;   // addi x9,  x0,  0    (s1 = 0)
        memory[27] = 32'h00100913;   // addi x18, x0,  1    (s2 = 1)
        memory[28] = 32'h00100293;   // addi x5, x0, 1
        memory[29] = 32'h01248333;   // add  x6, x9, x18   (t1 = s1+s2)
        memory[30] = 32'h00090493;   // add  x9, x18, x0   (s1 = s2)
        memory[31] = 32'h00030913;   // add  x18, x6, x0   (s2 = t1)
        memory[32] = 32'hFFF40413;   // addi x8, x8, -1    (s0--)
        memory[33] = 32'hFE5418E3;   // bne x8, x5, -16 
        memory[34] = 32'h00000513;   // addi x10, x0, 0   (a0 = 0)
        memory[35] = 32'h00090513;   // add  x10, x18, x0  (a0 = s2)
        memory[36] = 32'h00012903;   // lw   x18, 0(x2)   (restore s2)
        memory[37] = 32'h00412483;   // lw   x9,  4(x2)   (restore s1)
        memory[38] = 32'h00812403;   // lw   x8,  8(x2)   (restore s0)
        memory[39] = 32'h00C12083;   // lw   x1,  12(x2)  (restore ra)
        memory[40] = 32'h01010113;   // addi x2,  x2, 16  (pop stack)
        memory[41] = 32'h00008067;   // jalr x0, 0(x1)    (ret)
    end

    always @(*) begin
        instruction = memory[instAddress[9:2]];
    end
endmodule