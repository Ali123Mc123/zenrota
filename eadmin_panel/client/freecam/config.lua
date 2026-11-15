local INPUT_LOOK_LR           = 1
local INPUT_LOOK_UD           = 2
local INPUT_CHARACTER_WHEEL   = 19
local INPUT_SPRINT            = 21
local INPUT_MOVE_LR           = 30
local INPUT_MOVE_UD           = 31
local INPUT_VEH_ACCELERATE    = 71
local INPUT_VEH_BRAKE         = 72
local INPUT_PARACHUTE_BRAKE_L = 152
local INPUT_PARACHUTE_BRAKE_R = 153

FreecamConfig = {
    CAMERA = {
        FOV             = 50.0,
        ENABLE_EASING   = true,
        EASING_DURATION = 250,
    },

    KEYBOARD_CONTROLS = {
        LOOK_X    = INPUT_LOOK_LR,
        LOOK_Y    = INPUT_LOOK_UD,
        MOVE_X    = INPUT_MOVE_LR,
        MOVE_Y    = INPUT_MOVE_UD,
        MOVE_Z    = { INPUT_PARACHUTE_BRAKE_L, INPUT_PARACHUTE_BRAKE_R },
        MOVE_FAST = INPUT_SPRINT,
        MOVE_SLOW = INPUT_CHARACTER_WHEEL,
    },

    KEYBOARD_SETTINGS = {
        LOOK_SENSITIVITY_X    = 5,
        LOOK_SENSITIVITY_Y    = 5,
        BASE_MOVE_MULTIPLIER  = 0.85,
        FAST_MOVE_MULTIPLIER  = 6,
        SLOW_MOVE_MULTIPLIER  = 6,
    },

    GAMEPAD_CONTROLS = {
        LOOK_X    = INPUT_LOOK_LR,
        LOOK_Y    = INPUT_LOOK_UD,
        MOVE_X    = INPUT_MOVE_LR,
        MOVE_Y    = INPUT_MOVE_UD,
        MOVE_Z    = { INPUT_PARACHUTE_BRAKE_L, INPUT_PARACHUTE_BRAKE_R },
        MOVE_FAST = INPUT_VEH_ACCELERATE,
        MOVE_SLOW = INPUT_VEH_BRAKE,
    },

    GAMEPAD_SETTINGS = {
        LOOK_SENSITIVITY_X    = 2,
        LOOK_SENSITIVITY_Y    = 2,
        BASE_MOVE_MULTIPLIER  = 0.85,
        FAST_MOVE_MULTIPLIER  = 6,
        SLOW_MOVE_MULTIPLIER  = 6,
    },
}
