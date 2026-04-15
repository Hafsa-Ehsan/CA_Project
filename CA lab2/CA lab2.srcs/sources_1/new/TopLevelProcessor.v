`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2026 11:07:07 AM
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

//module TopLevelProcessor (
//    input  wire        clk,
//    input  wire        rst,
//    input  wire [15:0] switches,
//    input  wire        reset_btn,
//    output wire [15:0] leds,
//    output wire [3:0]  an,
//    output wire [6:0]  seg
//);
//    wire [31:0] PC, nextPC, PC_plus4, branchTarget, jumpTarget, jalrTarget;
//    wire [31:0] instruction, ReadData1, ReadData2, imm;
//    wire [31:0] ALU_B, ALUResult, MemReadData, WriteBackData;
//    wire        Zero, LessThan;

//    wire [6:0] opcode   = instruction[6:0];
//    wire [4:0] rd       = instruction[11:7];
//    wire [2:0] funct3   = instruction[14:12];
//    wire [4:0] rs1      = instruction[19:15];
//    wire [4:0] rs2      = instruction[24:20];
//    wire       funct7_5 = instruction[30];

//    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg;
//    wire Branch, Jump, JumpReg, LUI;
//    wire [1:0] ALUOp;
//    wire [3:0] ALUControl;

//    wire branchTaken = Branch & (
//        (funct3 == 3'b000) ?  Zero     :
//        (funct3 == 3'b001) ? ~Zero     :
//        (funct3 == 3'b100) ?  LessThan :
//                               1'b0);

//    assign jumpTarget  = PC + imm;
//    assign jalrTarget  = {ALUResult[31:1], 1'b0};
//    assign nextPC      = JumpReg     ? jalrTarget  :
//                         Jump        ? jumpTarget   :
//                         branchTaken ? branchTarget :
//                                       PC_plus4;

//    assign WriteBackData = LUI              ? imm        :
//                           (Jump | JumpReg) ? PC_plus4   :
//                           MemtoReg         ? MemReadData :
//                                             ALUResult;

//    // =====================================================
//    // LEDs - clearly labelled for instructor
//    // LD15 = LessThan   (BLT: ALU says A<B)
//    // LD14 = Zero        (ALU result == 0)
//    // LD13 = Branch      (is a branch instruction)
//    // LD12 = Jump        (JAL)
//    // LD11 = JumpReg     (JALR)  ? NEW
//    // LD10 = LUI                 ? NEW
//    // LD9  = MemtoReg
//    // LD8  = MemWrite
//    // LD7  = MemRead
//    // LD6  = ALUSrc
//    // LD5  = RegWrite
//    // LD4  = branchTaken (branch fired)
//    // LD3:0= ALUControl
//    // =====================================================
//    assign leds = {
//        LessThan,    // 15
//        Zero,        // 14
//        Branch,      // 13
//        Jump,        // 12
//        JumpReg,     // 11  ? lights for JALR
//        LUI,         // 10  ? lights for LUI
//        MemtoReg,    // 9
//        MemWrite,    // 8
//        MemRead,     // 7
//        ALUSrc,      // 6
//        RegWrite,    // 5
//        branchTaken, // 4
//        ALUControl   // 3:0
//    };

//    // 7-seg shows PC always
//    sevenseg_decoder seg_ctrl(
//        .clk(clk), .rst(rst),
//        .value(PC[15:0]),
//        .an(an), .seg(seg)
//    );

//    program_counter   pc_inst(.clk(clk),.rst(rst),.nextPC(nextPC),.PC(PC));
//    pcAdder           pc_adder_inst(.PC(PC),.PC_plus4(PC_plus4));
//    branchAdder       branch_adder_inst(.PC(PC),.imm(imm),.branchTarget(branchTarget));
//    instructionMemory instr_mem_inst(.clk(clk),.instAddress(PC),.instruction(instruction));
//    main_control      ctrl_inst(
//        .opcode(opcode),.RegWrite(RegWrite),.ALUSrc(ALUSrc),
//        .MemRead(MemRead),.MemWrite(MemWrite),.MemtoReg(MemtoReg),
//        .Branch(Branch),.Jump(Jump),.JumpReg(JumpReg),.LUI(LUI),.ALUOp(ALUOp)
//    );
//    RegisterFile reg_file_inst(
//        .clk(clk),.rst(rst),.WriteEnable(RegWrite),
//        .WriteReg(rd),.WriteData(WriteBackData),
//        .ReadReg1(rs1),.ReadData1(ReadData1),
//        .ReadReg2(rs2),.ReadData2(ReadData2)
//    );
//    immGen       imm_gen_inst(.instruction(instruction),.imm(imm));
//    assign ALU_B = ALUSrc ? imm : ReadData2;
//    alu_control  alu_ctrl_inst(.ALUOp(ALUOp),.funct3(funct3),.funct7_5(funct7_5),.ALUControl(ALUControl));
//    ALU alu_inst(
//        .A(ReadData1),.B(ALU_B),.ALUControl(ALUControl),
//        .ALUResult(ALUResult),.Zero(Zero),.LessThan(LessThan)
//    );
//    wire [15:0] leds_unused;
//    data_memory data_mem_inst(
//        .clk(clk),.rst(rst),
//        .MemWrite(MemWrite),.MemRead(MemRead),
//        .address(ALUResult),.WriteData(ReadData2),.ReadData(MemReadData),
//        .switches(switches),.reset_btn(reset_btn),.leds(leds_unused)
//    );
//endmodule

//works for TASkA
module TopLevelProcessor (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] switches,
    input  wire        reset_btn,
    output wire [15:0] leds,
    output wire [3:0]  an,
    output wire [6:0]  seg
);
    wire [31:0] PC, nextPC, PC_plus4, branchTarget, jumpTarget, jalrTarget;
    wire [31:0] instruction;
    wire [31:0] ReadData1, ReadData2, imm;
    wire [31:0] ALU_B, ALUResult, MemReadData, WriteBackData;
    wire        Zero, LessThan;   // LessThan NEW from ALU

    wire [6:0] opcode   = instruction[6:0];
    wire [4:0] rd       = instruction[11:7];
    wire [2:0] funct3   = instruction[14:12];
    wire [4:0] rs1      = instruction[19:15];
    wire [4:0] rs2      = instruction[24:20];
    wire       funct7_5 = instruction[30];

    wire RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg;
    wire Branch, Jump, JumpReg, LUI;
    wire [1:0] ALUOp;
    wire [3:0] ALUControl;

    // Branch condition - BEQ, BNE, BLT all use B-type opcode
    wire [2:0] funct3_branch = instruction[14:12];
    wire branchTaken = Branch & (
        (funct3_branch == 3'b000) ?  Zero      :  // BEQ
        (funct3_branch == 3'b001) ? ~Zero      :  // BNE
        (funct3_branch == 3'b100) ?  LessThan  :  // BLT  NEW
                                     1'b0);

    assign jumpTarget  = PC + imm;
    assign jalrTarget  = {ALUResult[31:1], 1'b0};
    assign nextPC      = JumpReg     ? jalrTarget  :
                         Jump        ? jumpTarget   :
                         branchTaken ? branchTarget :
                                       PC_plus4;

    wire [31:0] wb_jal = PC_plus4;
    assign WriteBackData = LUI              ? imm        :
                           (Jump | JumpReg) ? wb_jal     :
                           MemtoReg         ? MemReadData :
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
    instructionMemory instr_mem_inst (
        .clk(clk), .instAddress(PC), .instruction(instruction)
    );
    main_control ctrl_inst (
        .opcode(opcode),
        .RegWrite(RegWrite), .ALUSrc(ALUSrc),
        .MemRead(MemRead),   .MemWrite(MemWrite),
        .MemtoReg(MemtoReg), .Branch(Branch),
        .Jump(Jump),         .JumpReg(JumpReg),
        .LUI(LUI),           .ALUOp(ALUOp)
    );
    RegisterFile reg_file_inst (
        .clk(clk), .rst(rst),
        .WriteEnable(RegWrite),
        .WriteReg(rd), .WriteData(WriteBackData),
        .ReadReg1(rs1), .ReadData1(ReadData1),
        .ReadReg2(rs2), .ReadData2(ReadData2)
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
        .LessThan(LessThan)    // NEW
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


