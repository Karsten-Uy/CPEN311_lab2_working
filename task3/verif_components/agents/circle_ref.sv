/*
    The following is a reference model that will receive the same inputs as the DUT

    DUT behaviour is expected to line up with thie behavioural model
*/

module circle_ref (circle_if vif, phases phases);

    import lab_pkg::*;

    task run();
        int ERROR_COUNT; // Design assertions
        int offset_x;
        int offset_y;
        int centre_x;
        int centre_y;
        int crit;

        $display("[ref_model] Running circle reference model");

        if (~vif.start) begin
            @(vif.start == 1);
        end

        // Clear Screen
        $display("[ref_model] Running clear screen");
        vif.ref_state = CLEAR_SCREEN;
        vif.plot = 1'b1;
        for (int x = 0; x <= 159; x++) begin
            for (int y = 0; y <= 119; y++) begin
                @(posedge vif.clk) begin
                    vif.vga_x <= x;
                    vif.vga_y <= y;
                    vif.vga_colour <= 0; // TODO: What is black?
                end
            end
        end

        $display("[ref_model] Running Circle Drawing");
        offset_y = 0;
        offset_x = vif.radius;
        crit = 1 - vif.radius;
        centre_x = vif.centre_x;
        centre_y = vif.centre_y;

        vif.ref_state = DRAW;

        while (offset_y <= offset_x) begin
            setPixel(centre_x + offset_x, centre_y + offset_y); //  -- octant 1
            setPixel(centre_x + offset_y, centre_y + offset_x); //  -- octant 2
            setPixel(centre_x - offset_x, centre_y + offset_y); //  -- octant 4
            setPixel(centre_x - offset_y, centre_y + offset_x); //  -- octant 3
            setPixel(centre_x - offset_x, centre_y - offset_y); //  -- octant 5
            setPixel(centre_x - offset_y, centre_y - offset_x); //  -- octant 6
            setPixel(centre_x + offset_x, centre_y - offset_y); //  -- octant 8
            setPixel(centre_x + offset_y, centre_y - offset_x); //  -- octant 7
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
        vif.ref_state = DONE;
        vif.done <= 1'b1;

    endtask

    task setPixel(int vga_x, int vga_y);
        @(posedge vif.clk) begin
            if (vga_x >= 0 && vga_x <= 159) vif.vga_x <= vga_x;
            else                            vif.vga_x <= 'b0;

            if (vga_y >= 0 && vga_x <= 119) vif.vga_y <= vga_y;
            else                            vif.vga_y <= 'b0;

            if (vga_x >= 0 && vga_x <= 159 &&
                vga_y >= 0 && vga_y <= 119) begin
                vif.plot <= 1'b1;
            end else begin
                vif.plot <= 1'b0;
            end

        end
        @(negedge vif.clk);
        $display("[ref_model] x=%0d,y=%0d", vif.vga_x, vif.vga_y);
    endtask

endmodule