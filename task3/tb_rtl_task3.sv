module tb_rtl_task3();

    // Your testbench goes here. Our toplevel will give up after 1,000,000 ticks.

    import lab_pkg::*;

    // --------------------  VERIFICATION COMPONENTS --------------------
    // Used to synchronize test with monitors + checkers 
    phases     phases();

    // Interfaces
    top_if dut_if();
    circle_if circ_dut_if();
    circle_monitor circle_monitor(.vif(circ_dut_if), .phases(phases));

    // Main DUT stimulus
    top_test_seq test_seq (.vif(dut_if), .phases(phases));

    // --------------------  DUT INSTANTIATION --------------------
    // circle DUT (
    //     .clk          (circ_dut_if.clk), 
    //     .rst_n        (circ_dut_if.rst_n),
    //     .colour       (circ_dut_if.colour),
    //     .centre_x     (circ_dut_if.centre_x),
    //     .centre_y     (circ_dut_if.centre_y),
    //     .radius       (circ_dut_if.radius),
    //     .start        (circ_dut_if.start),
    //     .done         (circ_dut_if.done),
    //     .vga_x        (circ_dut_if.vga_x),
    //     .vga_y        (circ_dut_if.vga_y),
    //     .vga_colour   (circ_dut_if.vga_colour),
    //     .vga_plot     (circ_dut_if.vga_plot)
    // );

    task3 DUT (
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

    assign circ_dut_if.clk         = dut_if.CLOCK_50;
    assign circ_dut_if.rst_n       = dut_if.KEY[3];
    assign circ_dut_if.start       = dut_if.KEY[0];

    /*
     * NOTE: the inputs into the circle module are hardcoded so 
     *       they are hardcoded when passed into the ref model
     */
    assign circ_dut_if.radius   = 8'd40;
    assign circ_dut_if.centre_x = 8'd80;
    assign circ_dut_if.centre_y = 8'd60;

    assign circ_dut_if.done        = dut_if.LEDR[0];
    assign circ_dut_if.vga_x       = dut_if.VGA_X;
    assign circ_dut_if.vga_y       = dut_if.VGA_Y;
    assign circ_dut_if.vga_colour  = dut_if.VGA_COLOUR;
    assign circ_dut_if.vga_plot    = dut_if.VGA_PLOT;

    // -------------------- RUNNING TEST AND COLLECT COVERAGE --------------------
    int ERROR_COUNT = 0;



    initial begin
        // Treat as run_phase()
        fork
            test_seq.start();
            circle_monitor.start();
        join
    end

    initial begin
        @(phases.run_phase==1);

        repeat(1_000_000) @(posedge circ_dut_if.clk);
        // repeat(200) @(posedge circ_dut_if.clk);

        phases.run_phase = 0;
        phases.report_phase = 1;

        $error("Simulation Timeout!");
        ERROR_COUNT += 1;
    end

    initial begin
        @(phases.report_phase == 1) begin
            // Accumulate errors from all monitors and report
            circle_monitor.report();

            ERROR_COUNT += circle_monitor.ERROR_COUNT; // High level monitor failures
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

endmodule: tb_rtl_task3
