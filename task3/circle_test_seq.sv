`timescale 1ns/1ns

typedef enum {
    MIN_0_10,
    MIN_10_30,
    MED_30_60,
    MED_60_100,
    MAX_100_200,
    MAX_200_255
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

        TOTAL_TEST = 10;

        repeat(TOTAL_TEST) begin
            TEST_COUNT += 1;
            $display("Test iter %0d/%0d", TEST_COUNT, TOTAL_TEST);

            repeat (4) begin
                randomize_inside_grid(.radius_type(MIN_0_10)); 
                randomize_inside_grid(.radius_type(MIN_10_30)); 
                randomize_inside_grid(.radius_type(MED_30_60)); 
                randomize_inside_grid(.radius_type(MED_60_100)); 
                randomize_inside_grid(.radius_type(MAX_100_200)); 
                randomize_inside_grid(.radius_type(MAX_200_255)); 
            end

            randomize_corner1(.radius_type(MIN_0_10)); 
            randomize_corner1(.radius_type(MIN_10_30)); 
            randomize_corner1(.radius_type(MED_30_60)); 
            randomize_corner1(.radius_type(MED_60_100)); 
            randomize_corner1(.radius_type(MAX_100_200)); 
            randomize_corner1(.radius_type(MAX_200_255)); 

            randomize_corner2(.radius_type(MIN_0_10)); 
            randomize_corner2(.radius_type(MIN_10_30)); 
            randomize_corner2(.radius_type(MED_30_60)); 
            randomize_corner2(.radius_type(MED_60_100)); 
            randomize_corner2(.radius_type(MAX_100_200)); 
            randomize_corner2(.radius_type(MAX_200_255)); 

            randomize_corner3(.radius_type(MIN_0_10)); 
            randomize_corner3(.radius_type(MIN_10_30)); 
            randomize_corner3(.radius_type(MED_30_60)); 
            randomize_corner3(.radius_type(MED_60_100)); 
            randomize_corner3(.radius_type(MAX_100_200)); 
            randomize_corner3(.radius_type(MAX_200_255)); 

            randomize_corner4(.radius_type(MIN_0_10)); 
            randomize_corner4(.radius_type(MIN_10_30)); 
            randomize_corner4(.radius_type(MED_30_60)); 
            randomize_corner4(.radius_type(MED_60_100)); 
            randomize_corner4(.radius_type(MAX_100_200)); 
            randomize_corner4(.radius_type(MAX_200_255)); 

            randomize_edge1(.radius_type(MIN_0_10)); 
            randomize_edge1(.radius_type(MIN_10_30)); 
            randomize_edge1(.radius_type(MED_30_60));
            randomize_edge1(.radius_type(MED_60_100)); 
            randomize_edge1(.radius_type(MAX_100_200)); 
            randomize_edge1(.radius_type(MAX_200_255));  

            randomize_edge2(.radius_type(MIN_0_10)); 
            randomize_edge2(.radius_type(MIN_10_30)); 
            randomize_edge2(.radius_type(MED_30_60));
            randomize_edge2(.radius_type(MED_60_100)); 
            randomize_edge2(.radius_type(MAX_100_200)); 
            randomize_edge2(.radius_type(MAX_200_255)); 

            randomize_edge3(.radius_type(MIN_0_10)); 
            randomize_edge3(.radius_type(MIN_10_30)); 
            randomize_edge3(.radius_type(MED_30_60));
            randomize_edge3(.radius_type(MED_60_100)); 
            randomize_edge3(.radius_type(MAX_100_200)); 
            randomize_edge3(.radius_type(MAX_200_255)); 

            randomize_edge4(.radius_type(MIN_0_10)); 
            randomize_edge4(.radius_type(MIN_10_30)); 
            randomize_edge4(.radius_type(MED_30_60));
            randomize_edge4(.radius_type(MED_60_100)); 
            randomize_edge4(.radius_type(MAX_100_200)); 
            randomize_edge4(.radius_type(MAX_200_255)); 

            randomize_outside_grid_1(.radius_type(MIN_0_10)); 
            randomize_outside_grid_1(.radius_type(MIN_10_30)); 
            randomize_outside_grid_1(.radius_type(MED_30_60)); 
            randomize_outside_grid_1(.radius_type(MED_60_100)); 
            randomize_outside_grid_1(.radius_type(MAX_100_200)); 
            randomize_outside_grid_1(.radius_type(MAX_200_255)); 

            randomize_outside_grid_2_3(.radius_type(MIN_0_10)); 
            randomize_outside_grid_2_3(.radius_type(MIN_10_30)); 
            randomize_outside_grid_2_3(.radius_type(MED_30_60)); 
            randomize_outside_grid_2_3(.radius_type(MED_60_100)); 
            randomize_outside_grid_2_3(.radius_type(MAX_100_200)); 
            randomize_outside_grid_2_3(.radius_type(MAX_200_255)); 

        end

    endtask

    task force_early_clear();
        // vif.forced_early_clear = 1'b1;
        // if (DUT.CIRCLE_FSM.state != CIRCLE_BLACK) begin
        //     @(DUT.CIRCLE_FSM.state == CIRCLE_BLACK) begin
        //         @(posedge vif.clk);
        //         @(posedge vif.clk);
        //         force DUT.CIRCLE_FSM.state = CIRCLE_OCT1;
        //         @(posedge vif.clk);
        //         release DUT.CIRCLE_FSM.state;
        //     end
        // end
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
    
    task rand_min1();
        vif.radius = $urandom_range(0, 10);
    endtask

    task rand_min2();
        vif.radius = $urandom_range(10, 30);
    endtask

    task rand_med1();
        vif.radius = $urandom_range(30, 60);
    endtask

    task rand_med2();
        vif.radius = $urandom_range(60, 100);
    endtask

    task rand_max1();
        vif.radius = $urandom_range(100, 200);
    endtask

    task rand_max2();
        vif.radius = $urandom_range(200, 255);
    endtask

    task randomize_radius(test_radius_type radius_type = 1);
        case (radius_type)
            MIN_0_10    : rand_min1();
            MIN_10_30   : rand_min2(); 
            MED_30_60   : rand_med1();
            MED_60_100  : rand_med2();
            MAX_100_200 : rand_max1();
            MAX_200_255 : rand_max2();
        endcase
    endtask

    // Corners

    task randomize_corner1(test_radius_type radius_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(0,5);     
        vif.centre_y = $urandom_range(0,5);
        vif.colour = $urandom_range(0,7);

        randomize_radius(radius_type);
        wait_done_and_deassert(); 
    endtask

    task randomize_corner2(test_radius_type radius_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(155,159);     
        vif.centre_y = $urandom_range(0,5);
        vif.colour = $urandom_range(0,7);

        randomize_radius(radius_type);
        wait_done_and_deassert(); 
    endtask

    task randomize_corner3(test_radius_type radius_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(0,5);     
        vif.centre_y = $urandom_range(115, 119);  
        vif.colour = $urandom_range(0,7);

        randomize_radius(radius_type);
        wait_done_and_deassert(); 
    endtask

    task randomize_corner4(test_radius_type radius_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(155,159);     
        vif.centre_y = $urandom_range(115, 119);  
        vif.colour = $urandom_range(0,7);

        randomize_radius(radius_type);
        wait_done_and_deassert(); 
    endtask

    // Edges

    task randomize_edge1(test_radius_type radius_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(0, 5);
        vif.centre_y = $urandom_range(5, 115);
        vif.colour = $urandom_range(0,7);

        randomize_radius(radius_type);
        wait_done_and_deassert();
    endtask

    task randomize_edge2(test_radius_type radius_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(5, 155);
        vif.centre_y = $urandom_range(0, 5);
        vif.colour = $urandom_range(0,7);

        randomize_radius(radius_type);
        wait_done_and_deassert();
    endtask

    task randomize_edge3(test_radius_type radius_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(155, 159); 
        vif.centre_y = $urandom_range(5, 115);
        vif.colour = $urandom_range(0,7);

        randomize_radius(radius_type);
        wait_done_and_deassert();
    endtask

    task randomize_edge4(test_radius_type radius_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(5, 155);   
        vif.centre_y = $urandom_range(115, 119);
        vif.colour = $urandom_range(0,7);

        randomize_radius(radius_type);
        wait_done_and_deassert();
    endtask

    task randomize_outside_grid(test_radius_type radius_type);
        vif.start = 1'b1;
        
        vif.centre_x = $urandom_range(160, 255); 
        vif.centre_y = $urandom_range(120, 127);
        vif.colour = $urandom_range(0,7);

        randomize_radius(radius_type);
        wait_done_and_deassert();
    endtask

    task randomize_outside_grid_1(test_radius_type radius_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(0, 159); 
        vif.centre_y = $urandom_range(120, 127);
        vif.colour = $urandom_range(0,7);

        randomize_radius(radius_type);
        wait_done_and_deassert();
    endtask

    task randomize_outside_grid_2_3(test_radius_type radius_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(160, 255); 
        vif.centre_y = $urandom_range(0, 127);
        vif.colour = $urandom_range(0,7);

        randomize_radius(radius_type);
        wait_done_and_deassert();
    endtask

    task randomize_inside_grid(test_radius_type radius_type, bit early_clear = 0);
        vif.start = 1'b1;
        
        vif.centre_x = $urandom_range(5, 155); 
        vif.centre_y = $urandom_range(5, 115);
        vif.colour = $urandom_range(0,7);

        randomize_radius(radius_type);
        fork
            if (early_clear) force_early_clear();
            wait_done_and_deassert(); 
        join

    endtask


endmodule // circle_test_seq