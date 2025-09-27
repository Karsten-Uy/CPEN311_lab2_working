module task2(input logic CLOCK_50, input logic [3:0] KEY,
             input logic [9:0] SW, output logic [9:0] LEDR,
             output logic [6:0] HEX0, output logic [6:0] HEX1, output logic [6:0] HEX2,
             output logic [6:0] HEX3, output logic [6:0] HEX4, output logic [6:0] HEX5,
             output logic [7:0] VGA_R, output logic [7:0] VGA_G, output logic [7:0] VGA_B,
             output logic VGA_HS, output logic VGA_VS, output logic VGA_CLK,
             output logic [7:0] VGA_X, output logic [6:0] VGA_Y,
             output logic [2:0] VGA_COLOUR, output logic VGA_PLOT);

    // instantiate and connect the VGA adapter and your module

    logic [7:0] vga_x;
    logic [6:0] vga_y;
    logic [2:0] vga_colour;
    logic vga_plot;

    fillscreen DISPLAY(
        .clk           (CLOCK_50),
        .rst_n         (KEY[3]),
        .colour        (),
        .start         (KEY[0]),
        .done          (LEDR[0]), // TODO: figure out where this goes
        .vga_x         (vga_x),
        .vga_y         (vga_y),
        .vga_colour    (vga_colour),
        .vga_plot      (vga_plot)
    );

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
        .VGA_HS(VGA_HS),
        .VGA_VS(VGA_VS),
        .VGA_BLANK(VGA_BLANK),
        .VGA_SYNC(VGA_SYNC),
        .VGA_CLK(VGA_CLK));

endmodule: task2
