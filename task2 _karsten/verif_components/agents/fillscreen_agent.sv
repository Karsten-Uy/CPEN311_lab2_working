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
        report_error();
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
        first_pixel = 1; // no previous pixel yet

        while (phases.run_phase) begin
            @(posedge vif.clk);

            curr_x = vif.vga_x;
            curr_y = vif.vga_y;

            if (vif.vga_plot) begin
                if (!first_pixel) begin
                    // Only check increments if this is NOT the first pixel
                    if (prev_x == 159) begin
                        if (curr_x != 0)
                            $error("curr_x did not wrap: curr_x=%0d prev_x=%0d", curr_x, prev_x);
                        if (curr_y != prev_y + 1 && prev_y < 119)
                            $error("curr_y did not increment on line wrap: curr_y=%0d prev_y=%0d", curr_y, prev_y);
                        if (prev_y == 119 && curr_y != 0)
                            $error("curr_y did not wrap at frame end: curr_y=%0d prev_y=%0d", curr_y, prev_y);
                    end else begin
                        if (curr_x != prev_x + 1)
                            $error("curr_x increment error: curr_x=%0d prev_x=%0d", curr_x, prev_x);
                        if (curr_y != prev_y)
                            $error("curr_y changed unexpectedly: curr_y=%0d prev_y=%0d", curr_y, prev_y);
                    end
                end
                first_pixel = 0; // clear the first pixel flag after first plot
                prev_x = curr_x;
                prev_y = curr_y;
            end
        end
    endtask

    string curr_image;


    // monitor_fill: record every plotted pixel (sample on clock)
    task monitor_fill();

        string key;
        PIXEL_COUNT = 0;
        DUPLICATE_COUNT = 0;

        // keep running while phase active
        while (phases.run_phase) begin
            @(posedge vif.clk);
            // if a pixel is being plotted this cycle, record it
            if (vif.vga_plot) begin
                key = $sformatf("%0d_%0d", int'(vif.vga_x), int'(vif.vga_y));
                if (screen_colour.exists(key)) begin
                    // duplicate write to same pixel - not necessarily fatal but worth noting
                    $warning("Duplicate pixel write at %s: prev_colour=%0d new_colour=%0d",
                             key, screen_colour[key], vif.vga_colour);
                    DUPLICATE_COUNT++;
                end else begin
                    screen_colour[key] = vif.vga_colour; // save colour (0..7)
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

        // iterate all expected coordinates
        for (int x = 0; x < 160; x++) begin
            for (int y = 0; y < 120; y++) begin
                key = $sformatf("%0d_%0d", int'(x), int'(y));
                expected_colour = x % 8; // Task 2: colour = x mod 8
                if (!screen_colour.exists(key)) begin
                    $error("MISSING pixel at x=%0d y=%0d (expected colour %0d)", x, y, expected_colour);
                    missing++;
                    $stop();
                end else begin
                    // check the colour
                    if (screen_colour[key] !== expected_colour) begin
                        $error("COLOUR MISMATCH at x=%0d y=%0d: expected %0d but saw %0d",
                               x, y, expected_colour, screen_colour[key]);
                        colour_mismatches++;
                    end
                    seen_total++;
                end
            end
        end

        // sanity checks and summary
        if (missing == 0 && colour_mismatches == 0) begin
            $display("REPORT: Screen fill SUCCESS. All %0d pixels present with correct colours.", seen_total);
        end else begin
            $display("REPORT: Screen fill found %0d missing pixels and %0d colour mismatches.", missing, colour_mismatches);
        end

        // additional diagnostics
        if (seen_total != PIXEL_COUNT) begin
            $warning("Pixel counts differ: recorded PIXEL_COUNT=%0d unique seen_total=%0d DUPLICATE_COUNT=%0d",
                     PIXEL_COUNT, seen_total, DUPLICATE_COUNT);
        end

        // If anything wrong, increment ERROR_COUNT so testbench can see failure
        if (missing != 0 || colour_mismatches != 0) begin
            ERROR_COUNT += (missing + colour_mismatches);
        end

    endfunction

    function void report_error();

    endfunction
endmodule // fillscreen_monitor