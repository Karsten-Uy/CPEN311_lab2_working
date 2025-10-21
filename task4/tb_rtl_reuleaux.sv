module tb_rtl_reuleaux();

    import lab_pkg::*;

    // --------------------  VERIFICATION COMPONENTS --------------------
    // Used to synchronize test with monitors + checkers 
    phases     phases();

    // Interfaces
    triangle_if dut_if();
    triangle_monitor triangle_monitor(.vif(dut_if), .phases(phases));

    // Main DUT stimulus
    triangle_test_seq test_seq (.vif(dut_if), .phases(phases));

    // --------------------  DUT INSTANTIATION --------------------
    reuleaux DUT (
        .clk          (dut_if.clk), 
        .rst_n        (dut_if.rst_n),
        .colour       (dut_if.colour),
        .centre_x     (dut_if.centre_x),
        .centre_y     (dut_if.centre_y),
        .diameter     (dut_if.diameter),
        .start        (dut_if.start),
        .done         (dut_if.done),
        .vga_x        (dut_if.vga_x),
        .vga_y        (dut_if.vga_y),
        .vga_colour   (dut_if.vga_colour),
        .vga_plot     (dut_if.vga_plot)
    );

    // -------------------- RUNNING TEST AND COLLECT COVERAGE --------------------
    int ERROR_COUNT = 0;

    initial begin
        // Treat as run_phase()
        fork
            test_seq.start();
            triangle_monitor.start();
        join
    end

    initial begin
        @(phases.run_phase==1);

        // Mimic time out
        // repeat(1_000_000) @(posedge dut_if.clk);
        // repeat(5_000_000) @(posedge dut_if.clk);
        repeat(10_000_000) @(posedge dut_if.clk);

        // phases.run_phase = 0;
        // phases.report_phase = 1;

        $error("Simulation Timeout!");
        ERROR_COUNT += 1;
    end

    initial begin
        @(phases.report_phase == 1) begin
            // Accumulate errors from all monitors and report
            triangle_monitor.report();

            ERROR_COUNT += triangle_monitor.ERROR_COUNT; // High level monitor failures
            ERROR_COUNT += test_seq.ERROR_COUNT;       // Tightly coupled test checks
            // ERROR_COUNT += DUT.ERROR_COUNT;            // DUT design assertfions
        
            if (ERROR_COUNT != 0) begin
                $display("---------------------------");
                $display("***     TEST FAILED     ***");
                $display("---------------------------");
                $display();
                $display("ERROR_COUNT = %0d", ERROR_COUNT);
            end
            else begin
                $display("---------------------------");
                $display("***     TEST PASSED     ***");
                $display("---------------------------");
            end

            $stop;
        end
    end

endmodule: tb_rtl_reuleaux
