`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/17/2026 12:13:48 PM
// Design Name: 
// Module Name: ALU_tb
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


module ALU_tb;
    reg  [31:0] A;
    reg  [31:0] B;
    reg  [3:0] ALUControl;
    wire [31:0] ALUResult;
    wire Zero;
    
    ALU alu_instance (
        .A(A),
        .B(B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .Zero(Zero)
    );
    
        initial begin
        //AND
        A = 32'hFFFF0000; B = 32'hFF00FF00; ALUControl = 4'b0000; #10;
        // OR
        A = 32'hFFFF0000; B = 32'hFF00FF00; ALUControl = 4'b0001; #10;
        //XOR
        A = 32'hFFFF0000; B = 32'hFF00FF00; ALUControl = 4'b0010; #10;
        //  ADD
        A = 32'h00000005; B = 32'h00000003; ALUControl = 4'b0011; #10; //5+3=8
        // SUB
        A = 32'h00000008; B = 32'h00000003; ALUControl = 4'b0100; #10; //8-3=5
        //SLL
        A = 32'h0000000F; B = 32'h00000004; ALUControl = 4'b0101; #10; 
        //SRL
        A = 32'hF0000000; B = 32'h00000004; ALUControl = 4'b0110; #10; 
        // Zero flag test 
        A = 32'h00000005; B = 32'h00000005; ALUControl = 4'b0100; #10;  // 5-5=0, zero = 1   
        #10 $finish;
    end
    
endmodule


