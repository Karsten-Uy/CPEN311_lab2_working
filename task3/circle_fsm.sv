
module circle_fsm #(
    parameter VGA_X_DW  = 7, 
    parameter VGA_Y_DW  = 6, 
    parameter RADIUS_DW = 7,
    parameter CRIT_DW   = RADIUS_DW+1, // unsigned so +1 in size

    // Set offsets and octant such that they're X widths + 1
    parameter OFFSET_X_DW = VGA_X_DW + 1,
    parameter OFFSET_Y_DW = VGA_Y_DW + 1
)(

    // From circle
    input logic clk, 
    input logic rst_n, 
    input logic [2:0] colour,
    input logic [VGA_X_DW-1:0] centre_x, 
    input logic [VGA_Y_DW-1:0] centre_y,
    input logic [RADIUS_DW-1:0] radius,
    input logic start,

    // From Datapath
    input logic signed [CRIT_DW-1:0] curr_crit,
    input logic fill_done,
    input logic signed [OFFSET_X_DW-1:0] offset_x,
    input logic signed [OFFSET_Y_DW-1:0] offset_y,

    // To Circle
    output logic done,
    output logic [2:0] vga_colour,

    // To Datapath
    output logic draw_circle,
    output logic [2:0] octant_sel,
    output logic fill_start,
    output logic x_load,
    output logic y_load,
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

    always_comb begin : NEXT_STATE_LOGIC
        case(state)
            CIRCLE_IDLE  : next = (start == 1'd1) ? CIRCLE_LOAD : CIRCLE_IDLE;
            CIRCLE_LOAD  : next = CIRCLE_BLACK;
            CIRCLE_BLACK : next = (fill_done == 1'd1) ? CIRCLE_OCT1 : CIRCLE_BLACK;
            CIRCLE_OCT1  : next = CIRCLE_OCT2;
            CIRCLE_OCT2  : next = CIRCLE_OCT3;
            CIRCLE_OCT3  : next = CIRCLE_OCT4;
            CIRCLE_OCT4  : next = CIRCLE_OCT5;
            CIRCLE_OCT5  : next = CIRCLE_OCT6;
            CIRCLE_OCT6  : next = CIRCLE_OCT7;
            CIRCLE_OCT7  : next = CIRCLE_OCT8;
            CIRCLE_OCT8  : next = (offset_y <= offset_x) ? CIRCLE_OCT1 : CIRCLE_DONE;
            CIRCLE_DONE  : next = (start == 1'd1) ? CIRCLE_DONE : CIRCLE_IDLE;
            default      : next = CIRCLE_IDLE;
        endcase
    end

    always_comb begin : STATE_OUTPUTS

        done        = 1'd0;
        vga_colour  = 3'd0;
        draw_circle = 1'd0;
        octant_sel  = 3'd0;
        fill_start  = 1'd0;
        x_load      = 1'd0;
        y_load      = 1'd0;
        crit_load   = 1'd0;
        inc_y       = 1'd0;
        dec_x       = 1'd0;
        calc_crit   = 1'd0;

        case(state)
            CIRCLE_LOAD  : begin 
                x_load = 1'd1;
                y_load = 1'd1;
                crit_load = 1'd1;
            end
            CIRCLE_BLACK : begin 
                draw_circle = 1'd0;
                fill_start = 1'd1;
                vga_colour = 1'd0; // BLACK
            end
            CIRCLE_OCT1  : begin 
                draw_circle = 1'd1;
                vga_colour = colour;
                octant_sel = 3'd0;
            end
            CIRCLE_OCT2  : begin 
                draw_circle = 1'd1;
                vga_colour = colour;
                octant_sel = 3'd1;
            end
            CIRCLE_OCT3  : begin 
                draw_circle = 1'd1;
                vga_colour = colour;
                octant_sel = 3'd2;
            end
            CIRCLE_OCT4  : begin 
                draw_circle = 1'd1;
                vga_colour = colour;
                octant_sel = 3'd3;
            end
            CIRCLE_OCT5  : begin 
                draw_circle = 1'd1;
                vga_colour = colour;
                octant_sel = 3'd4;
            end
            CIRCLE_OCT6  : begin 
                draw_circle = 1'd1;
                vga_colour = colour;
                octant_sel = 3'd5;
            end
            CIRCLE_OCT7  : begin 
                draw_circle = 1'd1;
                vga_colour = colour;
                octant_sel = 3'd6;
            end
            CIRCLE_OCT8  : begin 
                draw_circle = 1'd1;
                vga_colour = colour;
                octant_sel = 3'd7;
                inc_y = 1'd1;
                if (curr_crit > 0)
                    dec_x = 1'd1;
                calc_crit = 1'd1;
            end
            CIRCLE_DONE  : done = 1'd1;
            default      : begin
                done        = 1'd0;
                vga_colour  = 3'd0;
                draw_circle = 1'd0;
                octant_sel  = 3'd0;
                fill_start  = 1'd0;
                x_load      = 1'd0;
                y_load      = 1'd0;
                crit_load   = 1'd0;
                inc_y       = 1'd0;
                dec_x       = 1'd0;
                calc_crit   = 1'd0;
            end
        endcase
    end

endmodule