`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2026 11:41:24 AM
// Design Name: 
// Module Name: instructionMemoryA
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


//---- TASK A ----- 
module instructionMemoryA #(
    parameter OPERAND_LENGTH = 31
)(
    input  wire                    clk,
    input  wire [OPERAND_LENGTH:0] instAddress,
    output reg  [31:0]             instruction
);
    reg [31:0] memory [0:255];
    initial begin
        memory[ 0] = 32'h00002137; // --- _start : lui sp,0x2
        memory[ 1] = 32'h100002B7; // lui t0,0x10000
        memory[ 2] = 32'h00428293; // addi t0,t0,4
        memory[ 3] = 32'h0002A023; // sw zero,0(t0)
        memory[ 4] = 32'h100002B7; // --- INPUT_WAIT : lui t0,0x10000
        memory[ 5] = 32'h0002A503; // lw a0,0(t0)
        memory[ 6] = 32'hFE050CE3; // beqz a0,INPUT_WAIT
        memory[ 7] = 32'h10000337; // lui t1,0x10000
        memory[ 8] = 32'h00430313; // addi t1,t1,4
        memory[ 9] = 32'h00A32023; // sw a0,0(t1)
        memory[10] = 32'hFF810113; // addi sp,sp,-8
        memory[11] = 32'h00112223; // sw ra,4(sp)
        memory[12] = 32'h00A12023; // sw a0,0(sp)
        memory[13] = 32'h028000EF; // jal ra,COUNTDOWN
        memory[14] = 32'h00412083; // lw ra,4(sp)
        memory[15] = 32'h00810113; // addi sp,sp,8
        memory[16] = 32'h100002B7; // lui t0,0x10000
        memory[17] = 32'h00428293; // addi t0,t0,4
        memory[18] = 32'h0002A023; // sw zero,0(t0)
        memory[19] = 32'h100002B7; // --- WAIT_RELEASE : lui t0,0x10000
        memory[20] = 32'h0002A303; // lw t1,0(t0)
        memory[21] = 32'hFE031CE3; // bnez t1,WAIT_RELEASE
        memory[22] = 32'hFB9FF06F; // j INPUT_WAIT
        memory[23] = 32'hFF410113; // --- COUNTDOWN : addi sp,sp,-12
        memory[24] = 32'h00112423; // sw ra,8(sp)
        memory[25] = 32'h00812223; // sw s0,4(sp)
        memory[26] = 32'h00912023; // sw s1,0(sp)
        memory[27] = 32'h00050413; // mv s0,a0
        memory[28] = 32'h100004B7; // lui s1,0x10000
        memory[29] = 32'h00448493; // addi s1,s1,4
        memory[30] = 32'h100002B7; // --- COUNT_LOOP : lui t0,0x10000
        memory[31] = 32'h00828293; // addi t0,t0,8
        memory[32] = 32'h0002A303; // lw t1,0(t0)
        memory[33] = 32'h02031663; // bnez t1,COUNT_RESET
        memory[34] = 32'h0084A023; // sw s0,0(s1)
        memory[35] = 32'h02040663; // beqz s0,COUNT_DONE
        memory[36] = 32'hFFC10113; // addi sp,sp,-4
        memory[37] = 32'h00A12023; // sw a0,0(sp)
        memory[38] = 32'h00000513; // li a0,0
        memory[39] = 32'h034000EF; // jal ra,DELAY_1S
        memory[40] = 32'h00012503; // lw a0,0(sp)
        memory[41] = 32'h00410113; // addi sp,sp,4
        memory[42] = 32'hFFF40413; // addi s0,s0,-1
        memory[43] = 32'hFCDFF06F; // j COUNT_LOOP
        memory[44] = 32'h0004A023; // --- COUNT_RESET : sw zero,0(s1)
        memory[45] = 32'h0080006F; // j COUNT_EPILOGUE
        memory[46] = 32'h0004A023; // --- COUNT_DONE : sw zero,0(s1)
        memory[47] = 32'h00012483; // --- COUNT_EPILOGUE : lw s1,0(sp)
        memory[48] = 32'h00412403; // lw s0,4(sp)
        memory[49] = 32'h00812083; // lw ra,8(sp)
        memory[50] = 32'h00C10113; // addi sp,sp,12
        memory[51] = 32'h00008067; // ret
        memory[52] = 32'h017D83B7; // --- DELAY_1S  25000000 iters = 0.5s @ 100MHz : lui t2,0x17d8
        memory[53] = 32'h84038393; // addi t2,t2,-1984
        memory[54] = 32'hFFF38393; // --- DELAY_LOOP : addi t2,t2,-1
        memory[55] = 32'hFE039EE3; // bnez t2,DELAY_LOOP
        memory[56] = 32'h00008067; // ret
    end

    always @(*) begin
        instruction = memory[instAddress[9:2]];
    end
endmodule


// --- Task B --- 
module instructionMemory #(
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

