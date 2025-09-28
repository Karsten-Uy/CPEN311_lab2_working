
`timescale 1ns/1ns

module tb_rtl_fillscreen();

    import lab_pkg::*;

    // --------------------  VERIFICATION COMPONENTS --------------------
    // Used to synchronize test with monitors + checkers 
    phases     phases();

    // Interfaces
    fillscreen_if    dut_if();             
    fsm_if           dut_fsm_if();             

    // Main DUT stimulus
    fillscreen_test_seq test_seq (.vif(dut_if), .phases(phases));

    // Test checking and coverage
    fillscreen_monitor monitor(.vif(dut_if), .phases(phases));
    fsm_monitor        fsm_monitor(.vif(dut_fsm_if), .phases(phases));

    // --------------------  DUT INSTANTIATION --------------------
    fillscreen DUT (        
        .clk           (dut_if.clk),
        .rst_n         (dut_if.rst_n),
        .colour        (dut_if.colour),
        .start         (dut_if.start),
        .done          (dut_if.done),
        .vga_x         (dut_if.vga_x),
        .vga_y         (dut_if.vga_y),
        .vga_colour    (dut_if.vga_colour),
        .vga_plot      (dut_if.vga_plot)
    );

    // // NOTE: cannot do for GLS
    assign dut_fsm_if.state      = DUT.FSM.state;
    assign dut_fsm_if.clk        = DUT.FSM.clk;
    assign dut_fsm_if.rst_n      = DUT.FSM.rst_n;
    assign dut_fsm_if.start      = DUT.FSM.start;
    assign dut_fsm_if.x_count    = DUT.FSM.x_count;
    assign dut_fsm_if.y_count    = DUT.FSM.y_count;
    assign dut_fsm_if.done       = DUT.FSM.done;
    assign dut_fsm_if.vga_x      = DUT.FSM.vga_x;
    assign dut_fsm_if.vga_y      = DUT.FSM.vga_y;
    assign dut_fsm_if.vga_colour = DUT.FSM.vga_colour;
    assign dut_fsm_if.vga_plot   = DUT.FSM.vga_plot;
    assign dut_fsm_if.x_en       = DUT.FSM.x_en;
    assign dut_fsm_if.y_en       = DUT.FSM.y_en;
    assign dut_fsm_if.x_rst      = DUT.FSM.x_rst;
    assign dut_fsm_if.y_rst      = DUT.FSM.y_rst;

    // -------------------- RUNNING TEST AND COLLECT COVERAGE --------------------

    event TEST_DONE;
    int ERROR_COUNT = 0;

    initial begin
        // Treat as run_phase()
        fork
            test_seq.start();
            monitor.start();
            fsm_monitor.start();
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

endmodule: tb_rtl_fillscreen
