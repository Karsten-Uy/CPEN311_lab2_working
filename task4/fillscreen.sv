/*
 * This is the fillscreen module for task4. The difference between 
 * this and task2 is that this module doesn't determine colour, which
 * controlled by reuleaux_fsm instead, being set to 0 to print a black
 * screen when this module is running 
 */

module fillscreen(input logic clk,
                  input logic rst_n,
                  input logic start,
                  output logic done,
                  output logic [7:0] vga_x, 
                  output logic [6:0] vga_y,
                  output logic vga_plot);

     // ---------------- INTERNAL SIGNALS ----------------
     
     logic [7:0] x_count;
     logic [6:0] y_count;
     logic x_en;
     logic y_en;
     logic x_rst;
     logic y_rst;

     // ---------------- FSM INSTANTIATION ----------------

     fillscreen_fsm FSM(
          .clk         (clk),
          .rst_n       (rst_n),
          .start       (start),
          .x_count     (x_count),
          .y_count     (y_count),
          .done        (done),
          .vga_x       (vga_x),
          .vga_y       (vga_y),
          .vga_plot    (vga_plot),
          .x_en        (x_en),
          .y_en        (y_en),
          .x_rst       (x_rst),
          .y_rst       (y_rst)
     );

     // ---------------- XY COUNTERS ----------------
     // These counters determine the coordinates that
     // are plotted for a given clock cycle
     
     // X COUNTER
     always_ff @( posedge clk ) begin : X_COUNTER
          if (x_rst == 1'b1)
               x_count = 8'b00000000;
          else begin
               if (x_en == 1'b1) begin
                    if (x_count == 159)
                         x_count = 0;
                    else
                         x_count += 8'b00000001;
               end 
          end
     end

     // Y COUNTER
     always_ff @( posedge clk ) begin : Y_COUNTER
          if (y_rst == 1'b1)
               y_count = 7'b0000000;
          else begin
               if (y_en == 1'b1) begin
                    if (y_count == 119)
                         y_count = 0;
                    else
                         y_count += 7'b0000001;
               end 
          end
     end


endmodule

