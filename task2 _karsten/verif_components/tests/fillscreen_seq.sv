`timescale 1ns/1ns

module datapath_test_seq (
    datapath_if vif,
    phases phases
);

    import lab_pkg::*;

    // --------------------  DUT SPECIFIC VERIF COMPONENTS --------------------
    rst_clk_if fast_clk_if();

    rst_clk_driver fast_clk_driver (.vif(fast_clk_if));

    assign vif.fast_clock = fast_clk_if.clk;
    assign vif.resetb     = fast_clk_if.rst;

    task start();
        phases.reset_phase = 1;
        fast_clk_driver.start(.active_low(1), .freq_hz(50_000_000));
        phases.reset_phase = 0;

        phases.run_phase = 1;
        run();
        phases.run_phase = 0;

        phases.report_phase = 1;
    endtask // start

    task run();
        repeat(100) begin
            repeat(60) begin
                random_press();
                random_load();
            end

            fast_clk_driver.rst_start(.active_low(1));
        end
    endtask

    task random_press();
        int length_wait;
        int length_slow;
        int random_offset;

        length_wait   = $urandom_range(5, 50);
        length_slow   = $urandom_range(5, 10);
        random_offset = $urandom_range(10,40);

        vif.slow_clock = 1;
        repeat(length_wait) @(vif.fast_clock);

        vif.slow_clock = 0;
        repeat(length_slow) @(vif.fast_clock);

        #(random_offset * 0.1ns);
    endtask

    // Fully randomize. Make no assumptions about the state of the incoming load signals
    task random_load();

        vif.load_pcard1 = $urandom % 2;
        vif.load_pcard2 = $urandom % 2;
        vif.load_pcard3 = $urandom % 2;

        vif.load_dcard1 = $urandom % 2;
        vif.load_dcard2 = $urandom % 2;
        vif.load_dcard3 = $urandom % 2;

    endtask

endmodule