`timescale 1ns/1ns

module fillscreen_test_seq (
    fillscreen_if vif,
    phases phases
);

    // import lab_pkg::*;

    // --------------------  DUT SPECIFIC VERIF COMPONENTS --------------------
    rst_clk_if     CLOCK_50_if();
    rst_clk_driver CLOCK_50_driver (.vif(CLOCK_50_if));

    assign vif.clk      = CLOCK_50_if.clk;
    assign vif.rst_n    = CLOCK_50_if.rst;

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

    //  Since the test has a timeout mechanism to flag this raise an error and should be accumulated later in tb.
    bit done_asserted;
    task run();

        vif.start = 1'b1;

        fork
            begin
                @(vif.done);
                done_asserted = 1;

                // Wait random time before deasserting start
                repeat($urandom_range(10,20)) @(posedge vif.clk);
                vif.start = 1'b0;
            end
            timeout();
        join_any

        // After done 10 more cycles
        repeat(10) @(posedge vif.clk);
    endtask

    task timeout();
        repeat(19210) @(posedge vif.clk);

        if (~done_asserted) begin
            $error("Done signal not asserted");
            ERROR_COUNT += 1;
        end
    endtask
endmodule // fillscreen_test_seq