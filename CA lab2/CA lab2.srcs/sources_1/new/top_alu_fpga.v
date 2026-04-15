`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/24/2026 11:08:05 AM
// Design Name: 
// Module Name: top_alu_fpga
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


module top_alu_fpga(
    input  wire [15:0] sw, // 16 switches 
    input  wire clk, 
    input  wire  btn, 
    output wire [15:0] led  // 16 LEDs
    );
    localparam [31:0] A_FIXED = 32'h10101010;  
    localparam [31:0] B_FIXED = 32'h01010101;  

    //debouncer
    reg [19:0] debounce_cnt;
    reg btn_stable, btn_prev;
    wire btn_edge;
    
    always @(posedge clk) begin
        if (btn) begin
            if (debounce_cnt < 20'd1_000_000)  // 10ms at 100MHz
                debounce_cnt <= debounce_cnt + 1;
            else
                btn_stable <= 1'b1;
        end else begin
            debounce_cnt <= 0;
            btn_stable <= 1'b0;
        end
        
        btn_prev <= btn_stable;
    end
    
    assign btn_edge = btn_stable & ~btn_prev;  // Rising edge pulse
    
    // FSM
    reg [3:0] current_op;
    
    always @(posedge clk) begin
        if (btn_edge) begin
            if (current_op == 4'b0110)  
                current_op <= 4'b0000;
            else
                current_op <= current_op + 1;
        end
    end
    
    wire [3:0] ALUControl = sw[15] ? sw[3:0] : current_op;
    
    // ALU
    wire [31:0] ALUResult;
    wire Zero;
    ALU alu(
        .A(A_FIXED),           
        .B(B_FIXED),           
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );

    assign led = ALUResult[15:0]; 

endmodule
