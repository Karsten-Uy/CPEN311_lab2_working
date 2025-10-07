
/* 
 * NOTE: This module is NOT synthesizable but meant to be used with 
 * the tb_rtl_task3_visual testbench to see what is being tested on
 * the fake VGA screen
 */

module task3_visual(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT,
             
             // Temp arguments for visualizatiob
             input logic [7:0] centre_x, 
             input logic [6:0] centre_y, 
             input logic [7:0] radius,
             input logic [2:0] colour
             );

    // instantiate and connect the VGA adapter and your module

    // NEED TO ADD THESE TO GET IT TO WORK ON DE1_SoC
    logic [9:0] VGA_R_10;
    logic [9:0] VGA_G_10;
    logic [9:0] VGA_B_10;
    logic VGA_BLANK, VGA_SYNC;
    assign VGA_R = VGA_R_10[9:2];
    assign VGA_G = VGA_G_10[9:2];
    assign VGA_B = VGA_B_10[9:2];

    logic [7:0] vga_x;
    logic [6:0] vga_y;
    logic [2:0] vga_colour;
    logic vga_plot;

    circle CIRCLE(
        .clk        (CLOCK_50),
        .rst_n      (KEY[3]),
        .colour     (colour),
        .centre_x   (centre_x),
        .centre_y   (centre_y),
        .radius     (radius),
        .start      (KEY[0]),
        .done       (LEDR[0]),
        .vga_x      (vga_x),
        .vga_y      (vga_y),
        .vga_colour (vga_colour),
        .vga_plot   (vga_plot)
    );

    // Internal Outputs
    assign VGA_X      = vga_x;
    assign VGA_Y      = vga_y;
    assign VGA_COLOUR = vga_colour;
    assign VGA_PLOT   = vga_plot;

    vga_adapter#(        
        .RESOLUTION("160x120")) vga_u0(
        .resetn(KEY[3]), 
        .clock(CLOCK_50), 
        .colour(vga_colour),
        .x(vga_x), 
        .y(vga_y), 
        .plot(vga_plot),
        .VGA_R(VGA_R_10), 
        .VGA_G(VGA_G_10), 
        .VGA_B(VGA_B_10),
        .*);


endmodule: task3_visual
