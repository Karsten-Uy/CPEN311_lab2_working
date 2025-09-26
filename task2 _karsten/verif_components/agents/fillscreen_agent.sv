interface fillscreen_if;

    logic clk;
    logic rst_n;
    logic [2:0] colour;
    logic start;
    logic done;
    logic [7:0] vga_x;
    logic [6:0] vga_y;
    logic [2:0] vga_colour;
    logic vga_plot;
    
endinterface //fillscreen_if

