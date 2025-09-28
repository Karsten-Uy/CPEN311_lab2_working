module fillscreen(input logic clk, input logic rst_n, input logic [2:0] colour,
                  input logic start, output logic done,
                  output logic [7:0] vga_x, output logic [6:0] vga_y,
                  output logic [2:0] vga_colour, output logic vga_plot);
     // fill the screen

     // ------------------ CONTROL LOGIC ------------------
     fillscreen_fsm FSM(
          .clk      (clk),
          .rst_n    (rst_n),
          .start    (start),
          .done     (done),
          .vga_plot (vga_plot),
          .x_count  (vga_x),
          .y_count  (vga_y),
          .x_inc_en (x_inc_en),
          .y_inc_en (y_inc_en)
     );
     // ------------------ DATAPATH ------------------

     // Implements color = x mod 8
     assign vga_colour = vga_x[2:0];

     always_ff @(posedge clk) begin : x_counter
          if(!rst_n) vga_x <= 'b0;
          else if (vga_x == 159 && vga_y == 119) begin
               vga_x <= 'b0;
          end
          else begin
               if(x_inc_en) begin
                    vga_x <= vga_x + 'b1;
               end
          end
     end

     always_ff @(posedge clk) begin : y_counter
          if(!rst_n) vga_y <= 'b0;
          else if (vga_y == 119) begin
               vga_y <= 'b0;
          end
          else begin
               if(y_inc_en) begin
                    vga_y <= vga_y + 'b1;
               end
          end
     end

     // ---------------- DESIGN ASSERTIONS ----------------

     // synthesis translate_off 

     // The following design assertions throw errors that can 
     // be accumulated at the testbench level to fail tests   
     int ERROR_COUNT;
     always_ff @(posedge clk) begin
          if (vga_x > 159) begin
               $error("x exceed limits");     
               ERROR_COUNT += 1;
          end
          if (vga_y > 119) begin
               $error("y exceed limits");     
               ERROR_COUNT += 1;
          end
     end

     // synthesis translate_on

endmodule

