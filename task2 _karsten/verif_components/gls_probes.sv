`ifndef PATH_TO_FSM
    `define PATH_TO_FSM DUT
`endif 

// For use in a one-hot encoded FSM
`define GLS_PROBES \
    assign fsm_if.GLS_state.IDLE    = `PATH_TO_FSM.\state.IDLE~q ; \
    assign fsm_if.GLS_state.DEAL_P1 = `PATH_TO_FSM.\state.DEAL_P1~q ; \
    assign fsm_if.GLS_state.DEAL_P2 = `PATH_TO_FSM.\state.DEAL_P2~q ; \
    assign fsm_if.GLS_state.DEAL_P3 = `PATH_TO_FSM.\state.DEAL_P3~q ; \
    assign fsm_if.GLS_state.DEAL_D1 = `PATH_TO_FSM.\state.DEAL_D1~q ; \
    assign fsm_if.GLS_state.DEAL_D2 = `PATH_TO_FSM.\state.DEAL_D2~q ; \
    assign fsm_if.GLS_state.DEAL_D3 = `PATH_TO_FSM.\state.DEAL_D3~q ; \
    assign fsm_if.GLS_state.DONE    = `PATH_TO_FSM.\state.DONE~q ; \
    assign fsm_if.GLS_state.PWIN    = `PATH_TO_FSM.\state.PWIN~q ; \
    assign fsm_if.GLS_state.DWIN    = `PATH_TO_FSM.\state.DWIN~q ; \
    assign fsm_if.GLS_state.TIE     = `PATH_TO_FSM.\state.TIE~q ;