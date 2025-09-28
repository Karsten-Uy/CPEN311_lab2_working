module fillscreen_fsm (

    // Top level signals 
    input   logic       clk,
    input   logic       rst_n,
    input   logic       start,    // Trigger FSM out of done state
    output  logic       done,     // Asserted when FSM is done drawing
    output  logic       vga_plot, // Asserted while pixels are being drawn

    // Datapath signals
    input   logic [7:0] x_count, // 0 to 159
    input   logic [6:0] y_count, // 0 to 127
    output  logic       x_inc_en,
    output  logic       y_inc_en
);

    // ---------------- PACKAGE IMPORTS ----------------
    import lab_pkg::*;

    // ---------------- STATE VARIABLES ----------------
    e_FSM_state state, next;

    // ---------------- MAIN FSM PROCESS ----------------


    always_ff @(posedge clk) begin : PRESENT_STATE_LOGIC
        if (!rst_n) state <= IDLE;
        else        state <= next;
    end

    always_comb begin : NEXT_STATE_LOGIC
        case (state)
            IDLE :  if(start == 1) 
                        next = DRAW;
                    else
                        next = IDLE;

            DRAW :  if (x_count == 159 && y_count == 119) 
                        next = DONE;
                    else
                        next = DRAW;
                        
            DONE :  if (start == 0) 
                        next = IDLE;
                    else
                        next = DONE;
        endcase
    end

    always_comb begin : CURR_STATE_OUTPUT_LOGIC
        done = 1'b0;
        vga_plot = 1'b0;
        x_inc_en = 1'b0;
        y_inc_en = 1'b0;

        case (state)
            DRAW:   begin
                        vga_plot = 1'b1;
                        y_inc_en = 1'b1;

                        // Need to check at 159 other wise x will increment an extra time
                        if (x_count != 159 && y_count == 119) 
                            x_inc_en = 1'b1;
                    end
            DONE: done = 1'b1;
        endcase
    end

endmodule