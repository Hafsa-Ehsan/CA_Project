`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/17/2026 10:42:48 AM
// Design Name: 
// Module Name: top_control
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


module top_control (
    input  wire clk,
    input  wire rst,       
    input  wire [15:0] sw,         
    output wire [15:0] led        
);
 
    // FSM 
    localparam IDLE = 1'b0;
    localparam RUN  = 1'b1;
 
    reg state;
 
    always @(posedge clk or posedge rst) begin
        if (rst) state <= IDLE;
        else     state <= RUN;
    end
 
    //  Switches module 
    wire [31:0] sw_readData;
 
    switches sw_inst (
        .clk (clk),
        .rst (rst),
        .writeData   (32'b0),
        .writeEnable (1'b0),
        .readEnable  (1'b1),        
        .memAddress  (30'b0),
        .sw (sw),
        .readData (sw_readData),
        .leds ()             
    );
 
    // sw_readData[15:0] mirrors sw[15:0] (set by switches module)
    wire [6:0] opcode   = (state == RUN) ? sw_readData[15:9] : 7'b0;
    wire [2:0] funct3   = (state == RUN) ? sw_readData[8:6]  : 3'b0;
    wire       funct7_5 = (state == RUN) ? sw_readData[5]    : 1'b0;
 
    // Main Control 
    wire       RegWrite, ALUSrc, MemRead, MemWrite, MemtoReg, Branch;
    wire [1:0] ALUOp;
 
    main_control mc_inst (
        .opcode   (opcode),
        .RegWrite (RegWrite),
        .ALUSrc   (ALUSrc),
        .MemRead  (MemRead),
        .MemWrite (MemWrite),
        .MemtoReg (MemtoReg),
        .Branch   (Branch),
        .ALUOp    (ALUOp)
    );
 
    // ALU Control 
    wire [3:0] ALUControl;
 
    alu_control ac_inst (
        .ALUOp      (ALUOp),
        .funct3     (funct3),
        .funct7_5   (funct7_5),
        .ALUControl (ALUControl)
    );
 
    wire [15:0] ctrl_word = {
        RegWrite,   // LD15
        ALUSrc,     // LD14
        MemRead,    // LD13
        MemWrite,   // LD12
        MemtoReg,   // LD11
        Branch,     // LD10
        ALUOp,      // LD9:8
        1'b0,       // LD7  unused
        ALUControl, // LD6:3
        3'b000      // LD2:0 unused
    };
 
    // LEDs module
    leds led_inst (
        .clk         (clk),
        .rst         (rst),
        .led_data    (ctrl_word),
        .writeEnable (state == RUN),  
        .readEnable  (1'b0),
        .led_out     (led),
        .readData    ()               
    );
 
endmodule
