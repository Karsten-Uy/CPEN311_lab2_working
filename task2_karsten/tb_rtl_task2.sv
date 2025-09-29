
`timescale 1ns/1ns

module tb_rtl_task2();

    import lab_pkg::*;

    // --------------------  VERIFICATION COMPONENTS --------------------
    // Used to synchronize test with monitors + checkers 
    phases     phases();

    // Interfaces
    top_if           dut_if();             
    fillscreen_if    dut_fillscreen_if();             
    fsm_if           dut_fsm_if();             

    // Main DUT stimulus
    top_test_seq       test_seq (.vif(dut_if), .phases(phases));

    // Test checking and coverage
    fillscreen_monitor monitor(.vif(dut_fillscreen_if), .phases(phases));
       /* 
        * because we can assign the outputs of fillscreen to outputs of task2, we do NOT need a seperate monitor 
        * and can just connect it to the fillscreen monitor  
        */
    fsm_monitor        fsm_monitor(.vif(dut_fsm_if), .phases(phases));

    // --------------------  DUT INSTANTIATION --------------------
    task2 DUT (        
        .CLOCK_50   (dut_if.CLOCK_50),
        .KEY        (dut_if.KEY),
        .SW         (dut_if.SW),
        .LEDR       (dut_if.LEDR),
        .HEX0       (dut_if.HEX0),
        .HEX1       (dut_if.HEX1),
        .HEX2       (dut_if.HEX2),
        .HEX3       (dut_if.HEX3),
        .HEX4       (dut_if.HEX4),
        .HEX5       (dut_if.HEX5),
        .VGA_R      (dut_if.VGA_R),
        .VGA_G      (dut_if.VGA_G),
        .VGA_B      (dut_if.VGA_B),
        .VGA_HS     (dut_if.VGA_HS),
        .VGA_VS     (dut_if.VGA_VS),
        .VGA_CLK    (dut_if.VGA_CLK),
        .VGA_X      (dut_if.VGA_X),
        .VGA_Y      (dut_if.VGA_Y),
        .VGA_COLOUR (dut_if.VGA_COLOUR),
        .VGA_PLOT   (dut_if.VGA_PLOT)
    );
    
    assign dut_fillscreen_if.clk        = DUT.CLOCK_50;
    assign dut_fillscreen_if.rst_n      = DUT.KEY[3];
    assign dut_fillscreen_if.start      = DUT.KEY[0];
    assign dut_fillscreen_if.done       = DUT.LEDR[0];
    assign dut_fillscreen_if.vga_x      = DUT.VGA_X;
    assign dut_fillscreen_if.vga_y      = DUT.VGA_Y;
    assign dut_fillscreen_if.vga_colour = DUT.VGA_COLOUR;
    assign dut_fillscreen_if.vga_plot   = DUT.VGA_PLOT;

    // NOTE: cannot do for GLS
    assign dut_fsm_if.state      = DUT.FS.FSM.state;
    assign dut_fsm_if.clk        = DUT.FS.FSM.clk;
    assign dut_fsm_if.rst_n      = DUT.FS.FSM.rst_n;
    assign dut_fsm_if.start      = DUT.FS.FSM.start;
    assign dut_fsm_if.x_count    = DUT.FS.FSM.x_count;
    assign dut_fsm_if.y_count    = DUT.FS.FSM.y_count;
    assign dut_fsm_if.done       = DUT.FS.FSM.done;
    assign dut_fsm_if.vga_x      = DUT.FS.FSM.vga_x;
    assign dut_fsm_if.vga_y      = DUT.FS.FSM.vga_y;
    assign dut_fsm_if.vga_colour = DUT.FS.FSM.vga_colour;
    assign dut_fsm_if.vga_plot   = DUT.FS.FSM.vga_plot;
    assign dut_fsm_if.x_en       = DUT.FS.FSM.x_en;
    assign dut_fsm_if.y_en       = DUT.FS.FSM.y_en;
    assign dut_fsm_if.x_rst      = DUT.FS.FSM.x_rst;
    assign dut_fsm_if.y_rst      = DUT.FS.FSM.y_rst;

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

endmodule: tb_rtl_task2

