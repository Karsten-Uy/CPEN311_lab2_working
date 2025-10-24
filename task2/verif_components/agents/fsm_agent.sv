import lab_pkg::*;
`timescale 1ns/1ns

interface fsm_if;

    // DUT signals
    logic clk;
    logic rst_n;
    logic start;
    logic [7:0] x_count;
    logic [6:0] y_count;

    logic done;
    logic [7:0] vga_x;
    logic [6:0] vga_y;
    logic [2:0] vga_colour;
    logic vga_plot;
    logic x_en;
    logic y_en;
    logic x_rst;
    logic y_rst;

    // TB signals
    bit rst;
    bit active_low;

    lab_pkg::e_FSM_state state;

    int targeted_err_count;
    int cycle_count;

endinterface //fsm_if

module fsm_monitor (
    fsm_if vif,
    phases phases
);

    // -------------------------------------------------------
    // --------------------  COMMON TASKS --------------------
    // -------------------------------------------------------
    int ERROR_COUNT;

    task start();
        @(phases.run_phase == 1);
        fork
            monitor_error();
            monitor_coverage();           
        join_none
    endtask

    task monitor_error();
        ERROR_COUNT = 0;   
        fork
            monitor_err_state_output();
        join_none
    endtask

    task monitor_coverage();
        fork
            monitor_fsm_state();
            monitor_fsm_transition();
        join_none
    endtask

    // Consume zero simulation time
    function void report();
        report_fsm_coverage();
        report_error();
    endfunction 

    // -----------------------------------------------------------
    // -----------------------------------------------------------
    // -----------------------------------------------------------

    bit state_coverage      [string];
    bit transition_coverage [string];

    lab_pkg::allowed_states      allowed_states;
    lab_pkg::allowed_transitions allowed_transitions;

    string curr_state, prev_state;
    string state_transition;

    real fsm_state_coverage;
    real fsm_transition_coverage;

    int err_transition_count;

    // --------------------  ERROR MONITORING --------------------
    logic [5:0] vif_val;
    task monitor_err_state_output();

        `define CHECK(pattern) \
            if (!(vif_val ==? pattern)) begin \
                $error("%s state has output error. vif = %0b", vif.state.name, vif_val); \
                ERROR_COUNT += 1; \
            end

        while (phases.run_phase) begin
            @(negedge vif.clk); 
            @(posedge vif.clk) begin

                vif_val = {
                            vif.done,
                            vif.vga_plot,
                            vif.x_en,
                            vif.y_en,
                            vif.x_rst,
                            vif.y_rst
                        };


                // State dependant signal checks
                case (vif.state)
                    IDLE : `CHECK(6'b0_0_?_?_1_1)

                    DRAW : begin
                            if (vif.y_count < 7'd119)
                                `CHECK(6'b0_1_0_1_0_0)
                            else if (vif.y_count == 7'd119)
                                `CHECK(6'b0_1_1_1_0_0)
                            else begin // vif.y_count > 7'd119
                                $error("vif.y_count > 119"); ERROR_COUNT += 1;
                            end
                        end

                    DONE : `CHECK(6'b1_?_?_?_?_?)
                endcase

                // Additional DONE check
                if (vif.state == DONE && (!vif.done)) begin 
                    $error("DONE condition not met"); 
                    ERROR_COUNT += 1; 
                end
            end
        end
    endtask

    // --------------------  COVERAGE MONITORING --------------------

    // FSM states should advance every cycle
    task monitor_fsm_state();
        allowed_states = lab_pkg::get_allowed_states();
        
        while(phases.run_phase) begin
            @(posedge vif.clk) begin
                if (allowed_states.exists(vif.state.name))
                    state_coverage[vif.state.name] = 1'b1;
                else begin
                    $error("Reached the following invalid state: %0b", vif.state);
                    ERROR_COUNT += 1;
                end
            end
        end
    endtask

    task monitor_fsm_transition();
        allowed_transitions = lab_pkg::get_allowed_transitions();

        curr_state = vif.state.name();
        while (phases.run_phase) begin
            @(posedge vif.clk);
            prev_state = curr_state;
            curr_state = vif.state.name();

            state_transition = {prev_state, " -> ", curr_state};

            if (allowed_transitions.exists(state_transition))
                transition_coverage[state_transition] = 1'b1;
            else begin
                $error("Reached the following invalid state transition: %s", state_transition); 
                ERROR_COUNT += 1;
            end
        end
    endtask

    function void report_fsm_coverage();
        lab_pkg::e_FSM_state state;

        int num_fsm_states;
        int expected_fsm_states;
        int num_fsm_transitions;
        int expected_fsm_transition;

        num_fsm_states = state_coverage.size();
        expected_fsm_states = state.num();

        num_fsm_transitions = transition_coverage.size();
        expected_fsm_transition = allowed_transitions.size(); 

        fsm_state_coverage      = 100.0*num_fsm_states/expected_fsm_states;
        fsm_transition_coverage = 100.0*num_fsm_transitions/expected_fsm_transition;

        $display("FSM state coverage      = %0.5f%%. Reached %0d states", fsm_state_coverage, num_fsm_states);
        $display("FSM transition coverage = %0.5f%%. Reached %0d transitions", fsm_transition_coverage, num_fsm_transitions);

        // Print all states hit and reached

        $display("FSM states reached");
        foreach(state_coverage[key]) begin
            $display("\t - %s", key);
        end

        $display("FSM transitions reached");
        foreach(transition_coverage[key]) begin
            $display("\t - %s", key);
        end

    endfunction 

    function void report_error();
        if (fsm_state_coverage < 100.0) begin
            ERROR_COUNT += 1;
            $display("ERROR: Not all FSM states have been hit");

            foreach(allowed_states[i]) begin
                if (!state_coverage.exists(i))
                    $display("\t - %s", i);      
            end
        end

        if (fsm_transition_coverage < 100.0) begin
            ERROR_COUNT += 1;
            $display("ERROR: Not all FSM transitions exercised");

            foreach(allowed_transitions[i]) begin
                if (!transition_coverage.exists(i))
                    $display("\t - %s", i);      
            end
        end

        if (vif.targeted_err_count > 0) begin

            ERROR_COUNT += vif.targeted_err_count;
            $display("ERROR: targeted tests not passing");
        end

    endfunction
endmodule // fsm_monitor