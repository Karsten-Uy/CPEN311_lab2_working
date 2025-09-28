/*
    The following is a reference model that will receive the same inputs as the DUT

    DUT behaviour is expected to line up with thie behavioural model
*/

module fillscreen_ref (fillscreen_if vif, phases phases);

    event rst_done; // trigger by testbench
    int x_loc;
    int y_loc;

    task run();
        $display("[ref_model] Running fillscreen reference model");

        // $display("[ref_model] Waiting on reset done");
        // @(rst_done);

        // Implementation of the fill screen algorithm
        for (int x = 0; x <= 159; x++) begin
            for (int y = 0; y <= 119; y++) begin
                @(posedge vif.clk) begin
                    vif.vga_x <= x;
                    vif.vga_y <= y;
                    vif.vga_colour <= (x % 8);
                end
            end
        end

        @(posedge vif.clk) 
        vif.vga_x <= 'b0;
        vif.vga_y <= 'b0;
        vif.vga_colour <= 0;

    endtask
endmodule