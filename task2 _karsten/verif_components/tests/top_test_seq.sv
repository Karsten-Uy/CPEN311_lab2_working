`timescale 1ns/1ns

module top_test_seq (
    top_if vif,
    phases phases
);

    import lab_pkg::*;

    // --------------------  DUT SPECIFIC VERIF COMPONENTS --------------------
    rst_clk_if fast_clk_if();

    rst_clk_driver fast_clk_driver (.vif(fast_clk_if));

    assign vif.CLOCK_50 = fast_clk_if.clk;
    // assign vif.KEY[3] = fast_clk_if.rst;

    task start();
        phases.reset_phase = 1;
        fast_clk_driver.start(.active_low(1), .freq_hz(50_000_000));
        slow_clk_active_low_sync_rst();
        phases.reset_phase = 0;

        phases.run_phase = 1;
        run();
        phases.run_phase = 0;

        phases.report_phase = 1;
    endtask // start

    task run();
        repeat(150) begin
            repeat(15) begin
                random_press();
            end

            slow_clk_active_low_sync_rst();
        end
    endtask

    task slow_clk_active_low_sync_rst();
        vif.KEY[3] = 1'b0;
        random_press();
        vif.KEY[3] = 1'b1;
    endtask

    task random_press();
        int length_wait;
        int length_low;
        int random_offset;

        length_wait   = $urandom_range(5, 40);
        length_low    = $urandom_range(5, 15);
        random_offset = $urandom_range(10,50);

        vif.KEY[0] = 1;
        repeat(length_wait) @(vif.CLOCK_50);

        vif.KEY[0] = 0;
        repeat(length_low) @(vif.CLOCK_50);

        #(random_offset * 0.1ns);
    endtask

endmodule