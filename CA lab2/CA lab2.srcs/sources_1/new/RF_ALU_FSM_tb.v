`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2026 01:23:29 PM
// Design Name: 
// Module Name: RF_ALU_FSM_tb
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


module RF_ALU_FSM_tb;
    // Clock
    reg clk;
    initial clk = 0;
    always #5 clk = ~clk;
    // Register File 
    reg        WriteEnable;
    reg [4:0]  ReadReg1, ReadReg2, WriteReg;
    reg [31:0] WriteData;
    wire [31:0] ReadData1, ReadData2;

    // ALU signals
    reg  [3:0]  ALUControl;
    wire [31:0] ALUResult;
    wire        Zero;
    
    RegisterFile regf_inst (
        .clk        (clk),
        .rst        (rst),
        .WriteEnable(WriteEnable),
        .ReadReg1   (ReadReg1),
        .ReadReg2   (ReadReg2),
        .WriteReg   (WriteReg),
        .WriteData  (WriteData),
        .ReadData1  (ReadData1),
        .ReadData2  (ReadData2)
    );

    ALU alu (
        .A         (ReadData1),
        .B         (ReadData2),
        .ALUControl(ALUControl),
        .ALUResult (ALUResult),
        .Zero      (Zero)
    );

    // FSM states
    localparam IDLE            = 3'd0;
    localparam WRITE_REGS      = 3'd1;
    localparam READ_REGISTERS  = 3'd2;
    localparam ALU_OPERATION   = 3'd3;
    localparam WRITE_REGISTERS = 3'd4;
    localparam DONE            = 3'd5;

    reg [2:0] state;
    reg [1:0] init_idx;
    reg [3:0] op;
    reg [4:0] dest;
    reg [31:0] result_latch;

    reg rst;

    initial begin
        $dumpfile("RF_ALU_FSM_tb.vcd");
        $dumpvars(0, RF_ALU_FSM_tb);

        // initialise all signals
        rst         = 1;
        WriteEnable = 0;
        ReadReg1    = 0;
        ReadReg2    = 0;
        WriteReg    = 0;
        WriteData   = 0;
        ALUControl  = 4'b0011;
        state       = IDLE;
        init_idx    = 0;
        op          = 0;
        dest        = 0;
        result_latch= 0;

        @(posedge clk); #1;
        @(posedge clk); #1;
        rst = 0;

        // IDLE
        state = IDLE;
        @(posedge clk); #1;

        // WRITE_REGS: write x1, x2, x3 
        state = WRITE_REGS;

        WriteEnable = 1;
        WriteReg = 5'd1; WriteData = 32'h10101010;
        @(posedge clk); #1;

        WriteReg = 5'd2; WriteData = 32'h01010101;
        @(posedge clk); #1;

        WriteReg = 5'd3; WriteData = 32'h00000005;
        @(posedge clk); #1;
        WriteEnable = 0;

        // Loop: READ -> ALU -> WRITE 
        begin : op_loop
            integer i;
            for (i = 0; i <= 6; i = i + 1) begin
                op = i;

                // READ_REGISTERS
                state = READ_REGISTERS;
                case (i)
                    0: begin ReadReg1=5'd1; ReadReg2=5'd2; ALUControl=4'b0011; dest=5'd4;  end // ADD
                    1: begin ReadReg1=5'd1; ReadReg2=5'd2; ALUControl=4'b0100; dest=5'd5;  end // SUB
                    2: begin ReadReg1=5'd1; ReadReg2=5'd2; ALUControl=4'b0000; dest=5'd6;  end // AND
                    3: begin ReadReg1=5'd1; ReadReg2=5'd2; ALUControl=4'b0001; dest=5'd7;  end // OR
                    4: begin ReadReg1=5'd1; ReadReg2=5'd2; ALUControl=4'b0010; dest=5'd8;  end // XOR
                    5: begin ReadReg1=5'd1; ReadReg2=5'd3; ALUControl=4'b0101; dest=5'd9;  end // SLL
                    6: begin ReadReg1=5'd1; ReadReg2=5'd3; ALUControl=4'b0110; dest=5'd10; end // SRL
                endcase
                @(posedge clk); #1;

                // ALU_OPERATION
                state = ALU_OPERATION;
                result_latch = ALUResult;
                @(posedge clk); #1;

                // WRITE_REGISTERS
                state       = WRITE_REGISTERS;
                WriteEnable = 1;
                WriteReg    = dest;
                WriteData   = result_latch;
                @(posedge clk); #1;
                WriteEnable = 0;
            end
        end

        //BEQ CHECK: SUB x1-x1, Zero->x11 
        op = 7;
        state      = READ_REGISTERS;
        ReadReg1   = 5'd1; ReadReg2 = 5'd1;
        ALUControl = 4'b0100; // SUB
        dest       = 5'd11;
        @(posedge clk); #1;

        state        = ALU_OPERATION;
        result_latch = ALUResult;
        @(posedge clk); #1;

        state       = WRITE_REGISTERS;
        WriteEnable = 1;
        WriteReg    = 5'd11;
        WriteData   = (Zero ? 32'd1 : 32'd0);
        @(posedge clk); #1;
        WriteEnable = 0;

        //  write x12, read back next cycle 
        op = 8;
        state       = WRITE_REGISTERS;
        WriteEnable = 1;
        WriteReg    = 5'd12;
        WriteData   = 32'hCAFECAFE;
        @(posedge clk); #1;
        WriteEnable = 0;

        // Read x12 back - one cycle later 
        op       = 9;
        state    = READ_REGISTERS;
        ReadReg1 = 5'd12;
        ReadReg2 = 5'd0;
        @(posedge clk); #1;

        state = ALU_OPERATION;
        @(posedge clk); #1;

        // DONE 
        state = DONE;
        repeat(5) @(posedge clk);

        $finish;
    end

endmodule