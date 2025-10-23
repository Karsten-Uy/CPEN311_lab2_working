/* 
 * This is the Circle FSM for the Reuleaux block. It differs from the FSM
 * in task3 by having 3 modes, dictated by the SEGMENT_TYPE parameter which
 * determine which octants to draw, ensuring that it will only draw in octants
 * that conatian pixels that are actually part of the Reuleaux Triangle.
 */

module circle_fsm#(
    parameter SEGMENT_TYPE = 1 // blue(c1) = 1, green(c2) = 2, red(c3) = 3
) (
    // From circle
    input logic clk, 
    input logic rst_n, 
    input logic start,

    // From Datapath
    input logic signed [9:0] curr_crit,
    input logic signed [9:0] offset_x,
    input logic signed [8:0] offset_y,
    
    // To Circle
    output logic done,

    // To Datapath
    output logic [2:0] octant_sel,
    output logic load_x_init,
    output logic load_y_init,
    output logic load_x_next,
    output logic load_y_next,
    output logic crit_load,
    output logic inc_y,
    output logic dec_x,
    output logic calc_crit
);
    // ---------------- PACKAGE IMPORTS ----------------

    import lab_pkg::*;

    // ---------------- STATE VARIABLES ----------------

    circle_FSM_state state, next;

    // ---------------- MAIN FSM PROCESS ----------------

    always_ff @( posedge clk ) begin : STATE_FF
        if (rst_n == 1'd0)
            state <= CIRCLE_IDLE;
        else 
            state <= next;
    end

    // ---------------- FSM NEXT STATE LOGIC ----------------
    // The FSM essentially enables the drawing of the 2 relevant
    // octants as specified by the segment parameter then finishes

    always_comb begin : NEXT_STATE_LOGIC
        case(state)
            CIRCLE_IDLE  : next = (start == 1'd1) ? CIRCLE_LOAD : CIRCLE_IDLE;
            CIRCLE_LOAD  :   begin 
                               case(SEGMENT_TYPE)
                                    1       : next = CIRCLE_OCT5; // blue,  (c1)
                                    2       : next = CIRCLE_OCT7; // green, (c2)
                                    3       : next = CIRCLE_OCT2; // red,   (c3)
                                    default : next = CIRCLE_IDLE;
                               endcase
                            end

            // Draw green(c2) segment loop
            CIRCLE_OCT2  : next = CIRCLE_OCT3; 
            CIRCLE_OCT3  : next = (offset_y+'sb1 <= offset_x-'sb1) ? CIRCLE_OCT2 : CIRCLE_DONE;

            // Draw blue(c1) segment loop
            CIRCLE_OCT5  : next = CIRCLE_OCT6;
            CIRCLE_OCT6  : next = (offset_y+'sb1 <= offset_x-'sb1) ? CIRCLE_OCT5 : CIRCLE_DONE;

            // Draw red(c3) segment loop
            CIRCLE_OCT7  : next = CIRCLE_OCT8;
            CIRCLE_OCT8  : next = (offset_y+'sb1 <= offset_x-'sb1) ? CIRCLE_OCT7 : CIRCLE_DONE;

            CIRCLE_DONE  : next = (start == 1'd1) ? CIRCLE_DONE : CIRCLE_IDLE;
            default      : next = CIRCLE_IDLE;
        endcase
    end

    // ---------------- FSM STATE OUTPUTS ----------------
    // Implementation of Mealy FSM where outputs depend on 
    // current state + counter input values and they control 
    // the datapath

    always_comb begin : STATE_OUTPUTS

        done        = 1'd0;
        octant_sel  = 3'd0;
        load_x_init = 1'd0;
        load_y_init = 1'd0;
        load_x_next = 1'd0;
        load_y_next = 1'd0;
        crit_load   = 1'd0;
        inc_y       = 1'd0;
        dec_x       = 1'd0;
        calc_crit   = 1'd0;

        case(state)
            CIRCLE_LOAD  : begin 
                load_x_init = 1'd1;
                load_y_init = 1'd1;
                crit_load = 1'd1;
            end

            // red(c3) loop
            CIRCLE_OCT2  : begin 
                octant_sel = 3'd1;
                inc_y = 1'd1;
                if (curr_crit > 0)
                    dec_x = 1'd1;
            end
            CIRCLE_OCT3  : begin 
                octant_sel = 3'd2;
                calc_crit = 1'd1;
                load_x_next = 1'd1;
                load_y_next = 1'd1; 
            end

            // blue (c1) loop
            CIRCLE_OCT5  : begin 
                octant_sel = 3'd4;
                inc_y = 1'd1;
                if (curr_crit > 0)
                    dec_x = 1'd1;
            end
            CIRCLE_OCT6  : begin 
                octant_sel = 3'd5;
                calc_crit = 1'd1;
                load_x_next = 1'd1;
                load_y_next = 1'd1; 
            end

            // green (c2) loop
            CIRCLE_OCT7  : begin 
                octant_sel = 3'd6;
                inc_y = 1'd1;
                if (curr_crit > 0)
                    dec_x = 1'd1;
            end
            CIRCLE_OCT8  : begin 
                octant_sel = 3'd7;
                calc_crit = 1'd1;
                load_x_next = 1'd1;
                load_y_next = 1'd1;
            end
            CIRCLE_DONE  : done = 1'd1;
            default      : begin
                done        = 1'd0;
                octant_sel  = 3'd0;
                load_x_init = 1'd0;
                load_y_init = 1'd0;
                load_x_next = 1'd0;
                load_y_next = 1'd0;
                crit_load   = 1'd0;
                inc_y       = 1'd0;
                dec_x       = 1'd0;
                calc_crit   = 1'd0;
            end
        endcase
    end

endmodule