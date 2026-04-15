`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2026 10:25:25 PM
// Design Name: 
// Module Name: leds
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

module leds (
    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] led_data,      // 16-bit value to show on LEDs
    input  wire        writeEnable,
    input  wire        readEnable,
    output reg  [15:0] led_out,       // connects to physical FPGA LEDs
    output reg  [31:0] readData       // read-back for memory-mapped access
);
 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led_out  <= 16'b0;
            readData <= 32'b0;
        end else begin
            if (writeEnable)
                led_out <= led_data;          // latch new LED pattern
 
            if (readEnable)
                readData <= {16'b0, led_out}; // read back current state
            else
                readData <= 32'b0;
        end
    end
 endmodule



















