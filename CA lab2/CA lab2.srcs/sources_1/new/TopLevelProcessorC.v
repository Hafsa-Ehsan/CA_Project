`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2026 9:12:45 AM
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

module TopLevelProcessorC (
    input  wire clk,
    input  wire rst,
    input  wire [15:0] switches,
    input  wire reset_btn,
    output wire [15:0] leds,
    output wire [3:0]  an,
    output wire [6:0]  seg
);
    wire [31:0] PC, nextPC, PC_plus4, branchTarget, jumpTarget, jalrTarget;
    wire [31:0] instruction;
    wire [31:0] ReadData1, ReadData2, imm;
    wire [31:0] ALU_B, ALUResult, MemReadData, WriteBackData;
    wire        Zero, LessThan;
    wire [6:0] opcode = instruction[6:0];
    wire [4:0] rd = instruction[11:7];
    wire [2:0] funct3 = instruction[14:12];
    wire [4:0] rs1 = instruction[19:15];
    wire [4:0] rs2 = instruction[24:20];
    wire funct7_5 = instruction[30];
    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg;
    wire Branch, Jump, JumpReg, LUI;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;
    wire [2:0] funct3_branch = instruction[14:12];
    wire branchTaken = Branch & (
        (funct3_branch == 3'b000) ?  Zero      :
        (funct3_branch == 3'b001) ? ~Zero      :
        (funct3_branch == 3'b100) ?  LessThan  :
                                     1'b0);
    assign jumpTarget = PC + imm;
    assign jalrTarget = {ALUResult[31:1], 1'b0};
    assign nextPC = JumpReg ? jalrTarget:
                         Jump? jumpTarget:
                         branchTaken ? branchTarget :
                                       PC_plus4;
    wire [31:0] wb_jal = PC_plus4;
    assign WriteBackData = LUI ? imm :
                           (Jump | JumpReg) ? wb_jal :
                           MemtoReg ? MemReadData :
                                             ALUResult;
    program_counter pc_inst (
        .clk(clk), .rst(rst), .nextPC(nextPC), .PC(PC)
    );
    pcAdder pc_adder_inst (
        .PC(PC), .PC_plus4(PC_plus4)
    );
    branchAdder branch_adder_inst (
        .PC(PC), .imm(imm), .branchTarget(branchTarget)
    );
    instructionMemoryC instr_mem_inst (
        .clk(clk), .instAddress(PC), .instruction(instruction)
    );
    main_control ctrl_inst (
        .opcode(opcode),
        .RegWrite(RegWrite), .ALUSrc(ALUSrc),
        .MemRead(MemRead),.MemWrite(MemWrite),
        .MemtoReg(MemtoReg),.Branch(Branch),
        .Jump(Jump),.JumpReg(JumpReg),
        .LUI(LUI),.ALUOp(ALUOp)
    );
    RegisterFile reg_file_inst (
        .clk(clk), .rst(rst),
        .WriteEnable(RegWrite),
        .WriteReg(rd),.WriteData(WriteBackData),
        .ReadReg1(rs1),.ReadData1(ReadData1),
        .ReadReg2(rs2),.ReadData2(ReadData2)
    );
    immGen imm_gen_inst (
        .instruction(instruction), .imm(imm)
    );
    assign ALU_B = ALUSrc ? imm : ReadData2;
    alu_control alu_ctrl_inst (
        .ALUOp(ALUOp), .funct3(funct3), .funct7_5(funct7_5),
        .ALUControl(ALUControl)
    );
    ALU alu_inst (
        .A(ReadData1), .B(ALU_B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero),
        .LessThan(LessThan)
    );
    wire [15:0] leds_wire;
    data_memory data_mem_inst (
        .clk(clk),
        .MemWrite(MemWrite), .MemRead(MemRead),
        .address(ALUResult),
        .WriteData(ReadData2),
        .ReadData(MemReadData),
        .switches(switches),
        .reset_btn(reset_btn),
        .leds(leds_wire)
    );
    assign leds = leds_wire;
    sevenseg_decoder seg_ctrl (
        .clk(clk), .rst(rst),
        .value(leds_wire),
        .an(an), .seg(seg)
    );
endmodule