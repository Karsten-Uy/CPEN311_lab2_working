`timescale 1ns/1ns

typedef enum {
    TEST_MIN,
    TEST_MED,
    TEST_MAX
} test_radius_type;

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

    // --------------------  RUN TASKS --------------------

    // Start the tests
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

    int TEST_COUNT;
    int TOTAL_TEST;

    // -------------------- TEST CASES --------------------

    // Main test stimuli
    task run();
        TEST_COUNT = 0;
        vif.forced_early_clear = 1'b0;

        // TOTAL_TEST = 100;
        TOTAL_TEST = 50;

        repeat(TOTAL_TEST) begin
            TEST_COUNT += 1;
            $display("Test iter %0d/%0d", TEST_COUNT, TOTAL_TEST);

            randomize_inside_grid(.radius_type(TEST_MIN)); 
            randomize_inside_grid(.radius_type(TEST_MED)); 
            randomize_inside_grid(.radius_type(TEST_MAX)); 

            randomize_corner(.radius_type(TEST_MIN)); 
            randomize_corner(.radius_type(TEST_MED)); 
            randomize_corner(.radius_type(TEST_MAX)); 

            randomize_edge(.radius_type(TEST_MIN)); 
            randomize_edge(.radius_type(TEST_MED)); 
            randomize_edge(.radius_type(TEST_MAX)); 

            // randomize_outside_grid(.radius_type(TEST_MIN)); 
            // randomize_outside_grid(.radius_type(TEST_MED)); 
            // randomize_outside_grid(.radius_type(TEST_MAX)); 

            randomize_outside_grid_1(.radius_type(TEST_MIN)); 
            randomize_outside_grid_1(.radius_type(TEST_MED)); 
            randomize_outside_grid_1(.radius_type(TEST_MAX)); 

            randomize_outside_grid_2_3(.radius_type(TEST_MIN)); 
            randomize_outside_grid_2_3(.radius_type(TEST_MED)); 
            randomize_outside_grid_2_3(.radius_type(TEST_MAX)); 
        end

    endtask

    task force_early_clear();
        vif.forced_early_clear = 1'b1;
        if (DUT.CIRCLE_FSM.state != CIRCLE_BLACK) begin
            @(DUT.CIRCLE_FSM.state == CIRCLE_BLACK) begin
                @(posedge vif.clk);
                @(posedge vif.clk);
                force DUT.CIRCLE_FSM.state = CIRCLE_OCT1;
                @(posedge vif.clk);
                release DUT.CIRCLE_FSM.state;
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
    // Too many inputs to simply to consider 100% as 
    // all centre_x, centre_y, radius inputs reached. 
    // Instead consider combinations of multiple bins
    // - min, normal, max radius
    // - centre inside screen
    // - centre at edge
    // - centre at corner
    // - centre outside screen 
    // The test cases here provide stimuli to provide 100% by the metrics described above
    
    task rand_min();
        vif.radius = $urandom_range(0, 30);
    endtask

    task rand_med();
        vif.radius = $urandom_range(30, 100);
    endtask

    task rand_max();
        vif.radius = $urandom_range(100, 255);
    endtask

    task randomize_radius(test_radius_type radius_type = 1);
        case (radius_type)
            TEST_MIN: rand_min();
            TEST_MED: rand_med();
            TEST_MAX: rand_max();
        endcase
    endtask

    task randomize_corner(test_radius_type radius_type);
        vif.start = 1'b1;

        case ($urandom_range(1,4))
            'd1: begin vif.centre_x = $urandom_range(0,5);     vif.centre_y = $urandom_range(0,5);     end
            'd2: begin vif.centre_x = $urandom_range(155,159); vif.centre_y = $urandom_range(0,5);     end
            'd3: begin vif.centre_x = $urandom_range(0,5);     vif.centre_y = $urandom_range(115,119); end
            'd4: begin vif.centre_x = $urandom_range(155,159); vif.centre_y = $urandom_range(115,119); end
        endcase

        randomize_radius(radius_type);
        wait_done_and_deassert(); 
    endtask

    task randomize_edge(test_radius_type radius_type);
        vif.start = 1'b1;

        case ($urandom_range(1,4))
            'd1: begin vif.centre_x = $urandom_range(0, 5);     vif.centre_y = $urandom_range(5, 115);   end
            'd2: begin vif.centre_x = $urandom_range(5, 155);   vif.centre_y = $urandom_range(0, 5);     end
            'd3: begin vif.centre_x = $urandom_range(155, 159); vif.centre_y = $urandom_range(5, 115);   end
            'd4: begin vif.centre_x = $urandom_range(5, 155);   vif.centre_y = $urandom_range(115, 119); end
        endcase

        randomize_radius(radius_type);
        wait_done_and_deassert();
    endtask

    task randomize_outside_grid(test_radius_type radius_type);
        vif.start = 1'b1;
        vif.centre_x = $urandom_range(160, 255); 
        vif.centre_y = $urandom_range(120, 127);

        randomize_radius(radius_type);
        wait_done_and_deassert();
    endtask

    task randomize_outside_grid_1(test_radius_type radius_type);
        vif.start = 1'b1;
        vif.centre_x = $urandom_range(0, 159); 
        vif.centre_y = $urandom_range(120, 127);

        randomize_radius(radius_type);
        wait_done_and_deassert();
    endtask

    task randomize_outside_grid_2_3(test_radius_type radius_type);
        vif.start = 1'b1;
        vif.centre_x = $urandom_range(160, 255); 
        vif.centre_y = $urandom_range(0, 127);

        randomize_radius(radius_type);
        wait_done_and_deassert();
    endtask

    task randomize_inside_grid(test_radius_type radius_type, bit early_clear = 0);
        vif.start = 1'b1;
        vif.centre_x = $urandom_range(5, 155); 
        vif.centre_y = $urandom_range(5, 115);
        randomize_radius(radius_type);

        fork
            if (early_clear) force_early_clear();
            wait_done_and_deassert(); 
        join

    endtask


endmodule // circle_test_seq