`timescale 1ns/1ns

// `define VISUAL // for seeing output on fake VGA with tb_rtl_task3_visual.sv

module circle_test_seq (
    circle_if vif,
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

    parameter COLOR_MAX    = 2**3 - 1;
    parameter CENTRE_X_MAX = 2**8 - 1;
    parameter CENTRE_Y_MAX = 2**7 - 1;
    parameter RADIUS_MAX   = 2**8 - 1;

    task run();
        // randomize_corner();
        // randomize_edge();


        vif.forced_early_clear = 1'b0;
        repeat(10) begin
            randomize_inside_grid();
        end

        repeat(10) begin
            randomize_inside_grid(.early_clear(1)); 
        end

    endtask

    task force_early_clear();
        vif.forced_early_clear = 1'b1;
        // Use to force DUT state to skip CLEAR_SCREEN state once it's been verified
        `ifdef VISUAL        
        if (DUT.CIRCLE.CIRCLE_FSM.state != CIRCLE_BLACK) begin
            @(DUT.CIRCLE.CIRCLE_FSM.state == CIRCLE_BLACK) begin
        `else
        if (DUT.CIRCLE_FSM.state != CIRCLE_BLACK) begin
            @(DUT.CIRCLE_FSM.state == CIRCLE_BLACK) begin
        `endif
                @(posedge vif.clk);
                @(posedge vif.clk);
                `ifdef VISUAL        
                    force DUT.CIRCLE.CIRCLE_FSM.state = CIRCLE_OCT1;
                `else
                    force DUT.CIRCLE_FSM.state = CIRCLE_OCT1;
                `endif
                @(posedge vif.clk);
                `ifdef VISUAL        
                    release DUT.CIRCLE.CIRCLE_FSM.state;
                `else
                    release DUT.CIRCLE_FSM.state;
                `endif
            end
        end
    endtask

    task wait_done_and_deassert();
        @(vif.done);
        repeat($urandom_range(0,20)) @(posedge vif.clk);
        vif.start = 1'b0;

        // Wait some random time before next start
        repeat($urandom_range(10,20)) @(posedge vif.clk);

    endtask


    // -------------- RANDOMIZED CASES --------------

    task draw_extreme_circles();
        // Test radius inputs at min anx max bounds
        // R = 0, 1, 255
        vif.radius   = 0;
        vif.start    = 1'b1;
        wait_done_and_deassert(); 

        vif.radius   = 1;
        vif.start    = 1'b1;
        wait_done_and_deassert(); 

        vif.radius   = 255;
        vif.start    = 1'b1;
        wait_done_and_deassert(); 
    endtask

    task randomize_corner();
        /*
            Implements randomization at one corner

            0---------------------------------1
            |                                 |
            |                                 |
            |                                 |
            |                                 |
            |                                 |
            3---------------------------------2
        */

        case ($urandom_range(0,3))
            'd0: begin vif.centre_x = 0;   vif.centre_y = 0;   end
            'd1: begin vif.centre_x = 159; vif.centre_y = 0;   end
            'd2: begin vif.centre_x = 159; vif.centre_y = 119; end
            'd3: begin vif.centre_x = 0;   vif.centre_y = 119; end
        endcase

        draw_extreme_circles();

        // R > 200
        vif.radius   = $urandom_range(201, RADIUS_MAX);
        vif.start    = 1'b1;
        wait_done_and_deassert(); 

        // Partially inside
        vif.radius   = $urandom_range(0, 160);
        vif.start    = 1'b1;
        wait_done_and_deassert(); 

    endtask

    task randomize_edge();
        /*
            Implements randomization along one edge

             ----------------1----------------
            |                                 |
            |                                 |
            0                                 2
            |                                 |
            |                                 |
             ----------------3----------------
        */

        int edge_idx;
        edge_idx = $urandom_range(0,3);

        case (edge_idx)
            'd0: begin vif.centre_x = 0;   vif.centre_y = $urandom_range(0, 119); end
            'd1: begin vif.centre_x = $urandom_range(0, 159); vif.centre_y = 0; end
            'd2: begin vif.centre_x = 159; vif.centre_y = $urandom_range(0, 119); end
            'd3: begin vif.centre_x = $urandom_range(0, 159); vif.centre_y = 119; end
        endcase

        draw_extreme_circles();

        if (edge_idx == 0 || edge_idx == 2) begin // left / right edges
            vif.radius   = 59;
            vif.start    = 1'b1;
            wait_done_and_deassert(); 

            vif.radius   = 60;
            vif.start    = 1'b1;
            wait_done_and_deassert(); 

            vif.radius   = 61;
            vif.start    = 1'b1;
            wait_done_and_deassert(); 
        end

        if (edge_idx == 1 || edge_idx == 3) begin // top/bottom edges
            vif.radius   = 79;
            vif.start    = 1'b1;
            wait_done_and_deassert(); 

            vif.radius   = 80;
            vif.start    = 1'b1;
            wait_done_and_deassert(); 

            vif.radius   = 81;
            vif.start    = 1'b1;
            wait_done_and_deassert(); 
        end


    endtask

    task randomize_outside_grid();
        /*
            Randomize such that the centre is outside

             ---------------------------------
            |                                 |
            |                                 |
            |                                 |
            |                                 |
            |                                 |
             ---------------------------------

                                   c
        */

    endtask

    task randomize_inside_grid(bit early_clear = 0);
        /*
            Randomize such that centre is inside

             ---------------------------------
            |                                 |
            |       c                         |
            |                                 |
            |                                 |
            |                                 |
             ---------------------------------
        */

        vif.centre_x = $urandom_range(60, 120); 
        vif.centre_y = $urandom_range(40, 60);
        vif.colour   = $urandom_range(1, 7);

        // Has potential to be partially outiside
        // TODO: Make tigher constraints to test fully inside and partially outside
        vif.radius = $urandom_range(90, 120);
        vif.start = 1'b1;



        fork
            if (early_clear) force_early_clear();
            wait_done_and_deassert(); 
        join

    endtask


endmodule // circle_test_seq