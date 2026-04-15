`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2026 10:26:11 PM
// Design Name: 
// Module Name: debouncer
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


module debouncer(
    input clk,
    input pbin,
    output reg pbout
);

reg [19:0] counter = 0;
reg sync_0 = 0;
reg sync_1 = 0;

always @(posedge clk) begin
    sync_0 <= pbin;
    sync_1 <= sync_0;
end

always @(posedge clk) begin
    if (pbout == sync_1)
        counter <= 0;
    else begin
        counter <= counter + 1;
        if (counter == 1_000_000) begin
            pbout <= sync_1;
            counter <= 0;
        end
    end
end

endmodule
