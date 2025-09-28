`timescale 1ns/1ns

interface fillscreen_if;
    // Top level DUT signals
    logic       clk;
    logic       rst_n;
    logic [2:0] colour;
    logic       start;
    logic       done;
    logic [7:0] vga_x;
    logic [6:0] vga_y;
    logic [2:0] vga_colour;
    logic       vga_plot;


    // Internal Signals
    import lab_pkg::*;
    e_FSM_state state;

endinterface //fillscreen_if

module fillscreen_monitor (
    fillscreen_if vif,
    phases phases
);

    fillscreen_if ref_if();
    fillscreen_ref ref_model (.vif(ref_if), .phases(phases));

    assign ref_if.clk = vif.clk;

    import lab_pkg::*;

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

    task done();
    endtask


    task monitor_error();
        ERROR_COUNT = 0;   
        fork
            count_pixels();
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

        foreach (exp_pixels[i]) begin
            if(!axp_pixels.exists(i)) begin
                ERROR_COUNT += 1;
                $error("%s is not found", i);
            end
        end

        foreach (axp_pixels[i]) begin
            if(!axp_pixels.exists(i)) begin
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

        // -> ref_model.rst_done;

        //  Monitor on negative edges of clocks
        if(vif.state != DRAW) begin
            @(vif.state == DRAW);
        end

        while (!vif.done) begin
            @(negedge vif.clk);
            // if (~vif.done) begin // done is on posedge. ignore this final check
                
            if (vif.vga_plot == 0 && vif.state == DRAW) begin
                $error("vga_plot signal not asserted");
                ERROR_COUNT += 1;
            end

            // Checks that x, y and color match with reference model
            if (vif.vga_x != ref_if.vga_x) begin
                $error("Mismatch in vga_x. exp=%0d, axp=%0d", ref_if.vga_x, vif.vga_x);
                ERROR_COUNT += 1;
            end

            if (vif.vga_y != ref_if.vga_y) begin
                $error("Mismatch in vga_y. exp=%0d, axp=%0d", ref_if.vga_x, vif.vga_y);
                ERROR_COUNT += 1;
            end

            if (vif.vga_colour != ref_if.vga_colour) begin
                $error("Mismatch in vga_colour. exp=%0d, axp=%0d", ref_if.vga_colour, vif.vga_colour);
                ERROR_COUNT += 1;
            end
            // end
        end
    endtask

    // Consume zero simulation time
    function void report();
    endfunction 

    function void report_error();
    endfunction
endmodule // fillscreen_monitor