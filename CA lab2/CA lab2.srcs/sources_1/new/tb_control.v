`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2026 10:00:25 AM
// Design Name: 
// Module Name: tb_control
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


module tb_control;
    reg [6:0] opcode;
    reg [2:0] funct3;
    reg funct7_5;
 
    wire RegWrite;
    wire ALUSrc;
    wire MemRead;
    wire MemWrite;
    wire MemtoReg;
    wire Branch;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;
 
    main_control mc (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ALUSrc   (ALUSrc),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .MemtoReg (MemtoReg),
        .Branch   (Branch),
        .ALUOp    (ALUOp)
    );
 
    alu_control ac (
        .ALUOp (ALUOp),
        .funct3 (funct3),
        .funct7_5 (funct7_5),
        .ALUControl (ALUControl)
    );
 
    initial begin
        $dumpfile("tb_control.vcd");
        $dumpvars(0, tb_control);
 
        opcode = 7'b0; funct3 = 3'b0; funct7_5 = 0; #10;
        
        // R-type 
        opcode = 7'b0110011;
        funct3 = 3'b000; funct7_5 = 0; #10; // ADD
        funct3 = 3'b000; funct7_5 = 1; #10; // SUB
        funct3 = 3'b111; funct7_5 = 0; #10; // AND
        funct3 = 3'b110; funct7_5 = 0; #10; // OR
        funct3 = 3'b100; funct7_5 = 0; #10; // XOR
        funct3 = 3'b001; funct7_5 = 0; #10; // SLL
        funct3 = 3'b101; funct7_5 = 0; #10; // SRL
        // ADDI 
        opcode = 7'b0010011; funct3 = 3'b000; funct7_5 = 0; #10;
        // Load
        opcode = 7'b0000011;
        funct3 = 3'b010; #10; // LW
        funct3 = 3'b001; #10; // LH
        funct3 = 3'b000; #10; // LB
        // Store 
        opcode = 7'b0100011;
        funct3 = 3'b010; #10; // SW
        funct3 = 3'b001; #10; // SH
        funct3 = 3'b000; #10; // SB
        // BEQ 
        opcode = 7'b1100011; funct3 = 3'b000; funct7_5 = 0; #10;
 
        #10; $finish;
    end
endmodule
