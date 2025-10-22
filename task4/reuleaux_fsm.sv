

module reuleaux_fsm(
    
    // From Reuleaux
    input logic clk, 
    input logic rst_n, 
    input logic [2:0] colour,
    input logic start,

    // From Datapath
    input logic fill_done,
    input logic fsm1_done,
    input logic fsm2_done,
    input logic fsm3_done,

    // To Reuleaux
    output logic done,
    output logic [2:0] vga_colour,

    // To Datapath
    output logic draw_reul,
    output logic fill_start,
    output logic load_corners,
    output logic start1,
    output logic start2,
    output logic start3

);
    // ---------------- PACKAGE IMPORTS ----------------

    import lab_pkg::*;

    // ---------------- STATE VARIABLES ----------------

    triangle_FSM_state state, next;

    // ---------------- MAIN FSM PROCESS ----------------

    always_ff @( posedge clk ) begin : STATE_FF
        if (rst_n == 1'd0)
            state <= REUL_IDLE;
        else 
            state <= next;
    end

    // ---------------- FSM NEXT STATE LOGIC ----------------
    // The FSM controls which module to run, whether it is fillscreen,
    // or specific circle modules that draw specific octants, moving
    // to the next drawing module once one is completed

    always_comb begin : NEXT_STATE_LOGIC
        case(state)
            REUL_IDLE  : next = (start == 1'd1)     ? REUL_BLACK : REUL_IDLE;
            REUL_BLACK : next = (fill_done == 1'b1) ? REUL_FSM1  : REUL_BLACK;
            REUL_FSM1  : next = (fsm1_done == 1'b1) ? REUL_FSM2  : REUL_FSM1;
            REUL_FSM2  : next = (fsm2_done == 1'b1) ? REUL_FSM3  : REUL_FSM2;
            REUL_FSM3  : next = (fsm3_done == 1'b1) ? REUL_DONE  : REUL_FSM3;
            REUL_DONE  : next = (start == 1'b1)     ? REUL_DONE  : REUL_IDLE;
            default    : next = REUL_IDLE;
        endcase
    end

    // ---------------- FSM STATE OUTPUTS ----------------
    // For each of the drawing states, this FSM outputs select
    // the colour, and controls which drawing module to run. In
    // REUL_BLACK load_corners is enabled to do calculations
    // and the draw_reul signal controls the MUX that selects
    // between the fillscreen and screened circle outputs
    
    always_comb begin : STATE_OUTPUTS

        done         = 1'b0;
        vga_colour   = 3'b000;
        draw_reul    = 1'b0;
        fill_start   = 1'b0;
        load_corners = 1'b0;
        start1       = 1'b0;
        start2       = 1'b0;
        start3       = 1'b0;

        case(state)
            REUL_BLACK : begin 
                draw_reul    = 1'b0;
                fill_start   = 1'b1;
                vga_colour   = 3'b000;
                load_corners = 1'b1;
            end
            REUL_FSM1  : begin 
                draw_reul    = 1'b1;
                start1       = 1'b1;
                vga_colour   = colour;
            end
            REUL_FSM2  : begin 
                draw_reul    = 1'b1;
                start2       = 1'b1;
                vga_colour   = colour;
            end
            REUL_FSM3  : begin 
                draw_reul    = 1'b1;
                start3       = 1'b1;
                vga_colour   = colour;
            end
            REUL_DONE  : begin 
                done         = 1'b1;
            end
            default      : begin
                done         = 1'b0;
                vga_colour   = 3'b000;
                draw_reul    = 1'b0;
                fill_start   = 1'b0;
                load_corners = 1'b0;
                start1       = 1'b0;
                start2       = 1'b0;
                start3       = 1'b0;
            end
        endcase
    end

endmodule