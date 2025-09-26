

module fsm_test_seq(
    fsm_if vif,
    phases phases
);

    import lab_pkg::*;

    // --------------------  DUT SPECIFIC VERIF COMPONENTS --------------------
    rst_clk_if rst_clk_if();
    rst_clk_driver rst_clk_driver (.vif(rst_clk_if));

    assign vif.clk = rst_clk_if.clk;
    assign vif.rst_n = rst_clk_if.rst;

    logic [7:0] prev_x_count;
    logic [6:0] prev_y_count;

    task start();
        phases.reset_phase = 1;
        rst_clk_driver.start(.active_low(1), .freq_hz(5_000_000));
        phases.reset_phase = 0;

        // Finished reset. Can begin "run_phase()"
        phases.run_phase = 1;

        // // Randomized Tests
        // repeat(10) begin

        //     vif.start = 0;
        //     @(negedge vif.clk);
        //     vif.start = 1;
        //     @(negedge vif.clk);
        //     vif.start = 0;

        //     repeat(19210) @(negedge vif.clk)  begin
                
        //         vif.cycle_count++;
        //     end

        //     if (vif.state != DONE) begin 
        //         $error("  Didn't finish in enough clk cycles %s", vif.state); 
        //         vif.targeted_err_count++; 
        //     end

        //     rst_clk_driver.rst_start(.active_low(1));
        // end

        // Randomized Tests
        repeat(10) begin

            vif.start = 0;
            @(negedge vif.clk);
            vif.start = 1;
            @(negedge vif.clk);
            vif.start = 0;

            repeat(200) @(negedge vif.clk)  begin
                vif.x_count = $urandom_range(0, 159);
                vif.y_count = $urandom_range(0, 119);
            end

            @(negedge vif.clk);
            vif.x_count = 159;
            vif.y_count = 119;
            @(negedge vif.clk);

            rst_clk_driver.rst_start(.active_low(1));
        end

        phases.run_phase = 0;
        phases.report_phase = 1;
    endtask // start

endmodule