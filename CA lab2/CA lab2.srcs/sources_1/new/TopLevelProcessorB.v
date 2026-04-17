`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/14/2026 8:10:31 AM
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


module TopLevelProcessor (
    input  wire clk, // 100MHz from board
    input  wire rst,
    input  wire [15:0] switches,
    input  wire reset_btn,
    output wire [15:0] leds,
    output wire [3:0]  an,
    output wire [6:0]  seg
);
    // Slow clock: 100MHz / 100,000,000 = 1Hz
    // Each instruction visible for 1 full second
    reg [26:0] clk_div;
    reg slow_clk;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_div  <= 0;
            slow_clk <= 0;
        end else begin
            if (clk_div == 27'd49_999_999) begin
                clk_div  <= 0;
                slow_clk <= ~slow_clk;
            end else
                clk_div <= clk_div + 1;
        end
    end
 
    // All processor logic uses slow_clk
    wire [31:0] PC, nextPC, PC_plus4, branchTarget, jumpTarget, jalrTarget;
    wire [31:0] instruction, ReadData1, ReadData2, imm;
    wire [31:0] ALU_B, ALUResult, MemReadData, WriteBackData;
    wire  Zero, LessThan;
 
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
 
    wire branchTaken = Branch & ((funct3 == 3'b000) ?  Zero :(funct3 == 3'b001) ? ~Zero : (funct3 == 3'b100) ?  LessThan : 1'b0);
 
    assign jumpTarget  = PC + imm;
    assign jalrTarget  = {ALUResult[31:1], 1'b0};
    assign nextPC      = JumpReg  ? jalrTarget : Jump  ? jumpTarget : branchTaken ? branchTarget : PC_plus4;
 
    assign WriteBackData = LUI  ? imm : (Jump | JumpReg) ? PC_plus4  : MemtoReg   ? MemReadData : ALUResult;
 
    // LEDs show control + ALU signals
    assign leds = {
        LessThan, // LD15 — 1 when A<B (BLT condition)
        Zero,  // LD14 — 1 when ALU result = 0
        Branch, // LD13 — 1 for any branch instruction
        Jump, // LD12 — 1 for JAL
        JumpReg, // LD11 — 1 for JALR
        LUI,  // LD10 — 1 for LUI
        MemtoReg, // LD9
        MemWrite, // LD8
        MemRead, // LD7
        ALUSrc, // LD6
        RegWrite, // LD5
        branchTaken, // LD4 — 1 when branch actually fires
        ALUControl   // LD3:0
    };
 
    // 7-seg shows PC using fast clock (stable display)
    sevenseg_decoder seg_ctrl(
        .clk(clk), .rst(rst),
        .value(PC[15:0]),
        .an(an), .seg(seg)
    );
 
    // Processor runs on slow_clk — 1 instruction per second
    program_counter pc_inst(.clk(slow_clk),.rst(rst),.nextPC(nextPC),.PC(PC));
    pcAdder pc_adder_inst(.PC(PC),.PC_plus4(PC_plus4));
    branchAdder  branch_adder_inst(.PC(PC),.imm(imm),.branchTarget(branchTarget));
    instructionMemoryB instr_mem_inst(.clk(slow_clk),.instAddress(PC),.instruction(instruction));
    main_control  ctrl_inst(
        .opcode(opcode),.RegWrite(RegWrite),.ALUSrc(ALUSrc),
        .MemRead(MemRead),.MemWrite(MemWrite),.MemtoReg(MemtoReg),
        .Branch(Branch),.Jump(Jump),.JumpReg(JumpReg),.LUI(LUI),.ALUOp(ALUOp)
    );
    RegisterFile reg_file_inst(
        .clk(slow_clk),.rst(rst),.WriteEnable(RegWrite),
        .WriteReg(rd),.WriteData(WriteBackData),
        .ReadReg1(rs1),.ReadData1(ReadData1),
        .ReadReg2(rs2),.ReadData2(ReadData2)
    );
    immGen imm_gen_inst(.instruction(instruction),.imm(imm));
    assign ALU_B = ALUSrc ? imm : ReadData2;
    alu_control  alu_ctrl_inst(.ALUOp(ALUOp),.funct3(funct3),.funct7_5(funct7_5),.ALUControl(ALUControl));
    ALU alu_inst(
        .A(ReadData1),.B(ALU_B),.ALUControl(ALUControl),
        .ALUResult(ALUResult),.Zero(Zero),.LessThan(LessThan)
    );
    wire [15:0] leds_unused;
    data_memory data_mem_inst(
        .clk(slow_clk),.rst(rst),
        .MemWrite(MemWrite),.MemRead(MemRead),
        .address(ALUResult),.WriteData(ReadData2),.ReadData(MemReadData),
        .switches(switches),.reset_btn(reset_btn),.leds(leds_unused)
    );
endmodule