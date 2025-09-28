interface fillscreen_if;

    logic clk;
    logic rst_n;
    logic [2:0] colour;
    logic start;
    logic done;
    logic [7:0] vga_x;
    logic [6:0] vga_y;
    logic [2:0] vga_colour;
    logic vga_plot;
    
endinterface //fillscreen_if



module fillscreen_monitor (
    fillscreen_if vif,
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
        join_none
    endtask

    // Consume zero simulation time
    function void report();
        report_screen();
    endfunction 

    // -----------------------------------------------------------
    // -----------------------------------------------------------
    // -----------------------------------------------------------

    int screen_colour[string];   // map "x_y" -> colour (0..7)
    int PIXEL_COUNT = 0;
    int DUPLICATE_COUNT = 0;

    // -------------------- MONITORING --------------------

    int counter;

    task monitor_clk_cycles();
        counter = 0;
        @(posedge vif.start); // wait until start is asserted
        counter = 0;          // reset cycle counter

        while (phases.run_phase) begin
            @(posedge vif.clk);
            counter++;
            // if ((counter > 19209) && (vif.done != 1'b1)) begin
            if ((counter > 1909) && (vif.done != 1'b1)) begin
                $error("More than 19210 cycles needed to draw: %d", counter);
                ERROR_COUNT++;
                $stop;
            end
        end
    endtask

    logic [7:0] curr_x;
    logic [6:0] curr_y;
    logic [7:0] prev_x;
    logic [6:0] prev_y;
    
    // checks increment and ensure no overflow and all increments
    task monitor_increment();
        prev_x = 0;
        prev_y = 0;

        while (phases.run_phase) begin
            @(posedge vif.clk);

            curr_x = vif.vga_x;
            curr_y = vif.vga_y;

            if (curr_x == 0 && curr_y == 0) 
                continue;

            // Only check increments if a pixel is actually plotted
            if (vif.vga_plot) begin
                if (curr_x > 159) begin
                    $error("curr_x > 159: %d", curr_x);
                    ERROR_COUNT++;
                end
                if (curr_y > 119) begin
                    $error("curr_y > 119: %d", curr_y);
                    ERROR_COUNT++;
                end

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

            // Always update previous coordinates at the end of clock
            prev_x = curr_x;
            prev_y = curr_y;
        end
    endtask

    string curr_image;

    // monitor_fill: record every plotted pixel (sample on clock)
    task monitor_fill();

        string key;
        PIXEL_COUNT = 0;
        DUPLICATE_COUNT = 0;

        while (phases.run_phase) begin
            @(posedge vif.clk);
            if (vif.vga_plot) begin
                key = $sformatf("%0d_%0d", int'(vif.vga_x), int'(vif.vga_y));
                if (screen_colour.exists(key)) begin
                    $warning("Duplicate pixel write at %s: prev_colour=%0d new_colour=%0d",
                             key, screen_colour[key], vif.vga_colour);
                    DUPLICATE_COUNT++;
                end else begin
                    screen_colour[key] = vif.vga_colour;
                    PIXEL_COUNT++;
                end
            end
        end

    endtask
        
    // -------------------- Reporting --------------------

    int missing = 0;
    int colour_mismatches = 0;
    string key;
    int expected_colour;
    int seen_total = 0;

    function void report_screen();

        // Model of correct screen here
        for (int x = 0; x < 160; x++) begin
            for (int y = 0; y < 120; y++) begin
                key = $sformatf("%0d_%0d", int'(x), int'(y));
                expected_colour = x % 8; 
                if (!screen_colour.exists(key)) begin
                    $error("MISSING pixel at x=%0d y=%0d (expected colour %0d)", x, y, expected_colour);
                    missing++;
                    $stop();
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

        // additional diagnostics
        if (seen_total != PIXEL_COUNT) begin
            $warning("Pixel counts differ: recorded PIXEL_COUNT=%0d unique seen_total=%0d DUPLICATE_COUNT=%0d",
                     PIXEL_COUNT, seen_total, DUPLICATE_COUNT);
        end

    endfunction

endmodule // fillscreen_monitor