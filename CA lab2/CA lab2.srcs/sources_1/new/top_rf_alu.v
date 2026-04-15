`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2026 10:23:29 PM
// Design Name: 
// Module Name: top_rf_alu
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


module top_rf_alu(
    input  wire clk,
    input  wire btnC,
    input  wire [15:0] sw,
    output wire [15:0] led,
    output wire [6:0]  seg,
    output wire [3:0]  an
);
    wire rst;
    debouncer db_rst (
        .clk  (clk),
        .pbin (btnC),
        .pbout(rst)
    );

   // switches 
    wire [31:0] sw_readData;
    wire [15:0] sw_led_mirror;
    switches sw_if (
        .clk        (clk),
        .rst        (rst),
        .writeData  (32'b0),
        .writeEnable(1'b0),
        .readEnable (1'b1),
        .memAddress (30'b0),
        .sw         (sw),
        .readData   (sw_readData),
        .leds       (sw_led_mirror)
    );
    // register file
    reg        WriteEnable;
    reg [4:0]  WriteReg;
    reg [31:0] WriteData;
    reg [4:0]  ReadReg1, ReadReg2;
    wire [31:0] ReadData1, ReadData2;

    RegisterFile rf (
        .clk        (clk),
        .rst        (rst),
        .WriteEnable(WriteEnable),
        .WriteReg   (WriteReg),
        .WriteData  (WriteData),
        .ReadReg1   (ReadReg1),
        .ReadData1  (ReadData1),
        .ReadReg2   (ReadReg2),
        .ReadData2  (ReadData2)
    );
  
    // ALU 
    reg  [3:0]  ALUControl;
    wire [31:0] ALUResult;
    wire        Zero;

    ALU alu (
        .A         (ReadData1),
        .B         (ReadData2),
        .ALUControl(ALUControl),
        .ALUResult (ALUResult),
        .Zero      (Zero)
    );

    // FSM state 
    localparam IDLE            = 3'd0;
    localparam WRITE_REGS      = 3'd1;
    localparam READ_REGISTERS  = 3'd2;
    localparam ALU_OPERATION   = 3'd3;
    localparam WRITE_REGISTERS = 3'd4;
    localparam DONE            = 3'd5;

    reg [2:0]  state;
    reg [1:0]  init_idx;
    reg [3:0]  op;
    reg [4:0]  dest;
    reg [31:0] result_latch;

    localparam A_CONST = 32'h10101010;
    localparam B_CONST = 32'h01010101;
    localparam S_CONST = 32'h00000005;

    // FSM
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= IDLE;
            WriteEnable  <= 0;
            WriteReg     <= 0;
            WriteData    <= 0;
            ReadReg1     <= 0;
            ReadReg2     <= 0;
            ALUControl   <= 4'b0011;
            init_idx     <= 0;
            op           <= 0;
            dest         <= 0;
            result_latch <= 0;
        end else begin

            if (sw[15]) begin
                state       <= IDLE;
                WriteEnable <= sw_readData[0];
                ALUControl  <= sw_readData[4:1];
                WriteReg    <= 5'd2;
                WriteData   <= A_CONST;
                ReadReg1    <= 5'd1;
                ReadReg2    <= 5'd2;

            end else begin
                case (state)

                    IDLE: begin
                        WriteEnable <= 0;
                        init_idx    <= 0;
                        op          <= 0;
                        state       <= WRITE_REGS;
                    end

                    // x1=A_CONST, x2=B_CONST, x3=S_CONST
                    WRITE_REGS: begin
                        WriteEnable <= 1;
                        case (init_idx)
                            2'd0: begin WriteReg<=5'd1; WriteData<=A_CONST; init_idx<=2'd1; end
                            2'd1: begin WriteReg<=5'd2; WriteData<=B_CONST; init_idx<=2'd2; end
                            2'd2: begin
                                WriteReg    <= 5'd3;
                                WriteData   <= S_CONST;
                                init_idx    <= 2'd0;
                                WriteEnable <= 0;
                                state       <= READ_REGISTERS;
                            end
                        endcase
                    end

                    //source regs and ALUControl per op
                    READ_REGISTERS: begin
                        WriteEnable <= 0;
                        case (op)
                            4'd0: begin ReadReg1<=5'd1; ReadReg2<=5'd2; ALUControl<=4'b0011; dest<=5'd4;  end // ADD
                            4'd1: begin ReadReg1<=5'd1; ReadReg2<=5'd2; ALUControl<=4'b0100; dest<=5'd5;  end // SUB
                            4'd2: begin ReadReg1<=5'd1; ReadReg2<=5'd2; ALUControl<=4'b0000; dest<=5'd6;  end // AND
                            4'd3: begin ReadReg1<=5'd1; ReadReg2<=5'd2; ALUControl<=4'b0001; dest<=5'd7;  end // OR
                            4'd4: begin ReadReg1<=5'd1; ReadReg2<=5'd2; ALUControl<=4'b0010; dest<=5'd8;  end // XOR
                            4'd5: begin ReadReg1<=5'd1; ReadReg2<=5'd3; ALUControl<=4'b0101; dest<=5'd9;  end // SLL
                            4'd6: begin ReadReg1<=5'd1; ReadReg2<=5'd3; ALUControl<=4'b0110; dest<=5'd10; end // SRL
                            default: begin ReadReg1<=5'd1; ReadReg2<=5'd2; ALUControl<=4'b0011; dest<=5'd4; end
                        endcase
                        state <= ALU_OPERATION;
                    end

                    // ALU result
                    ALU_OPERATION: begin
                        result_latch <= ALUResult;
                        state        <= WRITE_REGISTERS;
                    end

                    // result to destination register
                    WRITE_REGISTERS: begin
                        WriteEnable <= 1;
                        WriteReg    <= dest;
                        WriteData   <= result_latch;
                        if (op == 4'd6) begin
                            op    <= 0;
                            state <= DONE;
                        end else begin
                            op    <= op + 1;
                            state <= READ_REGISTERS;
                        end
                    end

                    // final result - ADD result shown on LEDs
                    DONE: begin
                        WriteEnable <= 0;
                        ReadReg1    <= 5'd4;
                        ReadReg2    <= 5'd5;
                        ALUControl  <= 4'b0011;
                        state       <= DONE;
                    end

                endcase
            end
        end
    end

    
    // LED output
    assign led[14:0] = ALUResult[14:0];
    assign led[15]   = Zero;

    wire [3:0] lower_nibble = ALUResult[3:0];
    wire [3:0] upper_nibble = ALUResult[7:4];

    reg [25:0] mux_counter;
    reg [3:0]  current_nibble;
    reg [3:0]  anode_reg;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mux_counter    <= 0;
            current_nibble <= 0;
            anode_reg      <= 4'b1110;
        end else begin
            mux_counter <= mux_counter + 1;
            if (mux_counter[16] == 0) begin
                current_nibble <= lower_nibble;
                anode_reg      <= 4'b1110;
            end else begin
                current_nibble <= upper_nibble;
                anode_reg      <= 4'b1101;
            end
        end
    end

    assign an = anode_reg;

    sevenseg_decoder ssd (
        .bin(current_nibble),
        .seg(seg)
    );

endmodule