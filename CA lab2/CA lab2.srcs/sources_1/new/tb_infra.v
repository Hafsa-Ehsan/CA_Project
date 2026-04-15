`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/01/2026 09:15:48 AM
// Design Name: 
// Module Name: tb_infra
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


module tb_infra;

    reg         clk, rst, PCSrc;
    reg  [31:0] instruction;

    wire [31:0] PC, nextPC, PC_plus4, branchTarget, imm;

    program_counter pc_inst (
        .clk(clk), .rst(rst),
        .nextPC(nextPC), .PC(PC)
    );

    pcAdder pc_add (
        .PC(PC), .PC_plus4(PC_plus4)
    );

    immGen imm_gen (
        .instruction(instruction), .imm(imm)
    );

    branchAdder br_add (
        .PC(PC), .imm(imm), .branchTarget(branchTarget)
    );

    mux2 pc_mux (
        .in0(PC_plus4), .in1(branchTarget),
        .sel(PCSrc), .out(nextPC)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_infra.vcd");
        $dumpvars(0, tb_infra);

        // Initialize
        rst = 1; 
        PCSrc = 0; 
        instruction = 32'b0;
        
        // Hold reset for 2 clock cycles to ensure proper initialization
        repeat(2) @(posedge clk);
        rst = 0;
        
        @(posedge clk);

        // Test 1: Sequential - PC increments by 4 each cycle
        PCSrc = 0; 
        instruction = 32'b0;
        repeat(4) @(posedge clk);

        // Test 2: Branch taken - BEQ with offset +8
        instruction = 32'h00000463;
        PCSrc = 1;
        @(posedge clk);

        // Test 3: I-type imm = +15
        PCSrc = 0;
        instruction = 32'h00F00093;
        @(posedge clk);

        // Test 4: I-type imm = -1
        instruction = 32'hFFF00093;
        @(posedge clk);

        // Test 5: S-type imm = +8
        instruction = 32'h00112423;
        @(posedge clk);

        #20; 
        $finish;
    end

endmodule