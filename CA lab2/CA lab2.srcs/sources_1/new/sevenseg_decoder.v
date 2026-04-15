`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/03/2026 10:28:03 PM
// Design Name: 
// Module Name: sevenseg_decoder
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

//module sevenseg_decoder (
//    input  wire        clk,
//    input  wire        rst,
//    input  wire [15:0] value,
//    output reg  [3:0]  an,
//    output reg  [6:0]  seg
//);
//    reg [17:0] clk_div;
//    reg [1:0]  digit_sel;

//    always @(posedge clk or posedge rst) begin
//        if (rst) begin
//            clk_div   <= 0;
//            digit_sel <= 0;
//        end else begin
//            if (clk_div == 18'd99999) begin
//                clk_div   <= 0;
//                digit_sel <= digit_sel + 1;
//            end else
//                clk_div <= clk_div + 1;
//        end
//    end

//    reg [3:0] nibble;

//    // Single always block drives BOTH an and nibble - no multiple drivers
//    always @(*) begin
//        case (digit_sel)
//            2'b00: begin an = 4'b1110; nibble = value[3:0];  end
//            2'b01: begin an = 4'b1101; nibble = value[7:4];  end
//            2'b10: begin an = 4'b1011; nibble = value[11:8]; end
//            2'b11: begin an = 4'b0111; nibble = value[15:12];end
//            default: begin an = 4'b1111; nibble = 4'h0;      end
//        endcase
//    end

//    always @(*) begin
//        case (nibble)
//            4'h0: seg = 7'b1000000;
//            4'h1: seg = 7'b1111001;
//            4'h2: seg = 7'b0100100;
//            4'h3: seg = 7'b0110000;
//            4'h4: seg = 7'b0011001;
//            4'h5: seg = 7'b0010010;
//            4'h6: seg = 7'b0000010;
//            4'h7: seg = 7'b1111000;
//            4'h8: seg = 7'b0000000;
//            4'h9: seg = 7'b0010000;
//            4'hA: seg = 7'b0001000;
//            4'hB: seg = 7'b0000011;
//            4'hC: seg = 7'b1000110;
//            4'hD: seg = 7'b0100001;
//            4'hE: seg = 7'b0000110;
//            4'hF: seg = 7'b0001110;
//            default: seg = 7'b1111111;
//        endcase
//    end
//endmodule



module sevenseg_decoder (

    input  wire        clk,
    input  wire        rst,
    input  wire [15:0] value,
    output reg  [3:0]  an,
    output reg  [6:0]  seg
);
    // 100MHz: divide by 50000 = 2kHz digit switch = 500Hz refresh
    // Sweet spot for Basys3 - no flicker, clean display
    reg [15:0] clk_div;
    reg [1:0]  digit_sel;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            clk_div   <= 0;
            digit_sel <= 0;
        end else begin
            if (clk_div == 16'd49999) begin
                clk_div   <= 0;
                digit_sel <= digit_sel + 1;
            end else
                clk_div <= clk_div + 1;
        end
    end

    reg [3:0] nibble;

    always @(*) begin
        case (digit_sel)
            2'b00: begin an = 4'b1110; nibble = value[3:0];   end
            2'b01: begin an = 4'b1101; nibble = value[7:4];   end
            2'b10: begin an = 4'b1011; nibble = value[11:8];  end
            2'b11: begin an = 4'b0111; nibble = value[15:12]; end
            default: begin an = 4'b1111; nibble = 4'h0;       end
        endcase
    end

    always @(*) begin
        case (nibble)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end
endmodule





