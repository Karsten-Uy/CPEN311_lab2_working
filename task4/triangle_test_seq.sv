`timescale 1ns/1ns

typedef enum {
    MIN_0_10,
    MIN_10_30,
    MED_30_60,
    MED_60_100,
    MAX_100_200,
    MAX_200_255
} test_diameter_type;

module triangle_test_seq (
    triangle_if vif,
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

    int TEST_COUNT;
    int TOTAL_TEST;

    task run();

        vif.forced_early_clear = 1'b0;

        // Perform test for test
        task4_test();  

        repeat(10) zero_test();

        // corner_test_cases();
        repeat(30) corner_test_cases();

        // // Randomize centres many times to catch errors
        // repeat(100) begin
        //     random_centre();
        // end

        TOTAL_TEST = 5;

        repeat(TOTAL_TEST) begin
            TEST_COUNT += 1;
            $display("Test iter %0d/%0d", TEST_COUNT, TOTAL_TEST);

            repeat (4) begin
                randomize_inside_grid(.diameter_type(MIN_0_10)); 
                randomize_inside_grid(.diameter_type(MIN_10_30)); 
                randomize_inside_grid(.diameter_type(MED_30_60)); 
                randomize_inside_grid(.diameter_type(MED_60_100)); 
                randomize_inside_grid(.diameter_type(MAX_100_200)); 
                randomize_inside_grid(.diameter_type(MAX_200_255)); 
            end

            randomize_corner1(.diameter_type(MIN_0_10)); 
            randomize_corner1(.diameter_type(MIN_10_30)); 
            randomize_corner1(.diameter_type(MED_30_60)); 
            randomize_corner1(.diameter_type(MED_60_100)); 
            randomize_corner1(.diameter_type(MAX_100_200)); 
            randomize_corner1(.diameter_type(MAX_200_255)); 

            randomize_corner2(.diameter_type(MIN_0_10)); 
            randomize_corner2(.diameter_type(MIN_10_30)); 
            randomize_corner2(.diameter_type(MED_30_60)); 
            randomize_corner2(.diameter_type(MED_60_100)); 
            randomize_corner2(.diameter_type(MAX_100_200)); 
            randomize_corner2(.diameter_type(MAX_200_255)); 

            randomize_corner3(.diameter_type(MIN_0_10)); 
            randomize_corner3(.diameter_type(MIN_10_30)); 
            randomize_corner3(.diameter_type(MED_30_60)); 
            randomize_corner3(.diameter_type(MED_60_100)); 
            randomize_corner3(.diameter_type(MAX_100_200)); 
            randomize_corner3(.diameter_type(MAX_200_255)); 

            randomize_corner4(.diameter_type(MIN_0_10)); 
            randomize_corner4(.diameter_type(MIN_10_30)); 
            randomize_corner4(.diameter_type(MED_30_60)); 
            randomize_corner4(.diameter_type(MED_60_100)); 
            randomize_corner4(.diameter_type(MAX_100_200)); 
            randomize_corner4(.diameter_type(MAX_200_255)); 

            randomize_edge1(.diameter_type(MIN_0_10)); 
            randomize_edge1(.diameter_type(MIN_10_30)); 
            randomize_edge1(.diameter_type(MED_30_60));
            randomize_edge1(.diameter_type(MED_60_100)); 
            randomize_edge1(.diameter_type(MAX_100_200)); 
            randomize_edge1(.diameter_type(MAX_200_255));  

            randomize_edge2(.diameter_type(MIN_0_10)); 
            randomize_edge2(.diameter_type(MIN_10_30)); 
            randomize_edge2(.diameter_type(MED_30_60));
            randomize_edge2(.diameter_type(MED_60_100)); 
            randomize_edge2(.diameter_type(MAX_100_200)); 
            randomize_edge2(.diameter_type(MAX_200_255)); 

            randomize_edge3(.diameter_type(MIN_0_10)); 
            randomize_edge3(.diameter_type(MIN_10_30)); 
            randomize_edge3(.diameter_type(MED_30_60));
            randomize_edge3(.diameter_type(MED_60_100)); 
            randomize_edge3(.diameter_type(MAX_100_200)); 
            randomize_edge3(.diameter_type(MAX_200_255)); 

            randomize_edge4(.diameter_type(MIN_0_10)); 
            randomize_edge4(.diameter_type(MIN_10_30)); 
            randomize_edge4(.diameter_type(MED_30_60));
            randomize_edge4(.diameter_type(MED_60_100)); 
            randomize_edge4(.diameter_type(MAX_100_200)); 
            randomize_edge4(.diameter_type(MAX_200_255)); 

            randomize_outside_grid_1(.diameter_type(MIN_0_10)); 
            randomize_outside_grid_1(.diameter_type(MIN_10_30)); 
            randomize_outside_grid_1(.diameter_type(MED_30_60)); 
            randomize_outside_grid_1(.diameter_type(MED_60_100)); 
            randomize_outside_grid_1(.diameter_type(MAX_100_200)); 
            randomize_outside_grid_1(.diameter_type(MAX_200_255)); 

            repeat(2) begin

                randomize_outside_grid_2_3(.diameter_type(MIN_0_10)); 
                randomize_outside_grid_2_3(.diameter_type(MIN_10_30)); 
                randomize_outside_grid_2_3(.diameter_type(MED_30_60)); 
                randomize_outside_grid_2_3(.diameter_type(MED_60_100)); 
                randomize_outside_grid_2_3(.diameter_type(MAX_100_200)); 
                randomize_outside_grid_2_3(.diameter_type(MAX_200_255)); 

            end

        end

    endtask

    task force_early_clear();
        vif.forced_early_clear = 1'b1;
        // Use to force DUT state to skip CLEAR_SCREEN state once it's been verified
        // `ifndef GLS
        // if (DUT.TRIANGLE_FSM.state != BLACK) begin
        //     @(DUT.TRIANGLE_FSM.state == BLACK) begin
        //         @(posedge vif.clk);
        //         @(posedge vif.clk);
        //         force DUT.TRIANGLE_FSM.state = FSM1;
        //         @(posedge vif.clk);
        //         release DUT.TRIANGLE_FSM.state;
        //     end
        // end
        // `else
        //     $fatal("Attempted to access internal path during GLS");
        // `endif 
    endtask

    task wait_done_and_deassert();
        @(vif.done);
        repeat($urandom_range(0,20)) @(posedge vif.clk);
        vif.start = 1'b0;

        // Wait some random time before next start
        repeat($urandom_range(10,20)) @(posedge vif.clk);
    endtask

    // -------------- RANDOMIZED CASES --------------

    task random_centre(bit early_clear=0);
        vif.centre_x = $urandom_range(0, 255); 
        vif.centre_y = $urandom_range(0, 127);
        vif.diameter = $urandom_range(0,255) & ~1; // force even;
        vif.colour = $urandom_range(0, 7);
        vif.start = 1'b1;

        $display("[%0t ns] starting random_centre with arguments:", $time);
        $display("  centre_x = %d", vif.centre_x);
        $display("  centre_y = %d", vif.centre_y);
        $display("  diameter = %d", vif.diameter);

        wait_done_and_deassert();
    endtask
    
    // -------------- DIRECTED TEST CASES --------------

    task task4_test(bit early_clear=0);

        vif.centre_x = 80;
        vif.centre_y = 60;
        vif.diameter = 80;
        vif.start = 1'b1;
        vif.colour = 3'd2; // TODO: get to correct colour

        $display("[%0t ns] starting task4_test with arguments:", $time);
        $display("  centre_x = %d", vif.centre_x);
        $display("  centre_y = %d", vif.centre_y);
        $display("  diameter = %d", vif.diameter);

        wait_done_and_deassert();
    endtask

    task zero_test(bit early_clear=0);

        vif.centre_x = $urandom_range(0, 159); 
        vif.centre_y = $urandom_range(0, 119);
        vif.diameter = 0;
        vif.start = 1'b1;
        vif.colour = $urandom_range(0, 7);

        $display("[%0t ns] starting zero_test with arguments:", $time);
        $display("  centre_x = %d", vif.centre_x);
        $display("  centre_y = %d", vif.centre_y);
        $display("  diameter = %d", vif.diameter);

        wait_done_and_deassert();
    endtask

    task corner_test_cases(bit early_clear=0);

        $display("[%0t ns] starting corner_test_cases with arguments:", $time);

        vif.centre_x = ($urandom_range(0,1) == 1) ? 0 : 159;
        vif.centre_y = ($urandom_range(0,1) == 1) ? 0 : 119;
        vif.diameter = $urandom_range(0,255) & ~1; // force even;
        vif.colour = $urandom_range(0, 7);
        vif.start = 1'b1;

        $display("  centre_x = %d", vif.centre_x);
        $display("  centre_y = %d", vif.centre_y);
        $display("  diameter = %d", vif.diameter);

        wait_done_and_deassert();
    endtask


    // -------------- RANDOMIZED CASES --------------
    // Too many inputs to simply to consider 100% as 
    // all centre_x, centre_y, diameter inputs reached. 
    // Instead consider combinations of multiple bins
    // - min, normal, max diameter
    // - centre inside screen
    // - centre at edge
    // - centre at corner
    // - centre outside screen 
    // The test cases here provide stimuli to provide 100% by the metrics described above
    
    task rand_min1();
        vif.diameter = $urandom_range(0, 9);
    endtask

    task rand_min2();
        vif.diameter = $urandom_range(10, 29);
    endtask

    task rand_med1();
        vif.diameter = $urandom_range(30, 59);
    endtask

    task rand_med2();
        vif.diameter = $urandom_range(60, 99);
    endtask

    task rand_max1();
        vif.diameter = $urandom_range(100, 199);
    endtask

    task rand_max2();
        vif.diameter = $urandom_range(200, 255);
    endtask

    task randomize_diameter(test_diameter_type diameter_type = 1);
        case (diameter_type)
            MIN_0_10    : rand_min1();
            MIN_10_30   : rand_min2(); 
            MED_30_60   : rand_med1();
            MED_60_100  : rand_med2();
            MAX_100_200 : rand_max1();
            MAX_200_255 : rand_max2();
        endcase
    endtask

    // Corners

    task randomize_corner1(test_diameter_type diameter_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(0,5);     
        vif.centre_y = $urandom_range(0,5);
        vif.colour = $urandom_range(0,7);

        randomize_diameter(diameter_type);
        wait_done_and_deassert(); 
    endtask

    task randomize_corner2(test_diameter_type diameter_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(155,159);     
        vif.centre_y = $urandom_range(0,5);
        vif.colour = $urandom_range(0,7);

        randomize_diameter(diameter_type);
        wait_done_and_deassert(); 
    endtask

    task randomize_corner3(test_diameter_type diameter_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(0,5);     
        vif.centre_y = $urandom_range(115, 119);  
        vif.colour = $urandom_range(0,7);

        randomize_diameter(diameter_type);
        wait_done_and_deassert(); 
    endtask

    task randomize_corner4(test_diameter_type diameter_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(155,159);     
        vif.centre_y = $urandom_range(115, 119);  
        vif.colour = $urandom_range(0,7);

        randomize_diameter(diameter_type);
        wait_done_and_deassert(); 
    endtask

    // Edges

    task randomize_edge1(test_diameter_type diameter_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(0, 5);
        vif.centre_y = $urandom_range(5, 115);
        vif.colour = $urandom_range(0,7);

        randomize_diameter(diameter_type);
        wait_done_and_deassert();
    endtask

    task randomize_edge2(test_diameter_type diameter_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(5, 155);
        vif.centre_y = $urandom_range(0, 5);
        vif.colour = $urandom_range(0,7);

        randomize_diameter(diameter_type);
        wait_done_and_deassert();
    endtask

    task randomize_edge3(test_diameter_type diameter_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(155, 159); 
        vif.centre_y = $urandom_range(5, 115);
        vif.colour = $urandom_range(0,7);

        randomize_diameter(diameter_type);
        wait_done_and_deassert();
    endtask

    task randomize_edge4(test_diameter_type diameter_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(5, 155);   
        vif.centre_y = $urandom_range(115, 119);
        vif.colour = $urandom_range(0,7);

        randomize_diameter(diameter_type);
        wait_done_and_deassert();
    endtask

    task randomize_outside_grid(test_diameter_type diameter_type);
        vif.start = 1'b1;
        
        vif.centre_x = $urandom_range(160, 255); 
        vif.centre_y = $urandom_range(120, 127);
        vif.colour = $urandom_range(0,7);

        randomize_diameter(diameter_type);
        wait_done_and_deassert();
    endtask

    task randomize_outside_grid_1(test_diameter_type diameter_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(0, 159); 
        vif.centre_y = $urandom_range(120, 127);
        vif.colour = $urandom_range(0,7);

        randomize_diameter(diameter_type);
        wait_done_and_deassert();
    endtask

    task randomize_outside_grid_2_3(test_diameter_type diameter_type);
        vif.start = 1'b1;

        vif.centre_x = $urandom_range(160, 255); 
        vif.centre_y = $urandom_range(0, 127);
        vif.colour = $urandom_range(0,7);

        randomize_diameter(diameter_type);
        wait_done_and_deassert();
    endtask

    task randomize_inside_grid(test_diameter_type diameter_type, bit early_clear = 0);
        vif.start = 1'b1;
        
        vif.centre_x = $urandom_range(5, 155); 
        vif.centre_y = $urandom_range(5, 115);
        vif.colour = $urandom_range(0,7);

        randomize_diameter(diameter_type);
        fork
            if (early_clear) force_early_clear();
            wait_done_and_deassert(); 
        join

    endtask

endmodule // circle_test_seq