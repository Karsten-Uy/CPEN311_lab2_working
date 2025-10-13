module reuleaux(input logic clk, input logic rst_n, input logic [2:0] colour,
                input logic [7:0] centre_x, input logic [6:0] centre_y, input logic [7:0] diameter,
                input logic start, output logic done,
                output logic [7:0] vga_x, output logic [6:0] vga_y,
                output logic [2:0] vga_colour, output logic vga_plot);

    // ---------------- PACKAGE IMPORTS ----------------
    import lab_pkg::*; 
    
    // ---------------- INTERNAL SIGNALS ----------------

    // To REULEAUX_FSM
    logic fill_done;
    logic fsm1_done;
    logic fsm2_done;
    logic fsm3_done;

    // From REULEAUX_FSM
    logic draw_reul;
    logic fill_start;
    logic load_corners;
    logic start1;
    logic start2;
    logic start3;

    // Fillscreen
    logic unsigned [7:0] clear_x;
    logic unsigned [6:0] clear_y;
    logic fillscreen_plot;

    // Screencheck
    logic unsigned [7:0] reul_vga_x;
    logic unsigned [6:0] reul_vga_y;
    logic reul_vga_plot;

    // CALC_CORNERS
    logic signed [8:0] c_x;
    logic signed [7:0] c_y;
    logic signed [8:0] s_diameter;
    logic signed [8:0] c_x1;
    logic signed [7:0] c_y1;
    logic signed [8:0] c_x2;
    logic signed [7:0] c_y2;
    logic signed [8:0] c_x3;
    logic signed [7:0] c_y3;
    logic signed [M_BIT_SHIFT+7:0] tmp_shifted1;
    logic signed [M_BIT_SHIFT+7:0] tmp_shifted2;
    logic signed [M_BIT_SHIFT+7:0] tmp_shifted3;

    // CORNER_REGISTERS
    logic signed [8:0] c_x_reg;
    logic signed [7:0] c_y_reg;
    logic signed [8:0] c_x1_reg;
    logic signed [7:0] c_y1_reg;
    logic signed [8:0] c_x2_reg;
    logic signed [7:0] c_y2_reg;
    logic signed [8:0] c_x3_reg;
    logic signed [7:0] c_y3_reg;
    
    // ---------------- MAIN FSM INST ----------------
    reuleaux_fsm REULEAUX_FSM (
        .clk          (clk),
        .rst_n        (rst_n),
        .colour       (colour),
        .start        (start),
        .fill_done    (fill_done),
        .fsm1_done    (fsm1_done),
        .fsm2_done    (fsm2_done),
        .fsm3_done    (fsm3_done),
        .done         (done),
        .vga_colour   (vga_colour),
        .draw_reul    (draw_reul),
        .fill_start   (fill_start),
        .load_corners (load_corners),
        .start1       (start1),
        .start2       (start2),
        .start3       (start3)
    );
    
    // ---------------- FILL_SCREEN INST ----------------
    fillscreen U_FILLSCREEN (
        .clk           (clk),
        .rst_n         (resetn),
        .start         (fill_start),
        .done          (fill_done),
        .vga_x         (clear_x),
        .vga_y         (clear_y),
        .vga_plot      (fillscreen_plot)
    );

    // Fillscreen-Reualueaux Triangle Mux
    assign vga_x    = (draw_reul == 1'b1) ? reul_vga_x    : clear_x;
    assign vga_y    = (draw_reul == 1'b1) ? reul_vga_y    : clear_y;
    assign vga_plot = (draw_reul == 1'b1) ? reul_vga_plot : fillscreen_plot;

    always_comb begin : CALC_CORNERS

        // Sign extend, centre_x, centre_y, and diameter always greater or equal to 0
        c_x        = {1'sb0, centre_x};
        c_y        = {1'sb0, centre_y};
        s_diameter = {1'sb0, diameter};        

        // Circle 1 corner calculation
        c_x1 = c_x + (s_diameter >> 2);
        tmp_shifted1 = diameter * SQRT_3_DIV_6;
        c_y1 = c_y + (tmp_shifted1 >> M_BIT_SHIFT);
        c_x2 = c_x - (s_diameter >> 2);
        tmp_shifted2 = diameter * SQRT_3_DIV_6;
        c_y2 = c_y + (tmp_shifted2 >> M_BIT_SHIFT);
        c_x3 = c_x;
        tmp_shifted3 = diameter * SQRT_3_DIV_3;
        c_y3 = c_y - (tmp_shifted3 >> M_BIT_SHIFT);

    end

    always_ff @(posedge clk) begin : CORNER_REGISTERS
        if (rst_n == 1'b0) begin
            c_x_reg  = 8'sd0;
            c_y_reg  = 7'sd0;
            c_x1_reg = 8'sd0;
            c_y1_reg = 7'sd0;
            c_x2_reg = 8'sd0;
            c_y2_reg = 7'sd0;
            c_x3_reg = 8'sd0;
            c_y3_reg = 7'sd0;
        end else begin
            if (load_corners == 1'b1) begin                
                c_x_reg  = c_x;
                c_y_reg  = c_y;
                c_x1_reg = c_x1;
                c_y1_reg = c_y1;
                c_x2_reg = c_x2;
                c_y2_reg = c_y2;
                c_x3_reg = c_x3;
                c_y3_reg = c_y3;
            end 
        end
    end

    // TODO: circle block + MUX, screencheck

    // CIRCLE BLOCKS
    // 1 datapath + 3 FSMs

    


endmodule

