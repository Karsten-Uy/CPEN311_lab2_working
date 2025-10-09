`timescale 1ns/1ns

module triangle_test_seq (
    triangle_if vif,
    phases phases
);

    import lab_pkg::*;

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

    task run();
        vif.forced_early_clear = 1'b0;

        // Test that multiple iterations operate properly
        random_centre();
        random_centre();

        // Randomize centres many times to catch errors
        repeat(50) begin
            random_centre(.early_clear(1));
        end
    endtask

    task force_early_clear();
        vif.forced_early_clear = 1'b1;
        // Use to force DUT state to skip CLEAR_SCREEN state once it's been verified
        // `ifndef GLS
        // if (DUT.TRIANGLE_FSM.state != BLACK) begin
        //     @(DUT.TRIANGLE_FSM.state == BLACK) begin
        //         @(posedge vif.clk);
        //         @(posedge vif.clk);
        //         force DUT.TRIANGLE_FSM.state = FSM1;
        //         @(posedge vif.clk);
        //         release DUT.TRIANGLE_FSM.state;
        //     end
        // end
        // `else
        //     $fatal("Attempted to access internal path during GLS");
        // `endif 
    endtask

    task wait_done_and_deassert();
        @(vif.done);
        repeat($urandom_range(0,20)) @(posedge vif.clk);
        vif.start = 1'b0;

        // Wait some random time before next start
        repeat($urandom_range(10,20)) @(posedge vif.clk);
    endtask

    // -------------- RANDOMIZED CASES --------------

    task random_centre(bit early_clear=0);
        vif.centre_x = $urandom_range(60, 120); 
        vif.centre_y = $urandom_range(40, 60);

        vif.diameter = $urandom_range(60, 100);
        vif.start = 1'b1;

        fork
            if (early_clear) force_early_clear();
            wait_done_and_deassert(); 
        join
    endtask

endmodule // circle_test_seq