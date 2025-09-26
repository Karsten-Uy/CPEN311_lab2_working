/*
 * This file contains the testbench for the statemachine module
 */

`timescale 1ns/1ns

module tb_statemachine();

    import lab_pkg::*;

    // --------------------  VERIFICATION COMPONENTS --------------------
    // Used to synchronize test with monitors + checkers 
    phases     phases();

    // Interfaces
    fsm_if    dut_if();             

    // Main DUT stimulus
    fsm_test_seq test_seq (.vif(dut_if), .phases(phases));

    // Test checking and coverage
    fsm_monitor monitor(.vif(dut_if), .phases(phases));

    // --------------------  DUT INSTANTIATION --------------------
    statemachine DUT (        
        .clk               (dut_if.clk),
        .rst_n             (dut_if.rst_n),
        .start             (dut_if.start),
        .x_count           (dut_if.x_count),
        .y_count           (dut_if.y_count),

        .done              (dut_if.done),
        .vga_x             (dut_if.vga_x),
        .vga_y             (dut_if.vga_y),
        .vga_colour        (dut_if.vga_colour),
        .vga_plot          (dut_if.vga_plot),
        .x_en              (dut_if.x_en),
        .y_en              (dut_if.y_en),
        .x_rst             (dut_if.x_rst),
        .y_rst             (dut_if.y_rst)
    );

    // NOTE: cannot do for GLS
    assign dut_if.state = DUT.state; 

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


endmodule
