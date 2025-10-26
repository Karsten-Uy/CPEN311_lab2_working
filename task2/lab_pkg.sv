package lab_pkg;

    parameter EXP_DRAW_PIXELS = 160*120; 
    parameter EXP_DRAW_COLORS = 8; 
    
    // Aim for binary coded since stated doesn't matter
    `define FSM_SWIDTH 2
  
    typedef enum logic [`FSM_SWIDTH:0] { 
        IDLE,        // FSM entry point
        DRAW,        // Draw 
        DONE         // assert the done signal
    } e_FSM_state;

    // synthesis translate_off
    typedef bit allowed_states      [string];
    typedef bit allowed_transitions [string];

        // Cannot declare associate arrays inside packages as entries can only be added at runtime
        function allowed_states get_allowed_states();
            allowed_states dict;
            dict ["IDLE"        ] = 1;           
            dict ["DRAW"     ] = 1;        
            dict ["DONE"     ] = 1;     

            return dict;

        endfunction

        function allowed_transitions get_allowed_transitions();

            allowed_transitions dict;

            dict [{"IDLE",        " -> ",   "DRAW"}]  = 1;
            dict [{"DRAW",        " -> ",   "DONE"}]  = 1;
            dict [{"DONE",        " -> ",   "IDLE"}]  = 1;
            dict [{"IDLE",        " -> ",   "IDLE"}]  = 1;
            dict [{"DONE",        " -> ",   "DONE"}]  = 1;
            dict [{"DRAW",        " -> ",   "DRAW"}]  = 1;

            return dict;

        endfunction
    // synthesis translate_on


endpackage