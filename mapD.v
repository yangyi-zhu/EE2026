`timescale 1ns / 1ps

module mapD(
    input clk,
    input isRunning,
    input clear, // btnC
    input btnU, btnD, btnL, btnR,
    input [12:0] pixel_index,
    output reg [15:0] col,
    output reg isDead,
    output reg hasWon = 0
    );
    
    localparam BORDER_WIDTH = 2;
    localparam TILE_WIDTH = 12;
    localparam AVATAR_DEFAULT = 8;
    localparam AVATAR_SMALL = 6;
    localparam OBS_WIDTH = 4;
    localparam SCREEN_WIDTH = 96;
    localparam SCREEN_HEIGHT = 64;
    
    localparam RED = 16'b11111_000000_00000;
    localparam GREEN = 16'b00000_111111_00000;
    localparam BLUE = 16'b00000_000000_11111;
    localparam GRAY30 = 16'b01001_010100_01001;
    localparam GRAY75 = 16'b11000_110001_11000;
    
    localparam PURPLE = 16'b11111_000000_11111;
    localparam GOLD = 16'b11111_110010_00100;
    localparam CYAN = 16'b01111_111111_11110;
    localparam LAVENDER = 16'b11111_101100_11111;
    localparam LIGHT_BLUE = 16'b10100_110101_11111;
        
    localparam BLACK = 16'h0000;
    localparam WHITE = 16'hFFFF;
    
    wire reset;
    reg death_reset;
    assign reset = clear | isDead;
    
    wire [6:0] x;
    wire [5:0] y;
    
    wire speed_avatar;
    wire speed_avatar_normal; // 30 Hz
    wire speed_avatar_small; //60 Hz
    wire speed_boxes; // 20 Hz
    wire speed_gate; // 4 Hz
    wire death_delay; // 1 Hz
    reg [1:0] counter;
    
    // Tracking top left corner of avatar
    reg [6:0] posx = 4;
    reg [5:0] posy = 4;
    
    reg [6:0] box1_x = 39;
    reg [5:0] box1_y = 23;
    
    reg [6:0] box2_x = 53;
    reg [5:0] box2_y = 35;
    
    reg [6:0] box3_x = 4;
    reg [5:0] box3_y = 29;
    reg box3_d = 0; // 0 rightward, 1 leftward
    
    reg [6:0] gatex = 12;
    reg [5:0] gatey = 49;
    
    reg killed = 0;
    reg outside = 1;
    reg hasTeleported = 0;
    reg isPicked = 0;
    
    wire [15:0] bgcol; 
    assign bgcol = isPicked ? LIGHT_BLUE : LAVENDER;
    
    wire [3:0] AVATAR_WIDTH;
    assign AVATAR_WIDTH = outside ? AVATAR_DEFAULT : AVATAR_SMALL;
    
    wire death_box1;
    assign death_box1 = !(posx + AVATAR_WIDTH < box2_x || posx > box1_x + OBS_WIDTH 
            || posy + AVATAR_WIDTH < box1_y || posy > box1_y + OBS_WIDTH);
    wire death_box2;
    assign death_box2 = !(posx + AVATAR_WIDTH < box2_x || posx > box2_x + OBS_WIDTH
            || posy + AVATAR_WIDTH < box2_y || posy > box2_y + OBS_WIDTH);
    wire death_box3;
    assign death_box3 = !(posx + AVATAR_WIDTH <= box3_x || posx >= box3_x + OBS_WIDTH
            || posy + AVATAR_WIDTH <= box3_y || posy >= box3_y + OBS_WIDTH);
    wire death_box4; 
    assign death_box4 = !(posx + AVATAR_WIDTH <= box3_x + 66 || posx >= box3_x + OBS_WIDTH + 66
            || posy + AVATAR_WIDTH <= box3_y || posy >= box3_y + OBS_WIDTH);
    
    assign x = pixel_index % SCREEN_WIDTH;
    assign y = pixel_index / SCREEN_WIDTH;
    
    assign speed_avatar = outside ? speed_avatar_normal : speed_avatar_small;
    clock_divider clk30Hz (clk, 1666666, speed_avatar_normal);
    clock_divider clk60Hz (clk, 833333, speed_avatar_small);
    clock_divider clk20Hz (clk, 2499999, speed_boxes);
    clock_divider clk4Hz (clk, 12499999, speed_gate);
    
    // Gray sections
    wire wall;
    assign wall = x < BORDER_WIDTH || x >= SCREEN_WIDTH - BORDER_WIDTH // Vertical
            || y < BORDER_WIDTH || y >= SCREEN_HEIGHT - BORDER_WIDTH; // Horizontal
    wire inside_block; 
    assign inside_block = (x >= 12 && x <= 66 && y >= 12 && y <= 51)
            || (x >= 63 && x <= 66 && y >= 52 && y <= 61)
            || (x >= 67 && x <= 81 && y >= 12 && y <= 31)
            || (x >= 79 && x <= 93 && y >= 38 && y <= 47);
    // Purple TP pads        
    wire tp_pad;
    assign tp_pad = (x >= 53 && x <= 62 && y >= 52 && y <= 61);
    // Spike wall
    wire spikes;
    assign spikes = (x == 67 && y >= 32 && y <= 61) || (x == 78 && y >= 38 && y <= 47)
            || (x == 82 && y >= 12 && y <= 31) || (x == 93 && y >= 2 && y <= 37);
    // Gold key
    wire gold_key;
    assign gold_key = (x >= 3 && x <= 5 && y == 6) || (x >= 3 && x <= 10 && x != 4 && y == 7)
            || (x >= 3 && x <= 9 && x != 6 && x != 8 && y == 8);        
    // Deco text
    wire deco_text;
    assign deco_text = ((y == 27 || y == 31) && (x >= 25 && x <= 53 && x != 29 && x != 34 && x != 39 && x != 44 && x != 49))
            || (y == 29 && x >= 25 && x <= 53 && x != 29 && x != 34 && x != 39 && x != 41 && x != 42 && x != 44 && x != 49)
            || (y == 28 && (x == 25 || x == 30 || x == 38 || x == 40 || x == 43 || x == 48 || x == 50))
            || (y == 30 && (x == 25 || x == 30 || x == 35 || x == 40 || x == 43 || x == 45 || x == 50 || x == 53));
    // Magic wand glint
    wire wand_glint;
    assign wand_glint = (y == 29 && x == 50) || (y == 28 && x == 47)
            || (y == 28 && (x == 49 || x == 52)) || (y == 31 && x == 52) || (y == 32 && x == 50);
    // Magic wand stick
    wire wand_stick;
    assign wand_stick = (y == 30 && x == 49) || (y == 31 && x == 48) || (y == 32 && x == 47)
            || (y == 33 && x == 46) || (y == 34 && x == 45) || (y == 35 && x == 44) || (y == 36 && x == 43);
    
    // Left wall: x 28-35 / y < 44
    // Right wall: x 60-67 / y >= 20
    always @(posedge speed_avatar) begin
        if (!isRunning | reset) begin
            outside <= 1;
            killed <= 0;
            hasTeleported <= 0;
            isPicked <= 0;
            posx <= 4;
            posy <= 4;
            hasWon <= 0;
        end
    
        else if (outside) begin
            if (btnR && (posx < 28 - AVATAR_WIDTH // Before left wall
                    || (posx < 36 - AVATAR_WIDTH && posy >= 44) // Below left wall
                    || (posx >= 36 - AVATAR_WIDTH && posx < 60 - AVATAR_WIDTH) // Between walls
                    || (posx >= 60 - AVATAR_WIDTH && posx < SCREEN_WIDTH - BORDER_WIDTH - AVATAR_WIDTH // Above right wall
                    && (posy <= 20 - AVATAR_WIDTH || posx >= 68)))) begin // Past right wall
                posx <= posx + 1;
            end if (btnL && ((posx > BORDER_WIDTH && posx < 36 && posy > 15) // Left Lower
                    || (posy < 16 && posx <= 28 && ((isPicked && posx > 16) || (!isPicked && posx > BORDER_WIDTH))) // Left Upper
                    || (posx > 36 && posx < 68) // Center
                    || (posx == 68 && posy <= 20 - AVATAR_WIDTH) || (posx == 36 && posy >= 44)// Wall boundary
                    || (posx > 68))) begin // Right
                posx <= posx - 1;
            end if (btnU && ((posy > 44) // Under left wall
                    || (posy > BORDER_WIDTH && posx > 35) // Center & Right
                    || (posy > BORDER_WIDTH && posx <= 28 - AVATAR_WIDTH && (posx > 15 || !isPicked)) // Left Open
                    || (isPicked && posx < 16 && posy > 16))) begin // Left Under
                posy <= posy - 1;
            end if (btnD && ((posy < 20 - AVATAR_WIDTH) // Above right wall
                    || (isPicked && posx <= 14 - AVATAR_WIDTH)
                    || (posy < SCREEN_HEIGHT - BORDER_WIDTH - AVATAR_WIDTH 
                    && (posx <= 60 - AVATAR_WIDTH || posx > 67)))) begin // Elsewhere
                posy <= posy + 1;
            end
            // Teleport check
            if (posx > 82 - AVATAR_WIDTH && posy > 50 - AVATAR_WIDTH && !hasTeleported) begin
                hasTeleported <= 1;
                posx <= 85;
                posy <= 53;
                outside <= 0;
            end
            if (isPicked && posx < 16 && (posy > 58 || posy < 8)) hasWon <= 1;
        end else begin
            if (btnR && ((posx > 66 && posx < SCREEN_WIDTH - BORDER_WIDTH - AVATAR_WIDTH && posy >= 48 && posy <= SCREEN_HEIGHT - BORDER_WIDTH - AVATAR_WIDTH)
                    || (posx > 66 && posx < 79 - AVATAR_WIDTH && posy >= 33 && posy <= 47) || (posx > 66 && posx < SCREEN_WIDTH - BORDER_WIDTH - AVATAR_WIDTH && posy <= 32)
                    || (posy <= 12 - AVATAR_WIDTH && posx < (isPicked ? 12 - AVATAR_WIDTH : SCREEN_WIDTH - BORDER_WIDTH - AVATAR_WIDTH))
                    || (posx < 12 - AVATAR_WIDTH && posy > 12 - AVATAR_WIDTH) || (posx < 54 && posy >= 52)))
                posx <= posx + 1;
            if (btnL && ((posx < 60 && posx > BORDER_WIDTH) || (posx > BORDER_WIDTH && posy <= 12 - AVATAR_WIDTH)
                    || (posx > 82 && posy > 12 - AVATAR_WIDTH && posy < 32) || (posx > 67 && posy >= 32)))
                posx <= posx - 1;
            if (btnU && ((posy > BORDER_WIDTH && (posy < 12 || posx >= 82 && posy <= 32))
                    || (posx >= 67 && (posy > 48 || (posx <= 79 - AVATAR_WIDTH && posy > 32)))
                    || (posx <= 12 - AVATAR_WIDTH && ((posy > BORDER_WIDTH && (posy < 51 || gatey >= 8) || posy > 51)))
                    || (posx < 60 && posy > 52)))
                posy <= posy - 1;
            if (btnD && ((posx > 12 - AVATAR_WIDTH && posx < 82 && posy < 12 - AVATAR_WIDTH)
                    || ((posx <= 12 - AVATAR_WIDTH && posy > 49 - AVATAR_WIDTH) && posy < SCREEN_HEIGHT - BORDER_WIDTH - AVATAR_WIDTH) 
                    || (posx <= 12 - AVATAR_WIDTH && posy < 49 - AVATAR_WIDTH)
                    || (posx <= 12 - AVATAR_WIDTH && posy == 49 - AVATAR_WIDTH && gatex >= 8)
                    || (posx > 81 && posy < 32) || (posx <= 78 - AVATAR_WIDTH && posy == 32)))
                posy <= posy + 1;
            // Teleport check
            if (posx > 53 - AVATAR_WIDTH && posx < 63 - AVATAR_WIDTH && posy > 51) begin
                posx <= 84;
                posy <= 52;
                outside <= 1;
            end
            // Key check
            if (posx <= 12 - AVATAR_WIDTH && posy <= 12 - AVATAR_WIDTH && !isPicked) isPicked <= 1;
            // Death check
            if ((gatex < 8 && posy <= 51 && posy > 49 - AVATAR_WIDTH && posx <= 12 - AVATAR_WIDTH) 
                    || (posx == 94 - AVATAR_WIDTH && posy >= 2 && posy <= 37)
                    || (posx == 82 && posy > 12 - AVATAR_WIDTH && posy <= 31)
                    || (posx == 79 - AVATAR_WIDTH && posy > 32 && posy <= 47)
                    || (posx == 67 && posy >= 32 && posy <= 61)) begin
                killed <= 1;
            end
        end
    end
    
    always @(posedge speed_boxes) begin
        // Revolving
        if (!isPicked) begin
            if (box1_x == 39 && box1_y != 35) begin
                box1_y <= box1_y + 1;
                box2_y <= box2_y - 1;
            end else if (box1_x == 53 && box1_y != 23) begin
                box1_y <= box1_y - 1;
                box2_y <= box2_y + 1;
            end else if (box1_x != 53 && box1_y == 35) begin
                box1_x <= box1_x + 1;
                box2_x <= box2_x - 1;
            end else if (box1_x != 39 && box1_y == 23) begin
                box1_x <= box1_x - 1;
                box2_x <= box2_x + 1;
            end 
            
            // Horizontal
            if (box3_d) begin 
                box3_x <= box3_x - 1;
                box3_d <= box3_x != 5;
            end else begin
                box3_x <= box3_x + 1;
                box3_d <= box3_x == 22 - OBS_WIDTH;
            end
        end else begin
            box1_x <= 39;
            box1_y <= 23;
            
            box2_x <= 53;
            box2_y <= 35;
        end
    end
    
    always @(posedge speed_gate) begin
        if (isPicked && gatex > 2) gatex <= gatex - 1; 
        if (!isRunning | reset) gatex <= 12;
    end
    
    always @(posedge clk) begin
        if (outside) begin
            if (x >= posx && x < posx + AVATAR_WIDTH && y >= posy && y < posy + AVATAR_WIDTH) begin
                col = RED;
            end else if (isPicked && x >= 2 && x <= 13 && (y == 0 || y == 1 || y == 62 || y == 63)) begin
                col = WHITE;
            end else if (wall || (x >= 28 && x < 36 && y < 44) || (x >= 60 && x < 68 && y >= 20)
                    || (isPicked && (((x == 14 || x == 15) && y >= 2 && y <= 15) || ((y == 14 || y == 15) && x >= 2 && x <= 15)))) begin // Walls
                col = GRAY30;
            end else if ((x >= box1_x && x < box1_x + OBS_WIDTH && y >= box1_y && y < box1_y + OBS_WIDTH)
                    || (x >= box2_x && x < box2_x + OBS_WIDTH && y >= box2_y && y < box2_y + OBS_WIDTH)
                    || (x >= box3_x && x < box3_x + OBS_WIDTH && y >= box3_y && y < box3_y + OBS_WIDTH)
                    || (x >= box3_x + 66 && x < box3_x + OBS_WIDTH + 66 && y >= box3_y && y < box3_y + OBS_WIDTH)) begin
                col = BLUE;
            end else if (x < TILE_WIDTH + BORDER_WIDTH && y < TILE_WIDTH + BORDER_WIDTH) begin
                col = GREEN;
            end else if (!isPicked && x >= SCREEN_WIDTH - TILE_WIDTH - BORDER_WIDTH && y >= SCREEN_HEIGHT - TILE_WIDTH - BORDER_WIDTH) begin
                col = PURPLE;
            end else if (wand_glint) begin
                col = GOLD;
            end else if (wand_stick) begin
                col = BLACK;
            end else begin
                col = bgcol;
            end
        end

        // Inside
        else if (deco_text)
            col = GRAY75;
        else if (wall | inside_block)
            col = WHITE;
        else if ((!isPicked && (x >= 2 && x <= 11 && y >= 49 && y <= 51))
                || (isPicked && ((x >= 12 && x <= 14 && y >= 2 && y <= 11)
                || (x >= gatex && x <= gatex + 9 && y >= gatey && y <= gatey + 2))))
            col = GRAY30;
        else if (x >= posx && x < posx + AVATAR_WIDTH && y >= posy && y < posy + AVATAR_WIDTH)
            col = CYAN;
        else if (spikes)
            col = RED;
        else if (gold_key)
            col = isPicked ? BLACK : GOLD;
        else if (tp_pad)
            col = PURPLE;
        else col = BLACK;
    end
    
    reg hasDied = 0;
    reg [25:0] death_timer = 0;
    
    always @(posedge clk) begin
        if (clear || !isRunning) begin
            isDead <= 0;
            hasDied <= 0;
            death_timer <= 0;
        end
    
        else if (!hasDied && (outside && (death_box1 || death_box2 || death_box3 || death_box4) || killed)) begin
            isDead <= 1;
            hasDied <= 1;
            death_timer <= 0;
        end
    
        else if (hasDied) begin
            if (death_timer < 50_000_000) begin
                death_timer <= death_timer + 1;
            end else begin
                isDead <= 0;
                hasDied <= 0;
                death_timer <= 0;
            end
        end
    end
endmodule
