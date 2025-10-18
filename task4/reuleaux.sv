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
    logic signed [8:0] c_x1_reg;
    logic signed [7:0] c_y1_reg;
    logic signed [8:0] c_x2_reg;
    logic signed [7:0] c_y2_reg;
    logic signed [8:0] c_x3_reg;
    logic signed [7:0] c_y3_reg;

    // FSM Wires
    logic unsigned [7:0] circ1_vga_x;
    logic unsigned [6:0] circ1_vga_y;
    logic unsigned       circ1_vga_plot;
    logic unsigned [7:0] circ2_vga_x;
    logic unsigned [6:0] circ2_vga_y;
    logic unsigned       circ2_vga_plot;
    logic unsigned [7:0] circ3_vga_x;
    logic unsigned [6:0] circ3_vga_y;
    logic unsigned       circ3_vga_plot;
    logic unsigned [7:0] circle_vga_x;
    logic unsigned [6:0] circle_vga_y;
    logic unsigned       circle_vga_plot;
    
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
        .rst_n         (rst_n),
        .start         (fill_start),
        .done          (fill_done),
        .vga_x         (clear_x),
        .vga_y         (clear_y),
        .vga_plot      (fillscreen_plot)
    );

    // Fillscreen-Reualueaux Triangle Mux
    assign vga_x    = (draw_reul == 1'b1) ? circle_vga_x  : clear_x;
    assign vga_y    = (draw_reul == 1'b1) ? circle_vga_y  : clear_y;
    assign vga_plot = (draw_reul == 1'b1) ? reul_vga_plot : fillscreen_plot;

    // ---------------- CORNER CALCULATIONS ----------------
    always_comb begin : CALC_CORNERS

        // Sign extend, centre_x, centre_y, and diameter always greater or equal to 0
        c_x        = {1'sb0, centre_x};
        c_y        = {1'sb0, centre_y};
        s_diameter = {1'sb0, diameter};        

        // Circle 1 corner calculation
        c_x1 = c_x + (s_diameter >> 1);
        tmp_shifted1 = diameter * SQRT_3_DIV_6;
        c_y1 = c_y + (tmp_shifted1 >> M_BIT_SHIFT);
        c_x2 = c_x - (s_diameter >> 1);
        tmp_shifted2 = diameter * SQRT_3_DIV_6;
        c_y2 = c_y + (tmp_shifted2 >> M_BIT_SHIFT);
        c_x3 = c_x;
        tmp_shifted3 = diameter * SQRT_3_DIV_3;
        c_y3 = c_y - (tmp_shifted3 >> M_BIT_SHIFT);

    end

    always_ff @(posedge clk) begin : CORNER_REGISTERS
        if (rst_n == 1'b0) begin
            c_x1_reg = 8'sd0;
            c_y1_reg = 7'sd0;
            c_x2_reg = 8'sd0;
            c_y2_reg = 7'sd0;
            c_x3_reg = 8'sd0;
            c_y3_reg = 7'sd0;
        end else begin
            if (load_corners == 1'b1) begin
                c_x1_reg = c_x1;
                c_y1_reg = c_y1;
                c_x2_reg = c_x2;
                c_y2_reg = c_y2;
                c_x3_reg = c_x3;
                c_y3_reg = c_y3;
            end 
        end
    end

    // ---------------- CIRCLE BLOCKS ----------------

    circle #(1) CIRC_1 (
        .clk      (clk),
        .rst_n    (rst_n),
        .centre_x (c_x1_reg),
        .centre_y (c_y1_reg),
        .radius   (s_diameter),
        .start    (start1),

        .done     (fsm1_done),
        .vga_x    (circ1_vga_x),
        .vga_y    (circ1_vga_y),
        .vga_plot (circ1_vga_plot)    
    );

    circle #(2) CIRC_2 (
        .clk      (clk),
        .rst_n    (rst_n),
        .centre_x (c_x2_reg),
        .centre_y (c_y2_reg),
        .radius   (s_diameter),
        .start    (start2),

        .done     (fsm2_done),
        .vga_x    (circ2_vga_x),
        .vga_y    (circ2_vga_y),
        .vga_plot (circ2_vga_plot)    
    );
 
    circle #(3) CIRC_3 (
        .clk      (clk),
        .rst_n    (rst_n),
        .centre_x (c_x3_reg),
        .centre_y (c_y3_reg),
        .radius   (s_diameter),
        .start    (start3),

        .done     (fsm3_done),
        .vga_x    (circ3_vga_x),
        .vga_y    (circ3_vga_y),
        .vga_plot (circ3_vga_plot)    
    );

    always_comb begin : CIRCLE_SEL_MUX
        case ({start1,start2,start3})
            3'b100  : begin
                circle_vga_x    = circ1_vga_x;
                circle_vga_y    = circ1_vga_y;
                circle_vga_plot = circ1_vga_plot;
            end
            3'b010  : begin
                circle_vga_x    = circ2_vga_x;
                circle_vga_y    = circ2_vga_y;
                circle_vga_plot = circ2_vga_plot;
            end
            3'b001  : begin
                circle_vga_x    = circ3_vga_x;
                circle_vga_y    = circ3_vga_y;
                circle_vga_plot = circ3_vga_plot;
            end
            default : begin // EMERGENCY DEFAULT CASE, shouldn't happen
                circle_vga_x    = circ1_vga_x;
                circle_vga_y    = circ1_vga_y;
                circle_vga_plot = circ1_vga_plot;
            end
        endcase
    end 

    // ---------------- TOP LEVEL SCREEN CHECK ----------------    
    // This block sets plot to 0 when the circle is drawing outside
    // of the reuleaux triangle using the x coordinate as the indicator
    // for whether it is out of bounds
    always_comb begin : FINAL_SCREENCHECK
        case({start1,start2,start3})
            3'b100  : reul_vga_plot = (circle_vga_x <= c_x3_reg) ? circle_vga_plot : 1'b0;
            3'b010  : reul_vga_plot = (circle_vga_x >= c_x3_reg) ? circle_vga_plot : 1'b0;
            3'b001  : reul_vga_plot = (circle_vga_x <= c_x1_reg && circle_vga_x >= c_x2_reg) ? circle_vga_plot : 1'b0;
            default : reul_vga_plot = 1'b0;
        endcase
    end

endmodule

