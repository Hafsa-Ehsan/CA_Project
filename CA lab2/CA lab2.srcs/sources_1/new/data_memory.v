`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2026 10:34:00 AM
// Design Name: 
// Module Name: data_memory
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



module data_memory (
    input  wire        clk,
    input  wire        rst,          // ADD rst port
    input  wire        MemWrite,
    input  wire        MemRead,
    input  wire [31:0] address,
    input  wire [31:0] WriteData,
    output reg  [31:0] ReadData,
    input  wire [15:0] switches,
    input  wire        reset_btn,
    output reg  [15:0] leds
);
    reg [31:0] memory [0:1023];
    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1)
            memory[i] = 32'b0;
    end

    wire io_switch = (address == 32'h10000000);
    wire io_led    = (address == 32'h10000004);
    wire io_reset  = (address == 32'h10000008);
    wire io_any    = io_switch | io_led | io_reset;

    always @(posedge clk or posedge rst) begin
        if (rst)
            leds <= 16'b0;           // clear on reset
        else if (MemWrite && io_led)
            leds <= WriteData[15:0];
        else if (MemWrite && !io_any)
            memory[address[11:2]] <= WriteData;
    end

    always @(*) begin
        if (MemRead) begin
            if      (io_switch) ReadData = {16'b0, switches};
            else if (io_reset)  ReadData = {31'b0, reset_btn};
            else if (io_led)    ReadData = {16'b0, leds};
            else                ReadData = memory[address[11:2]];
        end else
            ReadData = 32'b0;
    end
endmodule


//module data_memory (
//    input  wire        clk,
//    input  wire        rst,
//    input  wire        MemWrite,
//    input  wire        MemRead,
//    input  wire [31:0] address,
//    input  wire [31:0] WriteData,
//    output reg  [31:0] ReadData,
//    input  wire [15:0] switches,
//    input  wire        reset_btn,
//    output reg  [15:0] leds
//);
//    // 256-word memory - covers stack at 0x2000 (byte addr) = index 0x800>>2
//    // Note: address[9:2] gives word index from byte address
//    (* ram_style = "distributed" *)   // LUT RAM ? supports async read
//    reg [31:0] memory [0:255];

//    // I/O address decode
//    wire io_switch = (address == 32'h10000000);
//    wire io_led    = (address == 32'h10000004);
//    wire io_reset  = (address == 32'h10000008);
//    wire io_any    = io_switch | io_led | io_reset;

//    // ----------------------------------------------------------
//    // WRITE PATH - clocked (correct: writes commit on clock edge)
//    // ----------------------------------------------------------
//    always @(posedge clk or posedge rst) begin
//        if (rst) begin
//            leds <= 16'b0;
//        end else begin
//            if (MemWrite) begin
//                if (io_led)
//                    leds <= WriteData[15:0];
//                else if (!io_any)
//                    memory[address[9:2]] <= WriteData;
//            end
//        end
//    end

//    // ----------------------------------------------------------
//    // READ PATH - COMBINATIONAL (fixed for single-cycle)
//    // ReadData is available in the same cycle as address/MemRead
//    // ----------------------------------------------------------
//    always @(*) begin
//        if (MemRead) begin
//            if      (io_switch) ReadData = {16'b0, switches};
//            else if (io_reset)  ReadData = {31'b0, reset_btn};
//            else if (io_led)    ReadData = {16'b0, leds};
//            else                ReadData = memory[address[9:2]];
//        end else begin
//            ReadData = 32'b0;
//        end
//    end

//endmodule




