
module datapath #(
    parameter VGA_X_DW  = 8, 
    parameter VGA_Y_DW  = 7, 
    parameter RADIUS_DW = 8,
    // parameter CRIT_DW   = RADIUS_DW+1, // unsigned so +1 in size
    parameter CRIT_DW   = 10,

    // Set offsets and octant such that they're X widths + 1
    parameter OCT_DW      = VGA_X_DW + 1,
    parameter OFFSET_X_DW = VGA_X_DW + 1,
    parameter OFFSET_Y_DW = VGA_Y_DW + 1
)(
    // Global clk and active-low reset
    input   logic       clk,
    input   logic       resetn,

    // From top
    input   logic signed [8:0]    radius,
    input   logic signed [9:0]    centre_x,
    input   logic signed [8:0]    centre_y,

    // FSM signals
    input   logic unsigned [2:0]            octant_sel, // binary select mux for 0-7
    input   logic unsigned                  dec_x,
    input   logic unsigned                  inc_y,
    input   logic unsigned                  calc_crit,
    input   logic unsigned                  load_x_init,
    input   logic unsigned                  load_y_init,
    input   logic unsigned                  load_x_next,
    input   logic unsigned                  load_y_next,
    input   logic unsigned                  load_crit,
    output  logic signed  [OFFSET_X_DW-1:0] offset_x,  
    output  logic signed  [OFFSET_Y_DW-1:0] offset_y,  
    output  logic signed  [CRIT_DW-1    :0] crit,

    // To top
    output  logic unsigned [VGA_X_DW-1:0]   vga_x,
    output  logic unsigned [VGA_Y_DW-1:0]   vga_y,
    output  logic unsigned                  plot
);

    // ---------------- INTERNAL SIGNALS ----------------
    logic unsigned [VGA_X_DW-1:0] circle_x; 
    logic unsigned [VGA_Y_DW-1:0] circle_y;
    logic unsigned [VGA_X_DW-1:0] clear_x; 
    logic unsigned [VGA_Y_DW-1:0] clear_y;
    logic unsigned                circle_plot;
    logic unsigned                fillscreen_plot;

    logic signed [OCT_DW-1:0] oct1_x;
    logic signed [OCT_DW-1:0] oct2_x;
    logic signed [OCT_DW-1:0] oct3_x;
    logic signed [OCT_DW-1:0] oct4_x;
    logic signed [OCT_DW-1:0] oct5_x;
    logic signed [OCT_DW-1:0] oct6_x;
    logic signed [OCT_DW-1:0] oct7_x;
    logic signed [OCT_DW-1:0] oct8_x;
    logic signed [OCT_DW-1:0] circle_int_x;

    logic signed [OCT_DW-1:0] oct1_y;
    logic signed [OCT_DW-1:0] oct2_y;
    logic signed [OCT_DW-1:0] oct3_y;
    logic signed [OCT_DW-1:0] oct4_y;
    logic signed [OCT_DW-1:0] oct5_y;
    logic signed [OCT_DW-1:0] oct6_y;
    logic signed [OCT_DW-1:0] oct7_y;
    logic signed [OCT_DW-1:0] oct8_y;
    logic signed [OCT_DW-1:0] circle_int_y;

    logic signed  [OFFSET_X_DW-1:0] calc_offset_x;  
    logic signed  [OFFSET_Y_DW-1:0] calc_offset_y;  

    // ---------------- TOP LEVEL MUX ----------------
    assign vga_x =  circle_x;
    assign vga_y =  circle_y;
    assign plot  =  circle_plot;

    // ---------------- OFFSET/CRIT REGISTERS ----------------

    always_ff @( posedge clk ) begin : REG__offset_x 
        if(!resetn)           offset_x <= 'sd0;
        else if (load_x_init) offset_x <= radius;
        else if (load_x_next) offset_x <= calc_offset_x;
    end

    always_ff @( posedge clk ) begin : REG__offset_y 
        if(!resetn)           offset_y <= 'sb0;
        else if (load_y_init) offset_y <= 'sb0;
        else if (load_y_next) offset_y <= calc_offset_y;
    end

    always_ff @( posedge clk ) begin : REG__crit_offset_x 
        if (dec_x) calc_offset_x <= offset_x - 'sb1;
        else       calc_offset_x <= offset_x;
    end

    always_ff @( posedge clk ) begin : REG__crit_offset_y 
        if (inc_y)  calc_offset_y <= offset_y + 'sb1;
        else        calc_offset_y <= offset_y;
    end

    always_ff @( posedge clk ) begin : REG__crit
        if(!resetn)         crit  <= 'sb0;
        else if (load_crit) crit  <= 'sb1 - radius;
        else if (calc_crit)  begin
            if (crit <= 'sb0) crit <= crit + 'sd2 * (calc_offset_y) + 'sb1;
            else              crit <= crit + 'sd2 * (calc_offset_y - calc_offset_x) + 'sb1;
        end
    end

    // ---------------- ALU ----------------

    // Implements the Bresenham Circle Algorithm for each octant x/y
    always_comb begin : octant_ALU 
        oct1_x = centre_x + offset_x;
        oct2_x = centre_x + offset_y;
        oct4_x = centre_x - offset_x;
        oct3_x = centre_x - offset_y;
        oct5_x = centre_x - offset_x;
        oct6_x = centre_x - offset_y;
        oct8_x = centre_x + offset_x;
        oct7_x = centre_x + offset_y;

        oct1_y = centre_y + offset_y;
        oct2_y = centre_y + offset_x;
        oct4_y = centre_y + offset_y;
        oct3_y = centre_y + offset_x;
        oct5_y = centre_y - offset_y;
        oct6_y = centre_y - offset_x;
        oct8_y = centre_y - offset_y;
        oct7_y = centre_y - offset_x;
    end

    // ---------------- octant_mux ----------------
    // FSM cycles between oct{1...8} draw phases
    always_comb begin : octant_mux;
        case(octant_sel)
            3'd0 :   {circle_int_x, circle_int_y} = {oct1_x, oct1_y};
            3'd1 :   {circle_int_x, circle_int_y} = {oct2_x, oct2_y};
            3'd2 :   {circle_int_x, circle_int_y} = {oct3_x, oct3_y};
            3'd3 :   {circle_int_x, circle_int_y} = {oct4_x, oct4_y};
            3'd4 :   {circle_int_x, circle_int_y} = {oct5_x, oct5_y};
            3'd5 :   {circle_int_x, circle_int_y} = {oct6_x, oct6_y};
            3'd6 :   {circle_int_x, circle_int_y} = {oct7_x, oct7_y};
            3'd7 :   {circle_int_x, circle_int_y} = {oct8_x, oct8_y};
            default: {circle_int_x, circle_int_y} = 'bx; // should never be hit
        endcase
    end

    // ---------------- SCREEN_CHECK ----------------
    // Convert signed to unsigned and set plot signal to 0 if offscreen
    // Set pixels offscreen to 0 as well
    // Since vga_x and vga_y are positive, signed to unsigned conversion 
    // can be done by removing MSB from circle_int_{x,y}
    always_comb begin : screen_check
        circle_x = (circle_int_x <= 'sd159 && circle_int_x >= 'sd0) ? circle_int_x[VGA_X_DW-1:0] : 'b0;
        circle_y = (circle_int_y <= 'sd119 && circle_int_y >= 'sd0) ? circle_int_y[VGA_Y_DW-1:0] : 'b0;
        
        // Ensure plot is not enabled during pre-draw stages
        if (octant_sel != 3'd0) begin
            circle_plot = (circle_int_x <= 'sd159 && circle_int_x >= 'sd0 &&
                           circle_int_y <= 'sd119 && circle_int_y >= 'sd0) ? 1'b1 : 1'b0;
        end else circle_plot = 1'b0;
    end

endmodule