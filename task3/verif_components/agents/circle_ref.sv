/*
    The following is a reference model that will receive the same inputs as the DUT

    DUT behaviour is expected to line up with thie behavioural model
*/

package circle_ref_pkg;

    // Internal ref state
    typedef enum {
        CLEAR,
        DRAW_CIRCLE,
        REF_DONE
    } circle_ref_state;

endpackage

module circle_ref (circle_if vif, phases phases);

    import lab_pkg::*;
    import circle_ref_pkg::*;

    circle_ref_state ref_state;


    // Monitor start signals

    task run();
        event start_trig;

        fork
            while(phases.run_phase == 1) begin
                @(posedge vif.start == 1'b1) -> start_trig;
            end
        join_none


        while(phases.run_phase == 1) begin

            $display("[%0t ns][ref_model] Running circle reference model", $time);
            ref_main();

            if (vif.start == 1'b1) begin
                $display("[%0t ns][ref_model] Waiting start signal...", $time);
                @(start_trig);
            end

            if (vif.start == 1'b0) begin : wait_start_trig
                $display("[%0t ns][ref_model] Waiting start signal...", $time);
                @(start_trig);
            end
        end
    endtask


    task ref_main();
        int ERROR_COUNT; // Design assertions
        int offset_x;
        int offset_y;
        int centre_x;
        int centre_y;
        int crit;

        @(posedge vif.clk); // Load state
        offset_y = 0;
        offset_x = vif.radius;
        crit     = 1 - vif.radius;
        centre_x = vif.centre_x;
        centre_y = vif.centre_y;

        @(posedge vif.clk); // Fillscreen + 1 delay

        // Clear Screen
        $display("[%0t ns][ref_model] Running clear screen", $time);
        ref_state = CLEAR;
        vif.ref_state = CIRCLE_BLACK;
        vif.vga_plot = 1'b1;
        for (int x = 0; x <= 159; x++) begin
            for (int y = 0; y <= 119; y++) begin
                @(posedge vif.clk) begin
                    vif.vga_x <= x;
                    vif.vga_y <= y;
                    vif.vga_colour <= 0;
                end
            end
        end

        @(posedge vif.clk); // Wait for fill_done to startup circle drawing
        vif.vga_x <= 'b0;
        vif.vga_y <= 'b0;

        $display("[%0t ns][ref_model] Running Circle Drawing", $time);
        ref_state = DRAW_CIRCLE;

        while (offset_y <= offset_x) begin
            setPixel(centre_x + offset_x, centre_y + offset_y, 1); //  -- octant 1
            setPixel(centre_x + offset_y, centre_y + offset_x, 2); //  -- octant 2
            setPixel(centre_x - offset_y, centre_y + offset_x, 3); //  -- octant 3
            setPixel(centre_x - offset_x, centre_y + offset_y, 4); //  -- octant 4
            setPixel(centre_x - offset_x, centre_y - offset_y, 5); //  -- octant 5
            setPixel(centre_x - offset_y, centre_y - offset_x, 6); //  -- octant 6
            setPixel(centre_x + offset_y, centre_y - offset_x, 7); //  -- octant 7
            setPixel(centre_x + offset_x, centre_y - offset_y, 8); //  -- octant 8
            offset_y = offset_y + 1;
            if (crit <= 0) begin
                crit = crit + 2 * offset_y + 1;
            end
            else begin
                offset_x = offset_x - 1;
                crit = crit + 2 * (offset_y - offset_x) + 1;
            end
        end

        @(posedge vif.clk);
        vif.ref_state = CIRCLE_DONE;
        vif.done <= 1'b1;

        ref_state = REF_DONE;
    endtask

    task setPixel(int vga_x, int vga_y, int oct);
        @(posedge vif.clk) begin
            setOct(oct);

            if (vga_x >= 0 && vga_x <= 159) vif.vga_x = vga_x;
            else                            vif.vga_x = 'b0;

            if (vga_y >= 0 && vga_y <= 119) vif.vga_y = vga_y;
            else                            vif.vga_y = 'b0;

            if (vga_x >= 0 && vga_x <= 159 &&
                vga_y >= 0 && vga_y <= 119) begin
                vif.vga_plot = 1'b1;
            end else begin
                vif.vga_plot = 1'b0;
            end

        end
        @(negedge vif.clk);
        // $display("[ref_model] x=%0d,y=%0d", vif.vga_x, vif.vga_y);
    endtask

    task setOct(int oct);
        case(oct)
            1: vif.ref_state = CIRCLE_OCT1;
            2: vif.ref_state = CIRCLE_OCT2;
            3: vif.ref_state = CIRCLE_OCT3;
            4: vif.ref_state = CIRCLE_OCT4;
            5: vif.ref_state = CIRCLE_OCT5;
            6: vif.ref_state = CIRCLE_OCT6;
            7: vif.ref_state = CIRCLE_OCT7;
            8: vif.ref_state = CIRCLE_OCT8;
        endcase
    endtask

endmodule