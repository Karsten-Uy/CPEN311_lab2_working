package lab_pkg;

    ///////////////////////////////////////////////////////////
    // triangle assets

    `define FSM_SWIDTH_TRIANGLE 3

    typedef enum logic [`FSM_SWIDTH_TRIANGLE-1:0] { 
        REUL_IDLE,         
        REUL_BLACK,
        REUL_FSM1,         
        REUL_FSM2,         
        REUL_FSM3,         
        REUL_DONE         
    } triangle_FSM_state;

    parameter M_BIT_SHIFT = 8;

    // floor(sqrt(3)/6*2^8)
    parameter logic signed [8:0] SQRT_3_DIV_6 = 9'sd73;
    // floor(sqrt(3)/3*2^8)
    parameter logic signed [8:0] SQRT_3_DIV_3 = 9'sd147;
    
    ///////////////////////////////////////////////////////////
    // circle assets

    parameter VGA_X_DW  = 7; 
    parameter VGA_Y_DW  = 6; 
    parameter RADIUS_DW = 7;

    `define FSM_SWIDTH_CIRCLE 4

    typedef enum logic [`FSM_SWIDTH_CIRCLE-1:0] { 
        CIRCLE_IDLE,         
        CIRCLE_LOAD,
        CIRCLE_OCT2,         
        CIRCLE_OCT3,         
        CIRCLE_OCT5,         
        CIRCLE_OCT6,
        CIRCLE_OCT7,         
        CIRCLE_OCT8,         
        CIRCLE_DONE      
    } circle_FSM_state;


    ///////////////////////////////////////////////////////////
    // fillscreen assets

    `define FSM_SWIDTH_FILLSCREEN 2
  
    typedef enum logic [`FSM_SWIDTH_FILLSCREEN-1:0] { 
        FILL_IDLE,        // FSM entry point
        FILL_DRAW,        // Draw 
        FILL_DONE         // assert the done signal
    } fillscreen_FSM_state;

    // synthesis translate_off
    typedef bit allowed_states      [string];
    typedef bit allowed_transitions [string];

    // Cannot declare associate arrays inside packages as entries can only be added at runtime
    function allowed_states get_allowed_states_fillscreen();
        allowed_states dict;
        dict ["FILL_IDLE"     ] = 1;           
        dict ["FILL_DRAW"     ] = 1;        
        dict ["FILL_DONE"     ] = 1;     

        return dict;

    endfunction

    function allowed_transitions get_allowed_transitions_fillscreen();

        allowed_transitions dict;

        dict [{"FILL_IDLE",        " -> ",   "FILL_DRAW"}]  = 1;
        dict [{"FILL_DRAW",        " -> ",   "FILL_DONE"}]  = 1;
        dict [{"FILL_DONE",        " -> ",   "FILL_IDLE"}]  = 1;
        dict [{"FILL_IDLE",        " -> ",   "FILL_IDLE"}]  = 1;
        dict [{"FILL_DONE",        " -> ",   "FILL_DONE"}]  = 1;
        dict [{"FILL_DRAW",        " -> ",   "FILL_DRAW"}]  = 1;

        return dict;

    endfunction
    // synthesis translate_on


endpackage