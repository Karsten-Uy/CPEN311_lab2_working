interface top_if;

    logic CLOCK_50; 
    logic [3:0] KEY;
    logic [9:0] SW; 
    logic [9:0] LEDR;
    logic [6:0] HEX0; 
    logic [6:0] HEX1;
    logic [6:0] HEX2;
    logic [6:0] HEX3; 
    logic [6:0] HEX4; 
    logic [6:0] HEX5;
    logic [7:0] VGA_R; 
    logic [7:0] VGA_G; 
    logic [7:0] VGA_B;
    logic VGA_HS; 
    logic VGA_VS; 
    logic VGA_CLK;
    logic [7:0] VGA_X; 
    logic [6:0] VGA_Y;
    logic [2:0] VGA_COLOUR; 
    logic VGA_PLOT;

endinterface


interface top_visual_if;

    logic CLOCK_50; 
    logic [3:0] KEY;
    logic [9:0] SW; 
    logic [9:0] LEDR;
    logic [6:0] HEX0; 
    logic [6:0] HEX1;
    logic [6:0] HEX2;
    logic [6:0] HEX3; 
    logic [6:0] HEX4; 
    logic [6:0] HEX5;
    logic [7:0] VGA_R; 
    logic [7:0] VGA_G; 
    logic [7:0] VGA_B;
    logic VGA_HS; 
    logic VGA_VS; 
    logic VGA_CLK;
    logic [7:0] VGA_X; 
    logic [6:0] VGA_Y;
    logic [2:0] VGA_COLOUR; 
    logic VGA_PLOT;

    logic [7:0] centre_x;
    logic [6:0] centre_y;
    logic [7:0] radius;
    logic [2:0] colour;

endinterface