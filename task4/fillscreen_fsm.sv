module fillscreen_fsm(input logic clk, 
                    input logic rst_n,
                    input logic start, 
                    input logic [7:0] x_count, 
                    input logic [6:0] y_count, 
                    output logic done,
                    output logic [7:0] vga_x,
                    output logic [6:0] vga_y,
                    output logic vga_plot,
                    output logic x_en,
                    output logic y_en,
                    output logic x_rst,
                    output logic y_rst);

    // ---------------- PACKAGE IMPORTS ----------------

    import lab_pkg::*;

    // ---------------- STATE VARIABLES ----------------

    fillscreen_FSM_state state, next;

    // ---------------- MAIN FSM PROCESS ----------------

    always_ff @(posedge clk) begin : PRESENT_STATE_LOGIC
        if (rst_n == 0)  state <= FILL_IDLE;
        else             state <= next;
    end // PRESENT_STATE_LOGIC

    // ---------------- FSM NEXT STATE LOGIC ----------------
    // The FSM controls the vga signals directly, with the only 
    // thing needed outside of the FSM are counters

    always_comb begin : NEXT_STATE_LOGIC
        case (state) 
            FILL_IDLE      : next = (start == 1'b1)                        ? FILL_DRAW : FILL_IDLE;
            FILL_DRAW      : next = ({x_count,y_count} == {8'd159,7'd119}) ? FILL_DONE : FILL_DRAW;
            FILL_DONE      : next = (start == 1'b0)                        ? FILL_IDLE : FILL_DONE;
            default   : next = FILL_IDLE;
        endcase
    end // NEXT_STATE_LOGIC

    // ---------------- FSM STATE OUTPUTS ----------------
    // Implementation of Mealy FSM where outputs depend on 
    // current state + counter input values and they directly
    // control the counters and output VGA plot signals
    
    always_comb begin : CURR_STATE_OUTPUT_LOGIC

        // Default value assignment here before case statement
        // Only individual signals need to be asserted in each state which is less error prone. 
        
        done = 1'b0;
        vga_plot = 1'b0;
        y_en = 1'b0;
        x_rst = 1'b0;
        y_rst = 1'b0;

        // Input dependant outputs
        vga_x = x_count;
        vga_y = y_count;
        x_en = (y_count == 119) ? 1'b1 : 1'b0;

        case (state) 
            FILL_IDLE :  begin
                        x_rst = 1'b1;
                        y_rst = 1'b1;
                    end
            FILL_DRAW :  begin
                        vga_plot = 1'b1;
                        y_en = 1'b1;
                    end
            FILL_DONE :  done = 1'b1;
        endcase

    end // CURR_STATE_OUTPUT_LOGIC

endmodule

