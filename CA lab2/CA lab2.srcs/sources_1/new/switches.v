`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2026 10:24:33 PM
// Design Name: 
// Module Name: switches
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


module switches(
    input clk,
    input rst,
    input [31:0] writeData,   // Input Write Data
    input writeEnable,         // Input Write Enable
    input readEnable,          // Input Read Enable
    input [29:0] memAddress,   // Memory Address (unused in this case, but should be connected)
    input [15:0] sw,           // Input Switches (16 switches for control)
    output reg [31:0] readData, // Output Read Data
    output reg [15:0] leds      // Output LEDs (connected to FPGA LEDs for display)
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            readData <= 0;  // Clear the read data on reset
            leds <= 0;      // Clear LEDs on reset
        end else begin
            leds <= sw;     // Map switches to LEDs
            if (readEnable)
                readData <= {16'b0, sw};  // Read the switch values into the lower 16 bits of readData
            else
                readData <= 0;  // Reset readData if not reading
        end
    end
endmodule
