interface top_if;

    logic CLOCK_50;
    logic [3:0] KEY;
    logic [9:0] SW;
    logic [9:0] LEDR;
    logic [6:0] HEX0;
    logic [6:0] HEX1;
    logic [6:0] HEX2;
    logic [6:0] HEX3;
    logic [6:0] HEX4;
    logic [6:0] HEX5;
    logic [7:0] VGA_R;
    logic [7:0] VGA_G;
    logic [7:0] VGA_B;
    logic VGA_HS;
    logic VGA_VS;
    logic VGA_CLK;
    logic [7:0] VGA_X;
    logic [6:0] VGA_Y;
    logic [2:0] VGA_COLOUR;
    logic VGA_PLOT;
    
endinterface //datapath_if


// TODO: maybe combine fillscreen and top agents into 1

module top_monitor (
    top_if vif,
    phases phases
);

    // -------------------------------------------------------
    // --------------------  COMMON TASKS --------------------
    // -------------------------------------------------------
    int ERROR_COUNT;

    task start();
        @(phases.run_phase == 1);
        fork
            monitor_error();        
        join_none
    endtask

    task monitor_error();
        ERROR_COUNT = 0;   
        fork
            monitor_clk_cycles();
            monitor_increment();
            monitor_fill();
            monitor_clear();
            monitor_end_screen();
        join_none
    endtask

    // Consume zero simulation time
    function void report();
        // report_screen();
    endfunction 

    // -----------------------------------------------------------
    // -----------------------------------------------------------
    // -----------------------------------------------------------

    int screen_colour[string];
    int PIXEL_COUNT;
    int DUPLICATE_COUNT;
    int counter;

    // -------------------- VARIBALE SETTING --------------------

    task monitor_clear();
        while (phases.run_phase) begin
            @(posedge vif.KEY[0]);
            screen_colour.delete();
            PIXEL_COUNT      = 0;
            DUPLICATE_COUNT  = 0;
            counter          = 0;
        end
    endtask

    // -------------------- MONITORING --------------------


    task monitor_clk_cycles();
        while (phases.run_phase) begin
            @(posedge vif.CLOCK_50);
            if (vif.KEY[0]) begin
                counter++;
                if ((counter > 19210) && (vif.LEDR[0] != 1'b1)) begin
                    $error("More than 19210 cycles needed to draw: %d", counter);
                    ERROR_COUNT++;
                end
            end
        end
    endtask

    logic [7:0] curr_x;
    logic [6:0] curr_y;
    logic [7:0] prev_x;
    logic [6:0] prev_y;
    
    // checks increment and ensure no overflow
    task monitor_increment();
        while (phases.run_phase) begin
            @(posedge vif.KEY[0]);
            prev_x = 0;
            prev_y = 0;

            while (vif.KEY[0]) begin
                @(posedge vif.CLOCK_50);

                curr_x = vif.VGA_X;
                curr_y = vif.VGA_Y;

                if (curr_x == 0 && curr_y == 0)
                    continue;

                if (vif.VGA_PLOT) begin
                    if (curr_x > 159) begin
                        $error("curr_x > 159: %d", curr_x);
                        ERROR_COUNT++;
                    end
                    if (curr_y > 119) begin
                        $error("curr_y > 119: %d", curr_y);
                        ERROR_COUNT++;
                    end

                    if (curr_x != 159) begin
                        if (curr_x != prev_x + ((prev_y == 119) ? 1 : 0)) begin
                            $error("curr_x != prev_x + ((prev_y == 119) ? 1 : 0): curr_x=%0d prev_x=%0d", curr_x, prev_x);
                            ERROR_COUNT++;
                        end

                        if (prev_y < 119) begin
                            if (curr_y != prev_y + 1) begin
                                $error("curr_y != expected increment: curr_y=%0d prev_y=%0d prev_x=%0d", curr_y, prev_y, prev_x);
                                ERROR_COUNT++;
                            end
                        end else begin
                            if (curr_y != 0) begin
                                $error("curr_y != 0 at frame wrap: curr_y=%0d", curr_y);
                                ERROR_COUNT++;
                            end
                        end
                    end
                end

                prev_x = curr_x;
                prev_y = curr_y;
            end
        end
    endtask

    // monitor_fill: record every plotted pixel (sample on clock)
    task monitor_fill();
        string key;

        while (phases.run_phase) begin
            @(posedge vif.CLOCK_50);
            if (vif.VGA_PLOT) begin
                key = $sformatf("%0d_%0d", int'(vif.VGA_X), int'(vif.VGA_Y));
                // TODO: maybe add intermediate checking, i dont think it is needed tho
                if (screen_colour.exists(key)) begin
                    $warning("Duplicate pixel write at %s: prev_colour=%0d new_colour=%0d",
                            key, screen_colour[key], int'(vif.VGA_COLOUR));
                    DUPLICATE_COUNT++;
                end else begin
                    screen_colour[key] = vif.VGA_COLOUR;
                    PIXEL_COUNT++;
                end
            end
        end
    endtask

    task monitor_end_screen();
        while (phases.run_phase) begin
            @(posedge vif.LEDR[0]);
            report_screen(); // Check screen on done
        end
    endtask
            
    // -------------------- Reporting --------------------

    int missing;
    int colour_mismatches;
    string key;
    int expected_colour;
    int seen_total;

    // function void report_screen();
    task report_screen();

        missing = 0;
        colour_mismatches = 0;
        seen_total = 0;

        $display("checking final screen at %0t", $time);

        // Behaviourly describe and then validate the screen here
        for (int x = 0; x < 160; x++) begin
            for (int y = 0; y < 120; y++) begin
                key = $sformatf("%0d_%0d", int'(x), int'(y));
                expected_colour = x % 8; 
                if (!screen_colour.exists(key)) begin
                    $error("MISSING pixel at x=%0d y=%0d (expected colour %0d)", x, y, expected_colour);
                    missing++;
                end else begin
                    // Validate colour
                    if (screen_colour[key] !== expected_colour) begin
                        $error("COLOUR MISMATCH at x=%0d y=%0d: expected %0d but saw %0d",
                               x, y, expected_colour, screen_colour[key]);
                        colour_mismatches++;
                    end
                    seen_total++;
                end
            end
        end

        if (missing != 0) begin
            $error("ERROR: Not all pixels have been written to");
            ERROR_COUNT += missing;
        end

        if (colour_mismatches != 0) begin
            $error("ERROR: %d pixels have colour mismatches", colour_mismatches);
            ERROR_COUNT += colour_mismatches;
        end

        if (seen_total != PIXEL_COUNT) begin
            $warning("Pixel counts differ: recorded PIXEL_COUNT=%0d unique seen_total=%0d DUPLICATE_COUNT=%0d",
                     PIXEL_COUNT, seen_total, DUPLICATE_COUNT);
        end

    endtask
    // endfunction

endmodule // fillscreen_monitor