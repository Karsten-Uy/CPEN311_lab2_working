module tb_rtl_task4();

    import lab_pkg::*;

    // --------------------  VERIFICATION COMPONENTS --------------------
    // Used to synchronize test with monitors + checkers 
    phases     phases();

    // Interfaces
    top_if dut_if();
    triangle_if dut_triangle_if();
    triangle_monitor triangle_monitor(.vif(dut_triangle_if), .phases(phases));

    // Main DUT stimulus
    top_test_seq test_seq (.vif(dut_if), .phases(phases));

    // --------------------  DUT INSTANTIATION --------------------
    task4 DUT (
        .CLOCK_50   (dut_if.CLOCK_50),
        .KEY        (dut_if.KEY),
        .SW         (dut_if.SW),
        .LEDR       (dut_if.LEDR),
        .HEX0       (dut_if.HEX0),
        .HEX1       (dut_if.HEX1),
        .HEX2       (dut_if.HEX2),
        .HEX3       (dut_if.HEX3),
        .HEX4       (dut_if.HEX4),
        .HEX5       (dut_if.HEX5),
        .VGA_R      (dut_if.VGA_R),
        .VGA_G      (dut_if.VGA_G),
        .VGA_B      (dut_if.VGA_B),
        .VGA_HS     (dut_if.VGA_HS),
        .VGA_VS     (dut_if.VGA_VS),
        .VGA_CLK    (dut_if.VGA_CLK),
        .VGA_X      (dut_if.VGA_X),
        .VGA_Y      (dut_if.VGA_Y),
        .VGA_COLOUR (dut_if.VGA_COLOUR),
        .VGA_PLOT   (dut_if.VGA_PLOT)
    );

    assign dut_triangle_if.clk         = dut_if.CLOCK_50;
    assign dut_triangle_if.rst_n       = dut_if.KEY[3];
    assign dut_triangle_if.start       = dut_if.KEY[0];

    /*
     * NOTE: the inputs into the circle module are hardcoded so 
     *       they are hardcoded when passed into the ref model
     */
    assign dut_triangle_if.diameter   = 8'd80;
    assign dut_triangle_if.centre_x   = 8'd80;
    assign dut_triangle_if.centre_y   = 8'd60;
    assign dut_triangle_if.colour = 3'd2;

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

        repeat(1_000_000) @(posedge dut_if.CLOCK_50);

        phases.run_phase = 0;
        phases.report_phase = 1;

        $error("Simulation Timeout!");
        ERROR_COUNT += 1;
    end

    initial begin
        @(phases.report_phase == 1) begin
            // // Accumulate errors from all monitors and report
            // circle_monitor.report();

            ERROR_COUNT += triangle_monitor.ERROR_COUNT; // High level monitor failures
            ERROR_COUNT += test_seq.ERROR_COUNT;       // Tightly coupled test checks
            // ERROR_COUNT += DUT.ERROR_COUNT;            // DUT design assertions
        
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

endmodule: tb_rtl_task4
