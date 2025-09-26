`timescale 1ns/1ns
`include "macro.f"

module tb_template();

    import lab_pkg::*;

    // --------------------  VERIFICATION COMPONENTS --------------------
    // Used to synchronize test with monitors + checkers 
    phases     phases();

    // Interfaces
    fsm_if     fsm_if();

    // Main DUT stimulus
    fsm_test_seq test_seq (.vif(fsm_if), .phases(phases));

    // Test checking and coverage
    fsm_monitor monitor(.vif(fsm_if), .phases(phases));

    // Alias internal DUT signal to generic name in interface for use in monitor
    `ifndef GLS
        assign fsm_if.state = DUT.state; 
    `else
        `include "gls_probes.sv"
        `define PATH_TO_FSM DUT
        `GLS_PROBES
    `endif 

    // --------------------  DUT INSTANTIATION --------------------
    statemachine DUT (
        .slow_clock        (fsm_if.slow_clock),
        .resetb            (fsm_if.resetb),

        .dscore            (fsm_if.dscore),
        .pscore            (fsm_if.pscore),
        .pcard3            (fsm_if.pcard3),
        .load_pcard1       (fsm_if.load_pcard1),
        .load_pcard2       (fsm_if.load_pcard2),
        .load_pcard3       (fsm_if.load_pcard3),
        .load_dcard1       (fsm_if.load_dcard1),
        .load_dcard2       (fsm_if.load_dcard2),
        .load_dcard3       (fsm_if.load_dcard3),
        .player_win_light  (fsm_if.player_win_light),
        .dealer_win_light  (fsm_if.dealer_win_light)
    );

    // -------------------- RUNNING TEST AND COLLECT COVERAGE --------------------

    event TEST_DONE;
    int ERROR_COUNT = 0;

    // TODO: Implement better phasing mechanism
    // TODO: Report verbosity mechanism 
    initial begin
        // Treat as run_phase()
        fork
            test_seq.start();
            monitor.start();
        join

        -> TEST_DONE;

    end

    initial begin
        #500us;
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
