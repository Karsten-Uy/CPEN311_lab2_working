module circle(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
              input logic start, output logic done,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);
     // draw the circle

     datapath DP(
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

     circle_fsm CIRCLE_FSM(
          .clk         (clk),
          .rst_n       (rst_n),
          .colour      (colour),
          .centre_x    (centre_x),
          .centre_y    (centre_y),
          .radius      (radius),
          .start       (start),
          .curr_crit   (curr_crit),
          .fill_done   (fill_done),
          .offset_x    (offset_x),
          .offset_y    (offset_y),
          .done        (done),
          .vga_colour  (vga_colour),
          .draw_circle (draw_circle),
          .octant_sel  (octant_sel),
          .fill_start  (fill_start),
          .x_load      (x_load),
          .y_load      (y_load),
          .crit_load   (crit_load),
          .inc_y       (inc_y),
          .dec_x       (dec_x),
          .calc_crit   (calc_crit)
     );

endmodule

