/*
    The following is a reference model that will receive the same inputs as the DUT

    DUT behaviour is expected to line up with thie behavioural model
*/

package triangle_ref_pkg;

    // Internal ref state
    typedef enum {
        IDLE,
        CLEAR,
        DRAW_TRIANGLE,
        REF_DONE
    } triangle_ref_state;


    typedef enum {
       GREEN,
       BLUE,
       RED
    } e_segment_type;

endpackage

module triangle_ref (triangle_if vif, phases phases);

    import lab_pkg::*;
    import triangle_ref_pkg::*;

    triangle_ref_state ref_state;

    // GLOBALS
    int c_x;
    int c_y;
    int c_x1;
    int c_x2;
    int c_x3;
    int c_y1;
    int c_y2;
    int c_y3;

    // Start reference model
    task run();
        event start_trig;

        fork
            while(phases.run_phase == 1) begin
                @(posedge vif.start == 1'b1) -> start_trig;
            end
        join_none

        while(phases.run_phase == 1) begin

            $display("[%0t ns][ref_model] Running triangle reference model", $time);
            ref_main();
            fork
                if(vif.start == 1'b0) begin
                    ref_state = triangle_ref_pkg::IDLE;
                end
                else begin
                    @(posedge vif.start == 1'b0);
                    @(posedge vif.clk);
                    ref_state = triangle_ref_pkg::IDLE;
                end
            join_none

            $display("[%0t ns][ref_model] Waiting start signal...", $time);
            @(start_trig);
        end
    endtask

    // Main reference model code
    task ref_main();

        @(posedge vif.clk); // Load state

        /*
            NOTE: i think the real numbers are truncated here
        */
        c_x = vif.centre_x;
        c_y = vif.centre_y;
        c_x1 = c_x + vif.diameter/2;
        c_y1 = c_y + vif.diameter * $sqrt(3)/6;
        c_x2 = c_x - vif.diameter/2;
        c_y2 = c_y + vif.diameter * $sqrt(3)/6;
        c_x3 = c_x;
        c_y3 = c_y - vif.diameter * $sqrt(3)/3;

        vif.done  <= 1'b0;

        // Clear Screen
        fillscreen();
        
        ref_state = triangle_ref_pkg::DRAW_TRIANGLE;

        $display("[%0t ns][ref_model] Running triangle Drawing", $time);
        @(posedge vif.clk); 

        vif.vga_x = 0;
        vif.vga_y = 0;

        draw_circle_segment(vif.diameter, c_x1, c_y1, BLUE); @(posedge vif.clk); // Wait done
        draw_circle_segment(vif.diameter, c_x2, c_y2, GREEN);  @(posedge vif.clk); // Wait done
        draw_circle_segment(vif.diameter, c_x3, c_y3, RED);   @(posedge vif.clk); // Wait done

        vif.vga_plot = 1'b0;
        vif.done  <= 1'b1;

        @(posedge vif.clk); 

        vif.vga_x <=  'b0;
        vif.vga_y <=  'b0;
        ref_state = triangle_ref_pkg::REF_DONE;
        $display("Draw triangle done");

    endtask

    // Fillscreen module ref
    task fillscreen();
        $display("[%0t ns][ref_model] Running clear screen", $time);
        ref_state = triangle_ref_pkg::CLEAR;
        vif.vga_plot = 1'b1;

        fork
            begin : clear_loop 
                for (int x = 0; x <= 159; x++) begin
                    for (int y = 0; y <= 119; y++) begin
                        if (vif.forced_early_clear) begin
                            disable clear_loop; // exit both loops
                        end
                        @(posedge vif.clk);
                        vif.vga_x      <= x;
                        vif.vga_y      <= y;
                        vif.vga_colour <= 'b0;
                    end
                end
            end

            if (vif.forced_early_clear == 1'b1)
                #0;
        join
    endtask

    // Draws a partial circle that only contains what can be in the reuleaux triangle, the
    // octants drawn is determined by SEGMENT_TYPE
    task draw_circle_segment(int radius, int centre_x, int centre_y, e_segment_type SEGMENT_TYPE);

        int offset_x;
        int offset_y;
        int crit;

        $display("[%0t ns] Drawing segment type %s", $time, SEGMENT_TYPE.name());

        offset_y = 0;
        offset_x = radius;
        crit     = 1 - radius;
        
        vif.vga_plot = 1'b0;

        @(posedge vif.clk); 

        vif.vga_colour = vif.colour;

        case(SEGMENT_TYPE)
            GREEN: begin 
                vif.vga_x = c_x2;
                if (c_y2 > 0) begin 
                    vif.vga_y = c_y2;
                    if (seg_valid(vif.vga_x, SEGMENT_TYPE)) begin
                        vif.vga_plot = 1'b1;
                    end
                end
                else vif.vga_y = 0;
            end
            BLUE : begin 
                vif.vga_x = c_x1;
                vif.vga_y = c_y1;
                if (c_y1 > 0) begin
                    vif.vga_y = c_y1;
                    if (seg_valid(vif.vga_x, SEGMENT_TYPE)) begin
                        vif.vga_plot = 1'b1;
                    end
                end
                else vif.vga_y = 0;
            end
            RED  : begin 
                vif.vga_x = c_x3;
                vif.vga_y = c_y3;
                if (c_y3 > 0) begin 
                    vif.vga_y = c_y3;
                    if (seg_valid(vif.vga_x, SEGMENT_TYPE)) begin
                        vif.vga_plot = 1'b1;
                    end
                end
                else vif.vga_y = 0;
            end
        endcase

        vif.vga_plot = 1'b0;

        @(posedge vif.clk); 

        // Main circle segment drawing loop. Cycle by cycle check in monitor begins here
        while (offset_y <= offset_x) begin
            case(SEGMENT_TYPE)
                GREEN: draw_green_segment(centre_x, centre_y, offset_x, offset_y, SEGMENT_TYPE);
                BLUE : draw_blue_segment (centre_x, centre_y, offset_x, offset_y, SEGMENT_TYPE);
                RED  : draw_red_segment  (centre_x, centre_y, offset_x, offset_y, SEGMENT_TYPE);
            endcase

            offset_y = offset_y + 1;
            if (crit <= 0) begin
                crit = crit + 2 * offset_y + 1;
            end
            else begin
                offset_x = offset_x - 1;
                crit = crit + 2 * (offset_y - offset_x) + 1;
            end
        end
    endtask

    // Different segments are associated with different octants. 
    // These are the same octants that should be drawn in the DUT to speed up 
    // how many cycles is required to draw the full releaux triangle
    task draw_green_segment(int centre_x, int centre_y, int offset_x, int offset_y, e_segment_type SEGMENT_TYPE);
        setPixel(centre_x + offset_y, centre_y - offset_x, SEGMENT_TYPE); //  -- octant 7
        setPixel(centre_x + offset_x, centre_y - offset_y, SEGMENT_TYPE); //  -- octant 8
    endtask

    task draw_blue_segment(int centre_x, int centre_y, int offset_x, int offset_y, e_segment_type SEGMENT_TYPE);
        setPixel(centre_x - offset_x, centre_y - offset_y, SEGMENT_TYPE); //  -- octant 5
        setPixel(centre_x - offset_y, centre_y - offset_x, SEGMENT_TYPE); //  -- octant 6
    endtask

    task draw_red_segment(int centre_x, int centre_y, int offset_x, int offset_y, e_segment_type SEGMENT_TYPE);
        setPixel(centre_x + offset_y, centre_y + offset_x, SEGMENT_TYPE); //  -- octant 2
        setPixel(centre_x - offset_y, centre_y + offset_x, SEGMENT_TYPE); //  -- octant 3
    endtask

    // Main draw pixel task that toggles values on the reference interface
    // Ref interface is compared cycle by cycle with the DUT interface
    task setPixel(int x, int y, e_segment_type SEGMENT_TYPE);

        @(posedge vif.clk);

        if (inside_x(x) && inside_y(y)) vif.vga_x = x;
        else                            vif.vga_x = 'b0;

        if (inside_x(x) && inside_y(y)) vif.vga_y = y;
        else                            vif.vga_y = 'b0;

        if (seg_valid(x, SEGMENT_TYPE)) begin
            if (inside_x(x) && inside_y(y)) vif.vga_plot = 1'b1;
            else                            vif.vga_plot = 1'b0;
        end
        else begin
            vif.vga_plot = 1'b0;
        end        

        @(negedge vif.clk);
    endtask

    // --------------- VALIDATION FUNCTIONS --------------

    function bit seg_valid(int x, e_segment_type SEGMENT_TYPE);
        case (SEGMENT_TYPE)
            BLUE   : seg_valid = (x <= c_x3) ? 1 : 0;
            GREEN  : seg_valid = (x >= c_x3) ? 1 : 0;
            RED    : seg_valid = (x <= c_x1 && x >= c_x2) ? 1 : 0;
            default: seg_valid = 0;
        endcase
    endfunction

    function bit inside_x(int x);
        if (x >= 0 && x <= 159) return 1;
        else                    return 0;
    endfunction

    function bit inside_y(int y);
        if (y >= 0 && y <= 119) return 1;
        else                    return 0;
    endfunction

endmodule