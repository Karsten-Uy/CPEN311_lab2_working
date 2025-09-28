
`timescale 1ns/1ns

module tb_syn_task2();


    import lab_pkg::*;

    // --------------------  VERIFICATION COMPONENTS --------------------
    // Used to synchronize test with monitors + checkers 
    phases     phases();

    // Interfaces
    top_if           dut_if();               

    // Main DUT stimulus
    top_test_seq       test_seq (.vif(dut_if), .phases(phases));

    // Test checking and coverage
    top_monitor        monitor (.vif(dut_if), .phases(phases));

    // --------------------  DUT INSTANTIATION --------------------
    task2 DUT (        
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

    // -------------------- RUNNING TEST AND COLLECT COVERAGE --------------------

    event TEST_DONE;
    int ERROR_COUNT = 0;

    initial begin
        // Treat as run_phase()
        fork
            test_seq.start();
            monitor.start();
        join

        -> TEST_DONE;

    end

    initial begin
        #1000000us;
        $error("Simulation Timeout!");
        ERROR_COUNT += 1;
        -> TEST_DONE;
    end

    initial begin
        @(TEST_DONE) begin
            // Accumulate errors from all monitors and report
            monitor.report();

            ERROR_COUNT += monitor.ERROR_COUNT;
        
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

endmodule: tb_syn_task2
