`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2026 09:52:51 AM
// Design Name: 
// Module Name: main_control
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

module main_control(
    input  wire [6:0] opcode,
    output reg  RegWrite,
    output reg  ALUSrc,
    output reg  MemRead,
    output reg  MemWrite,
    output reg  MemtoReg,
    output reg  Branch,
    output reg  Jump,
    output reg  JumpReg,
    output reg  LUI,
    output reg  [1:0] ALUOp
);
    localparam R_TYPE  = 7'b0110011;
    localparam I_ALUI  = 7'b0010011;
    localparam I_LOAD  = 7'b0000011;
    localparam S_TYPE  = 7'b0100011;
    localparam B_TYPE  = 7'b1100011;
    localparam JAL     = 7'b1101111;
    localparam JALR    = 7'b1100111;
    localparam LUI_OP  = 7'b0110111;

    always @(*) begin
        RegWrite=0; ALUSrc=0; MemRead=0; MemWrite=0;
        MemtoReg=0; Branch=0; Jump=0; JumpReg=0; LUI=0;
        ALUOp=2'b00;

        case (opcode)
            R_TYPE: begin
                RegWrite=1; ALUSrc=0; ALUOp=2'b10;
            end
            I_ALUI: begin
                // ALUOp=2'b11 so alu_control decodes funct3 for ORI/SLTI/ADDI
                RegWrite=1; ALUSrc=1; ALUOp=2'b11;
            end
            I_LOAD: begin
                RegWrite=1; ALUSrc=1; MemRead=1; MemtoReg=1; ALUOp=2'b00;
            end
            S_TYPE: begin
                ALUSrc=1; MemWrite=1; ALUOp=2'b00;
            end
            B_TYPE: begin
                Branch=1; ALUOp=2'b01;
            end
            JAL: begin
                RegWrite=1; Jump=1;
            end
            JALR: begin
                RegWrite=1; ALUSrc=1; JumpReg=1; ALUOp=2'b00;
            end
            LUI_OP: begin
                RegWrite=1; LUI=1;
            end
            default: begin end
        endcase
    end
endmodule


//module main_control(
//    input  wire [6:0] opcode,
//    output reg  RegWrite,
//    output reg  ALUSrc,
//    output reg  MemRead,
//    output reg  MemWrite,
//    output reg  MemtoReg,
//    output reg  Branch,
//    output reg  Jump,
//    output reg  JumpReg,
//    output reg  LUI,
//    output reg  [1:0] ALUOp
//);
//    localparam R_TYPE = 7'b0110011;
//    localparam I_ALUI = 7'b0010011;
//    localparam I_LOAD = 7'b0000011;
//    localparam S_TYPE = 7'b0100011;
//    localparam B_TYPE = 7'b1100011;
//    localparam JAL    = 7'b1101111;
//    localparam JALR   = 7'b1100111;
//    localparam LUI_OP = 7'b0110111;

//    always @(*) begin
//        RegWrite = 0; ALUSrc = 0; MemRead = 0; MemWrite = 0;
//        MemtoReg = 0; Branch = 0; Jump = 0; JumpReg = 0;
//        LUI = 0; ALUOp = 2'b00;

//        case (opcode)
//            R_TYPE: begin
//                RegWrite = 1; ALUSrc = 0; ALUOp = 2'b10;
//            end
//            I_ALUI: begin
//                RegWrite = 1; ALUSrc = 1; ALUOp = 2'b00;
//            end
//            I_LOAD: begin
//                RegWrite = 1; ALUSrc = 1; MemRead = 1; MemtoReg = 1; ALUOp = 2'b00;
//            end
//            S_TYPE: begin
//                ALUSrc = 1; MemWrite = 1; ALUOp = 2'b00;
//            end
//            B_TYPE: begin
//                Branch = 1; ALUOp = 2'b01;
//            end
//            JAL: begin
//                RegWrite = 1; Jump = 1;
//            end
//            JALR: begin
//                RegWrite = 1; ALUSrc = 1; JumpReg = 1; ALUOp = 2'b00;
//            end
//            LUI_OP: begin
//                RegWrite = 1; LUI = 1;
//            end
//            default: begin end
//        endcase
//    end
//endmodule