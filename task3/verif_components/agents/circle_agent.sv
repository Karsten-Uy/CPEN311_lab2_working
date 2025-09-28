`timescale 1ns/1ns

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
    e_FSM_state dut_state;
    e_FSM_state ref_state;

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
    assign ref_if.start    = vif.start;

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
    endtask

    // Consume zero simulation time
    function void report();
    endfunction 

    function void report_error();
    endfunction
endmodule // circle_monitor