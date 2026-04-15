`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2026 09:55:34 AM
// Design Name: 
// Module Name: alu_control
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



module alu_control(
    input  wire [1:0] ALUOp,
    input  wire [2:0] funct3,
    input  wire       funct7_5,
    output reg  [3:0] ALUControl
);
    always @(*) begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0011;  // ADD (LW/SW/JALR)

           
            2'b01: begin
                case (funct3)
                    3'b000: ALUControl = 4'b0100;  // BEQ  ? SUB
                    3'b001: ALUControl = 4'b0100;  // BNE  ? SUB
                    3'b100: ALUControl = 4'b0111;  // BLT  ? SLT  ? THE FIX
                    default: ALUControl = 4'b0100; 
                endcase
            end

            2'b10: begin                   // R-type
                case (funct3)
                    3'b000: ALUControl = funct7_5 ? 4'b0100 : 4'b0011; // SUB:ADD
                    3'b111: ALUControl = 4'b0000;  // AND
                    3'b110: ALUControl = 4'b0001;  // OR
                    3'b100: ALUControl = 4'b0010;  // XOR
                    3'b001: ALUControl = 4'b0101;  // SLL
                    3'b101: ALUControl = 4'b0110;  // SRL
                    3'b010: ALUControl = 4'b0111;  // SLT
                    default: ALUControl = 4'b0011;
                endcase
            end

            2'b11: begin                   // I-type ALU (ORI, SLTI, ADDI, ANDI)
                case (funct3)
                    3'b110: ALUControl = 4'b0001;  // ORI
                    3'b010: ALUControl = 4'b0111;  // SLTI
                    3'b000: ALUControl = 4'b0011;  // ADDI
                    3'b111: ALUControl = 4'b0000;  // ANDI
                    default: ALUControl = 4'b0011;
                endcase
            end

            default: ALUControl = 4'b0011;
        endcase
    end
endmodule





