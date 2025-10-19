module circle#(
    parameter SEGMENT_TYPE = 1 // blue(c1) = 1, green(c2) = 2, red(c3) = 3
) (
     input logic clk, 
     input logic rst_n, 
     input logic signed [9:0] centre_x, 
     input logic signed [8:0] centre_y,
     input logic signed [8:0] radius,
     input logic start, 
     output logic done,
     output logic [7:0] vga_x, 
     output logic [6:0] vga_y,
     output logic vga_plot
);

     // FSM Signals
     logic unsigned [2:0] octant_sel;
     logic unsigned       dec_x;
     logic unsigned       inc_y;
     logic unsigned       calc_crit;
     logic unsigned       load_x_init;
     logic unsigned       load_y_init;
     logic unsigned       load_x_next;
     logic unsigned       load_y_next;
     logic unsigned       load_crit;

     logic signed  [9:0]  offset_x;
     logic signed  [8:0]  offset_y;
     logic signed  [9:0]  crit;

     logic unsigned dp_vga_plot;

     assign vga_plot = (done == 1'b0) ? dp_vga_plot : 1'b0;

     datapath DP(
          .clk         (clk),
          .resetn      (rst_n),
          .radius      (radius),
          .centre_x    (centre_x),
          .centre_y    (centre_y),

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
          .plot        (dp_vga_plot)
     );

     circle_fsm #(SEGMENT_TYPE) CIRCLE_FSM(
          .clk         (clk),
          .rst_n       (rst_n),
          .start       (start),

          .curr_crit   (crit),
          .offset_x    (offset_x),
          .offset_y    (offset_y),
          .done        (done),

          .octant_sel  (octant_sel),
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
