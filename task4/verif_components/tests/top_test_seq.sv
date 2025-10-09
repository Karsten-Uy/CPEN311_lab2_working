`timescale 1ns/1ns

module top_test_seq (
    top_if vif,
    phases phases
);

    // import lab_pkg::*;

    // --------------------  DUT SPECIFIC VERIF COMPONENTS --------------------
    rst_clk_if     CLOCK_50_if();
    rst_clk_driver CLOCK_50_driver (.vif(CLOCK_50_if));

    assign vif.CLOCK_50 = CLOCK_50_if.clk;
    assign vif.KEY[3]   = CLOCK_50_if.rst;

    int ERROR_COUNT;

    task start();
        phases.reset_phase = 1;
        CLOCK_50_driver.start(.active_low(1), .freq_hz(50_000_000));
        phases.reset_phase = 0;

        phases.run_phase = 1;
        run();
        phases.run_phase = 0;

        phases.report_phase = 1;
    endtask // start

    parameter COLOR_MAX    = 2**3 - 1;
    parameter CENTRE_X_MAX = 2**8 - 1;
    parameter CENTRE_Y_MAX = 2**7 - 1;
    parameter RADIUS_MAX   = 2**8 - 1;

    task run();

        test_default(); 

    endtask

    // task wait_done_and_deassert();
    //     @(vif.LEDR[0]);

    //     repeat($urandom_range(0,20)) @(posedge vif.CLOCK_50);
    //     vif.KEY[0] = 1'b0;

    //     // Wait some random time before next start
    //     repeat($urandom_range(10,20)) @(posedge vif.CLOCK_50);
    // endtask

    task test_default();
    
        vif.KEY[0] = 1'b1;
        // wait_done_and_deassert(); 

        @(vif.LEDR[0]);

        repeat($urandom_range(0,20)) @(posedge vif.CLOCK_50);
        vif.KEY[0] = 1'b0;

        // Wait some random time before next start
        repeat($urandom_range(10,20)) @(posedge vif.CLOCK_50);


    endtask


endmodule // top_test_seq