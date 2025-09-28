package lab_pkg;
    `define FSM_SWIDTH 3 // Keep large enough for a one-hot encoded FSM

    typedef enum logic [`FSM_SWIDTH:0] { 
        IDLE,          // FSM entry point
        CLEAR_SCREEN,  // Set screen to black
        DRAW,          // Drawing loop
        DONE           // Assert done signal
    } e_FSM_state;

    // synthesis translate_off
    typedef bit allowed_states      [string];
    typedef bit allowed_transitions [string];

    // Cannot declare associate arrays inside packages as entries can only be added at runtime
    function allowed_states get_allowed_states();
        allowed_states dict;
        dict ["IDLE"     ] = 1;           
        dict ["DRAW"     ] = 1;        
        dict ["DONE"     ] = 1;        

        return dict;
    endfunction

    function allowed_transitions get_allowed_transitions();
        allowed_transitions dict;

        dict [{"IDLE",         " -> ",   "CLEAR_SCREEN"}] = 1;
        dict [{"CLEAR_SCREEN", " -> ",   "DRAW"}]         = 1;
        dict [{"DRAW",         " -> ",   "DONE"}]         = 1;

        return dict;

    endfunction
// synthesis translate_on

endpackage