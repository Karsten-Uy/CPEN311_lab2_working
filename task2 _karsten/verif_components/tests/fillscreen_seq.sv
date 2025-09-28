`timescale 1ns/1ns

module fillscreen_test_seq (
    fillscreen_if vif,
    phases phases
);

    import lab_pkg::*;

    // --------------------  DUT SPECIFIC VERIF COMPONENTS --------------------
    rst_clk_if clk_if();

    rst_clk_driver clk_driver (.vif(clk_if));

    assign vif.clk        = clk_if.clk;
    assign vif.rst_n      = clk_if.rst;

    task start();
        phases.reset_phase = 1;
        clk_driver.start(.active_low(1), .freq_hz(50_000_000));
        phases.reset_phase = 0;

        phases.run_phase = 1;
        run();
        phases.run_phase = 0;

        phases.report_phase = 1;
    endtask // start

    task run();

        vif.start = 1'b0;
        @(posedge vif.clk);
        vif.start = 1'b1;

        repeat(19210)
            @(posedge vif.clk);
        
    endtask

endmodule