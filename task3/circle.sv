module circle(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
              input logic start, output logic done,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);
     
     // ---------------- PACKAGE IMPORTS ----------------
     import lab_pkg::*;


     // FSM Signals
     logic unsigned       fill_start;
     logic unsigned       fill_done;
     logic unsigned       draw_circle;
     logic unsigned [2:0] octant_sel;
     logic unsigned       dec_x;
     logic unsigned       inc_y;
     logic unsigned       calc_crit;
     logic unsigned       load_x;
     logic unsigned       load_y;
     logic unsigned       load_crit;
     logic signed  [7:0]  offset_x;
     logic signed  [6:0]  offset_y;
     logic signed  [7:0]  crit;

     datapath #(
          .VGA_X_DW  (VGA_X_DW),
          .VGA_Y_DW  (VGA_Y_DW),  
          .RADIUS_DW (RADIUS_DW)
     ) DP (
          .clk         (clk),
          .resetn      (resetn),
          .radius      (radius),
          .centre_x    (centre_x),
          .centre_y    (centre_y),

          .fill_start  (fill_start),
          .fill_done   (fill_done),
          .draw_circle (draw_circle),
          .octant_sel  (octant_sel),
          .dec_x       (dec_x),
          .inc_y       (inc_y),
          .calc_crit   (calc_crit),
          .load_x      (load_x),
          .load_y      (load_y),
          .load_crit   (load_crit),
          .offset_x    (offset_x),
          .offset_y    (offset_y),
          .crit        (crit),

          .vga_x       (vga_x),
          .vga_y       (vga_y),
          .plot        (vga_plot)
     );

     circle_fsm #(
          .VGA_X_DW  (VGA_X_DW),
          .VGA_Y_DW  (VGA_Y_DW),  
          .RADIUS_DW (RADIUS_DW)
     ) CIRCLE_FSM (
          .clk         (clk),
          .rst_n       (rst_n),
          .colour      (colour),
          .centre_x    (centre_x),
          .centre_y    (centre_y),
          .radius      (radius),
          .start       (start),

          .curr_crit   (crit),
          .fill_done   (fill_done),
          .offset_x    (offset_x),
          .offset_y    (offset_y),

          .done        (done),
          .vga_colour  (vga_colour),

          .draw_circle (draw_circle),
          .octant_sel  (octant_sel),
          .fill_start  (fill_start),
          .x_load      (load_x),
          .y_load      (load_y),
          .crit_load   (load_crit),
          .inc_y       (inc_y),
          .dec_x       (dec_x),
          .calc_crit   (calc_crit)
     );

endmodule

