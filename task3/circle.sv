/* 
 * This is the top level module of circle, it instatiates the datapath
 * and FSM
 */

module circle(input logic clk, input logic rst_n, input logic [2:0] colour,
              input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] radius,
              input logic start, output logic done,
              output logic [7:0] vga_x, output logic [6:0] vga_y,
              output logic [2:0] vga_colour, output logic vga_plot);

    // ---------------- INTERNAL SIGNALS ----------------

     logic unsigned       fill_start;
     logic unsigned       fill_done;
     logic unsigned       draw_circle;
     logic unsigned [2:0] octant_sel;
     logic unsigned       dec_x;
     logic unsigned       inc_y;
     logic unsigned       calc_crit;
     logic unsigned       load_x_init;
     logic unsigned       load_y_init;
     logic unsigned       load_x_next;
     logic unsigned       load_y_next;
     logic unsigned       load_crit;
     logic signed  [8:0]  offset_x;
     logic signed  [8:0]  offset_y;
     logic signed  [10:0]  crit;
     logic signed  [8:0]  centre_x_sgn;
     logic signed  [7:0]  centre_y_sgn;
     logic signed  [8:0]  radius_sgn;

    // ---------------- SIGN EXTENSION OF INPUTS ----------------
    // The inputs are sign-extended to make arithmathic consistent
    // with the crit value which can be negative

     assign centre_x_sgn = {1'b0, centre_x};
     assign centre_y_sgn = {1'b0, centre_y};
     assign radius_sgn   = {1'b0, radius};

     // ---------------- DP INSTATIATION ----------------

     datapath DP(
          .clk         (clk),
          .resetn      (rst_n),
          .radius      (radius_sgn),
          .centre_x    (centre_x_sgn),
          .centre_y    (centre_y_sgn),

          .fill_start  (fill_start),
          .fill_done   (fill_done),
          .draw_circle (draw_circle),
          .octant_sel  (octant_sel),
          .dec_x       (dec_x),
          .inc_y       (inc_y),
          .calc_crit   (calc_crit),
          .load_x_init (load_x_init),
          .load_y_init (load_y_init),
          .load_x_next (load_x_next),
          .load_y_next (load_y_next),
          .load_crit   (load_crit),
          .offset_x    (offset_x),
          .offset_y    (offset_y),
          .crit        (crit),

          .vga_x       (vga_x),
          .vga_y       (vga_y),
          .plot        (vga_plot)
     );

     // ---------------- FSM INSTATIATION ----------------

     circle_fsm CIRCLE_FSM(
          .clk         (clk),
          .rst_n       (rst_n),
          .colour      (colour),
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
          .load_x_init (load_x_init),
          .load_y_init (load_y_init),
          .load_x_next (load_x_next),
          .load_y_next (load_y_next),
          .crit_load   (load_crit),
          .inc_y       (inc_y),
          .dec_x       (dec_x),
          .calc_crit   (calc_crit)
     );

endmodule
