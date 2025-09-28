`timescale 1ns/1ns

module top_test_seq (
    top_if vif,
    phases phases
);

    import lab_pkg::*;

    // --------------------  DUT SPECIFIC VERIF COMPONENTS --------------------
    rst_clk_if clk_if();

    rst_clk_driver clk_driver (.vif(clk_if));

    assign vif.CLOCK_50        = clk_if.clk;
    assign vif.KEY[3]          = clk_if.rst;

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

        vif.KEY[0]  = 1'b1;

        repeat(19210)
            @(posedge vif.CLOCK_50);


        // TODO: Figure out how to make it run multiple times
        
        // repeat(3) begin

        //     vif.KEY[0]  = 1'b1;

        //     repeat(19210)
        //         @(posedge vif.CLOCK_50);

        //     vif.KEY[0]  = 1'b0;
        //     @(posedge vif.CLOCK_50);

        //     clk_driver.rst_start(.active_low(1));

        // end

            
    endtask

endmodule