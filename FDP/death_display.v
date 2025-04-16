`timescale 1ns / 1ps

module death(
    input clk,
    input [12:0] pixel_index,
    output reg [15:0] oled_data
    );
    
    localparam SCREEN_WIDTH = 96;
    localparam GRAY50 = 16'b01111_011111_01111;
    localparam BLACK = 16'h0000;
    localparam WHITE = 16'hFFFF;
    
    wire [6:0] x;
    wire [5:0] y;
    wire [13:0] row_white;
    wire gray_pixels;
    
    assign x = pixel_index % SCREEN_WIDTH;
    assign y = pixel_index / SCREEN_WIDTH;
    
    assign row_white[0] = y == 25 && (x == 7 || x == 88);
    assign row_white[1] = y == 26 && (x == 8 || x == 9 || x == 86 || x == 87);
    assign row_white[2] = y == 27 && ((x >= 8 && x <= 11) || (x >= 84 && x <= 87));
    assign row_white[3] = y == 28 && ((x >= 8 && x <= 13) || (x >= 82 && x <= 87));
    assign row_white[4] = y == 29 && ((x >= 9 && x <= 15) || (x >= 80 && x <= 86) || x == 23 || x == 28 || x == 33 || x == 34
        || x == 39 || x == 45 || (x >= 50 && x <= 52) || x == 58 || (x >= 60 && x <= 64) || (x >= 67 && x <= 69));
    assign row_white[5] = y == 30 && (x == 8 || (x >= 12 && x <= 16) || x == 23 || x == 27 || x == 31 || x == 36 || x == 39
        || x == 45 || x == 50 || x == 54 || x == 58 || x == 60 || x == 67 || x == 71 || (x >= 79 && x <= 83) || x == 87);
    assign row_white[6] = y == 31 && ((x >= 7 && x <= 17) || x == 24 || x == 27 || x == 30 || x == 36 || x == 37 || x == 39
        || x == 45 || x == 50 || x == 55 || x == 58 || x == 60 || x == 67 || x == 72 || (x >= 78 && x <= 88));
    assign row_white[7] = y == 32 && ((x >= 7 && x <= 17) || x == 24 || x == 26 || x == 30 || x == 37 || x == 39 || x == 45
        || x == 50 || x == 55 || x == 58 || x == 60 || x == 67 || x == 72 || (x >= 78 && x <= 88));
    assign row_white[8] = y == 33 && ((x >= 8 && x <= 12) || (x >= 16 && x <= 18) || x == 25 || x == 26 || x == 30 || x == 37 || x == 39 
        || x == 45 || x == 50 || x == 55 || x == 58 || (x >= 60 && x <= 64) || x == 67 || x == 72 || (x >= 77 && x <= 79) || (x >= 83 && x <= 87));
    assign row_white[9] = y == 34 && (x == 10 || x == 11 || (x >= 13 && x <= 15) || x == 17 || x == 18 || x == 25 || x == 30 || x == 37 || x == 39 
        || x == 45 || x == 50 || x == 55 || x == 56 || x == 58 || x == 60 || x == 67 || x == 72 || x == 73 || x == 77 || x == 78
        || (x >= 80 && x <= 82) || x == 84 || x == 85);
    assign row_white[10] = y == 35 && ((x >= 8 && x <= 10) || (x >= 12 && x <= 15) || x == 17 || x == 18 || x == 25 || x == 30 || x == 36 || x == 37
        || x == 39 || x == 45 || x == 50 || x == 55 || x == 58 || x == 60 || x == 67 || x == 72 || x == 77 || x == 78
        || (x >= 80 && x <= 83) || (x >= 85 && x <= 87));
    assign row_white[11] = y == 36 && (x == 9 || x == 10 || (x >= 12 && x <= 14) || (x >= 16 && x <= 18) || x == 25 || x == 30 || x == 31 || x == 36
        || x == 39 || x == 40 || x == 44 || x == 50 || x == 54 || x == 55 || x == 58 || x == 60 || x == 67 || x == 71 || x == 72
        || (x >= 77 && x <= 79) || (x >= 81 && x <= 83) || x == 85 || x == 86);
    assign row_white[12] = y == 37 && ((x >= 12 && x <= 17) || x == 25 || (x >= 31 && x <= 35) || (x >= 40 && x <= 44) || (x >= 50 && x <= 54)
        || x == 58 || (x >= 60 && x <= 64) || (x >= 67 && x <= 71) || (x >= 78 && x <= 83));
    assign row_white[13] = y == 38 && ((x >= 13 && x <= 16) || (x >= 79 && x <= 82));
    
    assign gray_pixels = (y == 25 && (x == 6 || x == 89))
        || ((y == 26 || y == 27) && (x == 7 || x == 88))
        || (y == 29 && (x == 22 || x == 32 || x == 35 || x == 49 || x == 53 || x == 66 || x == 70))
        || (y == 30 && (x == 24 || x == 28 || x == 30 || x == 32 || x == 35 || x == 44 || x == 49
            || x == 53 || x == 55 || x == 61 || x == 66 || x == 70 || x == 72))
        || (y == 31 && (x == 23 || x == 31 || x == 44 || x == 49 || x == 54 || x == 61 || x == 66 || x == 71))
        || (y == 32 && (x == 27 || x == 36 || x == 44 || x == 49 || x == 56 || x == 61 || x == 66 || x == 73))
        || (y == 33 && (x == 24 || x == 44 || x == 49 || x == 56 || x == 66 || x == 73))
        || (y == 34 && (x == 26 || x == 36 || x == 44 || x == 49 || x == 61 || x == 66))
        || (y == 35 && (x == 26 || x == 44 || x == 49 || x == 61 || x == 66))
        || (y == 36 && (x == 26 || x == 35 || x == 45 || x == 49 || x == 61 || x == 66))
        || (y == 37 && (x == 26 || x == 36 || x == 49 || x == 66));
    
    always @(posedge clk) begin
        if (row_white) begin
            oled_data = WHITE;
        end else if (gray_pixels) begin
            oled_data = GRAY50;
        end else begin
            oled_data = BLACK;
        end
    end
endmodule
