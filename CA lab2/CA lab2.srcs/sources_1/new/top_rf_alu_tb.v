`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2026 10:41:56 PM
// Design Name: 
// Module Name: top_rf_alu_tb
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


`timescale 1ns/1ps

module top_rf_alu_tb;

    reg        clk;
    reg        btnC;
    reg [15:0] sw;
    wire [15:0] led;
    wire [6:0]  seg;
    wire [3:0]  an;

    // Instantiate top level DUT
    top_rf_alu DUT (
        .clk (clk),
        .btnC(btnC),
        .sw  (sw),
        .led (led),
        .seg (seg),
        .an  (an)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("top_rf_alu_tb.vcd");
        $dumpvars(0, top_rf_alu_tb);

        // =====================================================
        // INITIALISE all inputs
        // =====================================================
        sw   = 16'b0;
        btnC = 0;
        #10;

        // =====================================================
        // RESET - pulse btnC to trigger debouncer -> rst
        // =====================================================
        $display("=== RESET ===");
        btnC = 1; repeat(10) @(posedge clk); #1;
        btnC = 0; repeat(5)  @(posedge clk); #1;

        // =====================================================
        // TEST 1 + 2: FSM AUTO DEMO MODE  (sw[15]=0)
        //
        // FSM runs automatically after reset:
        //   IDLE(1) -> WRITE_REGS(3) -> [READ+ALU+WRITE]x7 -> DONE
        //
        // In DONE state: ReadReg1=x4 (ADD result)
        //   x1=0x10101010 + x2=0x01010101 = 0x11111111
        //   led[14:0] = 0x11111111 & 0x7FFF = 0x1111
        //   led[15]   = Zero = 0
        // =====================================================
        $display("=== FSM AUTO DEMO MODE (sw[15]=0) ===");
        sw = 16'b0;
        repeat(60) @(posedge clk); #1;

        $display("FSM state    = %0d  (expect 5 = DONE)",  DUT.state);
        $display("led[14:0]    = %h   (expect 1111)",      led[14:0]);
        $display("led[15] Zero = %0b  (expect 0)",         led[15]);

        if (DUT.state === 3'd5)
            $display("TEST 1 PASSED: FSM reached DONE state");
        else
            $display("TEST 1 FAILED: state = %0d (expected 5)", DUT.state);

        if (led[14:0] === 15'h1111)
            $display("TEST 2 PASSED: ADD result visible on LEDs");
        else
            $display("TEST 2 FAILED: led[14:0] = %h (expected 1111)", led[14:0]);

        repeat(5) @(posedge clk); #1;

        // =====================================================
        // MANUAL MODE TESTS  (sw[15]=1)
        //
        // In manual mode FSM stays IDLE.
        // ReadReg1 = x1 = 0x10101010 (hardcoded)
        // ReadReg2 = x2 = 0x01010101 (hardcoded)
        //
        // sw[4:1] = ALUControl
        // sw[0]   = WriteEnable
        //
        // ALU control codes (from ALU.v):
        //   AND=4'b0000  OR=4'b0001  XOR=4'b0010
        //   ADD=4'b0011  SUB=4'b0100 SLL=4'b0101 SRL=4'b0110
        //
        // Switch encoding:
        //   sw[15]=1, sw[4:1]=ALUControl, sw[0]=WE
        //   sw = 1000_0000_000X_XXX0
        //            15       4321  0
        // =====================================================
        $display("\n=== MANUAL MODE (sw[15]=1) ===");

        // --- ADD: ALUControl=0011, sw[4:1]=0011 ---
        // sw[15]=1, sw[4]=0, sw[3]=0, sw[2]=1, sw[1]=1, sw[0]=0
        // binary: 1000_0000_0000_0110
        sw = 16'b1000000000000110;
        repeat(5) @(posedge clk); #1;
        $display("ADD  led=%h  Zero=%b  (expect 1111, 0)", led[14:0], led[15]);
        if (led[14:0] === 15'h1111)
            $display("TEST 3 PASSED: Manual ADD correct");
        else
            $display("TEST 3 FAILED: got %h (expect 1111)", led[14:0]);

        // --- SUB: ALUControl=0100, sw[4:1]=0100 ---
        // binary: 1000_0000_0000_1000
        sw = 16'b1000000000001000;
        repeat(5) @(posedge clk); #1;
        $display("SUB  led=%h  Zero=%b  (expect 0f0f, 0)", led[14:0], led[15]);
        if (led[14:0] === 15'h0f0f)
            $display("TEST 4 PASSED: Manual SUB correct");
        else
            $display("TEST 4 FAILED: got %h (expect 0f0f)", led[14:0]);

        // --- AND: ALUControl=0000, sw[4:1]=0000 ---
        // AND of 0x10101010 & 0x01010101 = 0x00000000 -> Zero=1
        // binary: 1000_0000_0000_0000
        sw = 16'b1000000000000000;
        repeat(5) @(posedge clk); #1;
        $display("AND  led=%h  Zero=%b  (expect 0000, 1)", led[14:0], led[15]);
        if (led[14:0] === 15'h0000 && led[15] === 1'b1)
            $display("TEST 5 PASSED: Manual AND correct + Zero=1");
        else
            $display("TEST 5 FAILED: led=%h Zero=%b (expect 0000, 1)", led[14:0], led[15]);

        // --- OR: ALUControl=0001, sw[4:1]=0001 ---
        // binary: 1000_0000_0000_0010
        sw = 16'b1000000000000010;
        repeat(5) @(posedge clk); #1;
        $display("OR   led=%h  Zero=%b  (expect 1111, 0)", led[14:0], led[15]);
        if (led[14:0] === 15'h1111)
            $display("TEST 6 PASSED: Manual OR correct");
        else
            $display("TEST 6 FAILED: got %h (expect 1111)", led[14:0]);

        // --- XOR: ALUControl=0010, sw[4:1]=0010 ---
        // binary: 1000_0000_0000_0100
        sw = 16'b1000000000000100;
        repeat(5) @(posedge clk); #1;
        $display("XOR  led=%h  Zero=%b  (expect 1111, 0)", led[14:0], led[15]);
        if (led[14:0] === 15'h1111)
            $display("TEST 7 PASSED: Manual XOR correct");
        else
            $display("TEST 7 FAILED: got %h (expect 1111)", led[14:0]);

        // =====================================================
        // TEST 8 + 9: RESET restarts FSM cleanly
        // =====================================================
        $display("\n=== RESET THEN RESTART ===");
        sw   = 16'b0;
        btnC = 1; repeat(10) @(posedge clk); #1;
        btnC = 0; repeat(5)  @(posedge clk); #1;

        if (DUT.state === 3'd0)
            $display("TEST 8 PASSED: FSM back to IDLE after reset");
        else
            $display("TEST 8 FAILED: state=%0d (expect 0)", DUT.state);

        repeat(60) @(posedge clk); #1;

        if (DUT.state === 3'd5)
            $display("TEST 9 PASSED: FSM reached DONE again after restart");
        else
            $display("TEST 9 FAILED: state=%0d (expect 5)", DUT.state);

        $display("\n================================");
        $display("       ALL TESTS COMPLETE       ");
        $display("================================");
        #20 $finish;
    end

endmodule