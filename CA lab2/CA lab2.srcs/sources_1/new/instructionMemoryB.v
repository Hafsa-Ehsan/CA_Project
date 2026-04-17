`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2026 8:06:31 AM
// Design Name: 
// Module Name: instructionMemoryB
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



// --- Task B --- 
module instructionMemoryB #(
    parameter OPERAND_LENGTH = 31
)(
    input  wire clk,
    input  wire [OPERAND_LENGTH:0] instAddress,
    output reg  [31:0]  instruction
);
    (* rom_style = "distributed" *)
    reg [31:0] memory [0:5];
    initial begin
        memory[0] = 32'h00300413;  // addi s0,zero,3  (s0=3)
        memory[1] = 32'h00700493;  // addi s1,zero,7  (s1=7)
        memory[2] = 32'h00944463;  // BLT s0,s1,TAKEN - 3<7 branch taken
        memory[3] = 32'h00000293;  // addi t0,zero,0  
        memory[4] = 32'h00100313;  // TAKEN: addi t1,zero,1  
        memory[5] = 32'hFEDFF06F;  // j _start  loop
    end
    always @(*) begin
        instruction = memory[instAddress[9:2]];
    end
endmodule
