`timescale 1ns/1ns

// Store the input parameters of a test
typedef struct { 
    int centre_x;
    int centre_y;
    int radius;
} test_item;

typedef enum {
    MIN_0_10,
    MIN_10_30,
    MED_30_60,
    MED_60_100,
    MAX_100_200,
    MAX_200_255
} radius_type_e;

typedef enum {
    MIDDLE1,
    MIDDLE2,
    MIDDLE3,
    MIDDLE4,

    EDGE1,
    EDGE2,
    EDGE3,
    EDGE4,

    CORNER1,
    CORNER2,
    CORNER3,
    CORNER4,

    OUTSIDE1,
    OUTSIDE2,
    OUTSIDE3
} centre_type_e ;


interface circle_if;
    // Top level DUT signals
    logic       clk;
    logic       rst_n;
    logic [2:0] colour;
    logic [7:0] centre_x;
    logic [6:0] centre_y;
    logic [7:0] radius;
    logic       start;
    logic       done;
    logic [7:0] vga_x;
    logic [6:0] vga_y;
    logic [2:0] vga_colour;
    logic       vga_plot;


    // Internal Signals
    import lab_pkg::*;
    circle_FSM_state dut_state;
    circle_FSM_state ref_state;
    bit forced_early_clear;

endinterface //circle_if

module circle_monitor (
    circle_if vif,
    phases phases
);

    circle_if ref_if();
    circle_ref ref_model (.vif(ref_if), .phases(phases));

    // Reference model gets same input as DUT
    assign ref_if.clk      = vif.clk;
    assign ref_if.rst_n    = vif.rst_n;
    assign ref_if.colour   = vif.colour;
    assign ref_if.centre_x = vif.centre_x;
    assign ref_if.centre_y = vif.centre_y;
    assign ref_if.radius   = vif.radius;
    assign ref_if.start    = vif.start;
    assign ref_if.forced_early_clear = vif.forced_early_clear;

    import lab_pkg::*;
    import circle_ref_pkg::*;

    // -------------------------------------------------------
    // --------------------  COMMON TASKS --------------------
    // -------------------------------------------------------
    int ERROR_COUNT;
    bit Mismatch;
    test_item test_item_arr [int];
    bit colors_drawn[int];
    bit pixels_drawn[string];

    task start();
        @(phases.run_phase == 1);
        fork
            monitor_error();
            monitor_coverage();
        join_none
    endtask

    task done();
    endtask
    
    // -------------------- MONITORING --------------------
    // These tasks run concurrently to the DUT

    task monitor_coverage();
        test_item item;
        int idx;

        // Everytime start is asserted log the values of the current test
        // to determine input coverage
        idx = 0;
        while (phases.run_phase == 1) begin
            @(vif.start == 1) begin
                item.centre_x = vif.centre_x;
                item.centre_y = vif.centre_y;
                item.radius   = vif.radius;

                test_item_arr[idx] = item;
                idx += 1;
            end
        end
    endtask

    task monitor_error();
        ERROR_COUNT = 0;   
        fork
            // count_pixels();
            scoreboard();
        join_none
    endtask

    task count_pixels();

        bit axp_pixels[string];
        bit exp_pixels[string];
        string pixel_loc;

        while (!vif.done) begin
            @(negedge vif.clk);

            if (vif.vga_plot) begin
                pixel_loc = $sformatf("x=%0d,y=%0d", vif.vga_x, vif.vga_y);
                axp_pixels[pixel_loc] = 1'b1;
            end
        end

        // Get expected array
        // Implementation of the fill screen algorithm
        for (int x = 0; x <= 159; x++) begin
            for (int y = 0; y <= 119; y++) begin
                pixel_loc = $sformatf("x=%0d,y=%0d", x, y);
                exp_pixels[pixel_loc] = 1'b1;
            end
        end

        // Check exp vs axp arrays against each other
        foreach (exp_pixels[i]) begin
            if(!axp_pixels.exists(i)) begin
                ERROR_COUNT += 1;
                $error("%s is not found", i);
            end
        end

        foreach (axp_pixels[i]) begin
            if(!exp_pixels.exists(i)) begin
                ERROR_COUNT += 1;
                $error("%s is not an expected pixel", i);
            end
        end

        if (axp_pixels.size() != exp_pixels.size()) begin
            $error("Not all pixels displayed");
            ERROR_COUNT += 1;
        end       

    endtask

    string key;
            
    task scoreboard();
        fork
            ref_model.run();
        join_none

        while(phases.run_phase==1) begin
            @ (negedge vif.clk); // Synchonization event
            Mismatch = 0;

            if (ref_if.vga_plot == 1'b1) begin
                key = $sformatf("%0d_%0d", int'(vif.vga_x), int'(vif.vga_y));
                if (!pixels_drawn.exists(key)) begin
                    pixels_drawn[key] = 1'b1;
                end
            end

            if((ref_model.ref_state == circle_ref_pkg::DRAW_CIRCLE) && (ref_if.ref_state != lab_pkg::CIRCLE_BLACK)) begin

                if (vif.vga_plot != ref_if.vga_plot) begin
                    Mismatch = 1;
                    $error("vga plot signals not matching");
                    ERROR_COUNT += 1;
                end

                if (ref_if.vga_plot == 1'b1) begin
                    if (vif.vga_x != ref_if.vga_x ) begin
                        Mismatch = 1;
                        $error("Mismatch in vga_x. exp=%0d, axp=%0d", ref_if.vga_x, vif.vga_x);
                        ERROR_COUNT += 1;
                    end
                    
                    if (vif.vga_y != ref_if.vga_y) begin
                        Mismatch = 1;
                        $error("Mismatch in vga_y. exp=%0d, axp=%0d", ref_if.vga_x, vif.vga_y);
                        ERROR_COUNT += 1;
                    end                    

                    if (vif.vga_colour != ref_if.vga_colour ) begin
                        Mismatch = 1;
                        $error("Mismatch in vga_colour in (x,y) = (%d,%d). exp=%0d, axp=%0d", ref_if.vga_x, ref_if.vga_y, ref_if.vga_colour, vif.vga_colour);
                        ERROR_COUNT += 1;
                    end else begin
                        if (!colors_drawn.exists(ref_if.vga_colour)) begin
                            colors_drawn[ref_if.vga_colour] = 1'b1;
                        end
                    end                    
                end
            end

            // Stop monitoring once both reached done states
            if(ref_model.ref_state == circle_ref_pkg::REF_DONE) begin
                if (vif.done == 1'b0) begin
                    Mismatch = 1;
                    $error("DUT did not assert done signal");
                    ERROR_COUNT += 1;
                end
            end

        end
    endtask

    // -------------------- REPORTING --------------------

    // Consume zero simulation time
    function void report();
        report_coverage();
    endfunction 

    // Since start, done, and vga_x/y behaviour is checked cycle by cycle via the ref model
    // no point in monitoring output covreage

    // Too many inputs to simply to consider 100% as 
    // all centre_x, centre_y, radius inputs reached. 
    // Instead consider combinations of multiple bins
    // - min, normal, max radius
    // - centre inside screen
    // - centre at edge
    // - centre at corner
    // - centre outside screen 
    // Consider a coverpoint hit if the combination is reached
    // e.g. max radius with centre offscreen
    // e.g. min radius with centre inside screen
    // e.g. normal raidius with centre at an edge

    bit cvg_grp [string];

    function void report_coverage();
        // Map radius type to N diff. values 
        // Map centre type to M diff. values 
        // 100% coverage requires N*M unique values

        // Radius mappings
        // - MIN: [ 0:10:30]
        // - MED: [30:60:100]
        // - MAX: [100:200:255]

        // Centre mappings:
        // - inside: 
        //      5<=x<=80  &&  5<=y<=60  -> MIDDLE1
        //     80<=x<=155 &&  5<=y<=60  -> MIDDLE2
        //      5<=x<=80  && 60<=y<=115 -> MIDDLE3
        //     80<=x<=155 && 60<=y<=115 -> MIDDLE4
        // - edge:
        //     x<=5    && 5<=y<=115 -> EDGE1
        //     y<=5    && 5<=x<=155 -> EDGE2
        //     x>= 155 && 5<=y<=115 -> EDGE3
        //     y>= 115 && 5<=x<=155 -> EDGE4
        // - corner:
        //     x <= 5    && y<= 5   -> CORNER1
        //     x >= 155  && y<= 5   -> CORNER2
        //     x <= 5    && y<= 115 -> CORNER3
        //     x >= 155  && y<= 115 -> CORNER4
        // - outside: 
        //     x<= 160 && y>=120  -> OUTSIDE1
        //    160<=x<=208         -> OUTSIDE2
        //    208<=x<=255         -> OUTSIDE3

        radius_type_e radius_type;
        centre_type_e centre_type;
        int x;
        int y;
        real coverage;
        real color_coverage;

        string cvg_sample;       

        // Map ranges centre x/y and radius inputs to locations on screen
        foreach (test_item_arr[i]) begin
            x = test_item_arr[i].centre_x;
            y = test_item_arr[i].centre_y;

            radius_type = get_radius_type(test_item_arr[i].radius);
            centre_type = get_centre_type(x, y);

            cvg_sample = $sformatf("%s - %s", centre_type.name(), radius_type.name());

            cvg_grp[cvg_sample] = 1'b1;
        end

        // Print total coverage
        coverage = cvg_grp.size() / real'(EXP_DRAW_REGIONS);
        color_coverage = colors_drawn.size() / real'(EXP_DRAW_COLORS);


        $display("The following test bins have been hit");
        foreach (cvg_grp[i]) begin
            $display(" - %s", i);
        end

        $display("Reached %0d/%0d bins. Coverage=%0.5f%%", cvg_grp.size(), EXP_DRAW_REGIONS, coverage*100);
        if (coverage != 1.0) begin
            ERROR_COUNT += 1;
        end

        $display("Reached %0d/%0d colors. Coverage=%0.5f%%", colors_drawn.size(), EXP_DRAW_COLORS, color_coverage*100);
        if (color_coverage != 1.0) begin
            ERROR_COUNT += 1;
        end
        
    endfunction

    function radius_type_e get_radius_type(int radius);
        if (radius <= 10)
            return MIN_0_10;
        else if (radius <= 30)
            return MIN_10_30;
        else if (radius <= 60)
            return MED_30_60;
        else if (radius <= 100)
            return MED_60_100;
        else if (radius <= 200)
            return MAX_100_200;
        else if (radius <= 255)
            return MAX_200_255;
        else
            $fatal("Invalid radius input during test");
    endfunction

    function centre_type_e get_centre_type(int x, int y);
        centre_type_e centre_type;

        if (inside_screen(x,y)) begin
            // Middle portion of screen
            if      ((x >= 5   && x <= 80)  && (y >= 5   && y <= 60))  centre_type = MIDDLE1;
            else if ((x >= 80  && x <= 155) && (y >= 5   && y <= 60))  centre_type = MIDDLE2;
            else if ((x >= 5   && x <= 80)  && (y >= 60  && y <= 115)) centre_type = MIDDLE3;
            else if ((x >= 80  && x <= 155) && (y >= 60  && y <= 115)) centre_type = MIDDLE4;

            // Edge regions 
            else if ((x <= 5)   && (y >= 5   && y <= 115)) centre_type = EDGE1;
            else if ((y <= 5)   && (x >= 5   && x <= 155)) centre_type = EDGE2;
            else if ((x >= 155) && (y >= 5   && y <= 115)) centre_type = EDGE3;
            else if ((y >= 115) && (x >= 5   && x <= 155)) centre_type = EDGE4;

            // Corner regions 
            else if ((x <= 5)   && (y <= 5))   centre_type = CORNER1;
            else if ((x >= 155) && (y <= 5))   centre_type = CORNER2;
            else if ((x <= 5)   && (y >= 115)) centre_type = CORNER3;
            else if ((x >= 155) && (y >= 115)) centre_type = CORNER4;

            else $fatal("Hit invalid input");            
        end
        else begin // Outside regions
            if      ((x <= 160) && (y >= 120)) centre_type = OUTSIDE1;
            else if ((x >= 160) && (x <= 208)) centre_type = OUTSIDE2;
            else if ((x >= 208) && (x <= 255)) centre_type = OUTSIDE3;
            else $fatal("Hit invalid input");
        end
        
        return centre_type;
    endfunction

    function inside_screen(int x, int y);
        if (x >= 0 && x < 160 && y >= 0 && y < 120)
            return 1'b1;
        else
            return 1'b0;
    endfunction

    // Top Level coverage
    function void report_top();
        report_coverage_top();
    endfunction 

    function void report_coverage_top();

        // For top level, we just ensure that all pixels have been hit
        real coverage;

        // Print total coverage
        coverage = pixels_drawn.size() / real'(EXP_PIXELS_DRAWN);

        $display("Reached %0d/%0d pixels. Coverage=%0.5f%%", pixels_drawn.size(), EXP_PIXELS_DRAWN, coverage*100);
        if (coverage != 1.0) begin
            ERROR_COUNT += 1;
        end
        
    endfunction

endmodule // circle_monitor