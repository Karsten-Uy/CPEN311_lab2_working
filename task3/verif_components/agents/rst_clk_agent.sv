`timescale 1ns/1ns

interface rst_clk_if;
    logic rst;
    bit   clk;
endinterface //rst_clk_if

module rst_clk_driver (
    rst_clk_if vif
);
    bit clk_enable;
    int pre_rst_wait;
    int length_rst;
    realtime period_ns;

    task start(bit active_low = 1, longint freq_hz = 50_000_000);
        clk_enable = 1;
        clk_start(freq_hz);
        rst_start(active_low);
    endtask

    task clk_disable();
        clk_enable = 0;
    endtask

    task rst_start(bit active_low); 
        pre_rst_wait  = $urandom_range(5, 25);
        length_rst    = $urandom_range(5, 25);

        if(active_low) vif.rst <= 1'b1;
        else           vif.rst <= 1'b0;

        repeat(pre_rst_wait) begin
            @(posedge vif.clk);
        end

        repeat(length_rst) begin
            @(posedge vif.clk);
            if(active_low) vif.rst <= 1'b0;
            else           vif.rst <= 1'b1;
        end

        if(active_low) vif.rst <= 1'b1;
        else           vif.rst <= 1'b0;
    endtask

    task clk_start(longint freq_hz);
        period_ns = 1e9/real'(freq_hz);

        vif.clk = 0;
        fork
            while(clk_enable) begin
                #(period_ns*1ns) vif.clk = ~vif.clk;
            end          
        join_none
    endtask

    // Note that clk_enable MUST be 0, this task
    // triggers a single rising edge 
    task clk_one_edge();
        vif.clk = 0; #(period_ns*1ns);
        vif.clk = 1; #(period_ns*1ns);
    endtask


endmodule // rst_clk_driver