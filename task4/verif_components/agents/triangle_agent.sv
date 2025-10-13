`timescale 1ns/1ns

interface triangle_if;
    // Top level DUT signals
    logic       clk;
    logic       rst_n;
    logic [2:0] colour;
    logic [7:0] centre_x;
    logic [6:0] centre_y;
    logic [7:0] diameter;
    logic       start;
    logic       done;
    logic [7:0] vga_x;
    logic [6:0] vga_y;
    logic [2:0] vga_colour;
    logic       vga_plot;

    // Internal Signals
    import lab_pkg::*;
    bit forced_early_clear;

endinterface //triangle_if

module triangle_monitor (
    triangle_if vif,
    phases phases
);

    triangle_if ref_if();
    triangle_ref ref_model (.vif(ref_if), .phases(phases));

    // Reference model gets same input as DUT
    assign ref_if.clk      = vif.clk;
    assign ref_if.rst_n    = vif.rst_n;
    assign ref_if.colour   = vif.colour;
    assign ref_if.centre_x = vif.centre_x;
    assign ref_if.centre_y = vif.centre_y;
    assign ref_if.diameter = vif.diameter;
    assign ref_if.start    = vif.start;
    assign ref_if.forced_early_clear = vif.forced_early_clear;

    import lab_pkg::*;
    import triangle_ref_pkg::*;

    // -------------------------------------------------------
    // --------------------  COMMON TASKS --------------------
    // -------------------------------------------------------
    int ERROR_COUNT;
    bit Mismatch;

    task start();
        @(phases.run_phase == 1);
        fork
            monitor_error();
        join_none
    endtask

    task done();
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
            
    task scoreboard();
        fork
            ref_model.run();
        join_none

        while(phases.run_phase==1) begin
            @ (negedge vif.clk); // Synchonization event
            Mismatch = 0;

            if((ref_model.ref_state == triangle_ref_pkg::DRAW_TRIANGLE) && (ref_model.ref_state != lab_pkg::REUL_BLACK)) begin
                // Checks that x, y and color match with reference model
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
            end

            // Stop monitoring once both reached done states
            if(ref_model.ref_state == triangle_ref_pkg::REF_DONE) begin
                if (vif.done == 1'b0) begin
                    Mismatch = 1;
                    $error("DUT did not assert done signal");
                    ERROR_COUNT += 1;
                end
            end

        end
    endtask

    // Consume zero simulation time
    function void report();
    endfunction 

    function void report_error();
    endfunction
endmodule // triangle_monitor