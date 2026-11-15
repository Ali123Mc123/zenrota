-- BDX-Skate ox_lib Keybind & Proximity Bridge
if not lib or not lib.addKeybind then return end

-- Kaykay Sürüş & Trick Kişiselleştirilebilir Keybinds (ESC -> Settings -> Keybinds)
lib.addKeybind({
    name = 'bdx_skate_grind',
    description = 'Kaykay Grind Hareketi (E)',
    defaultKey = 'E',
    onPressed = function()
        -- Grind action trigger
    end
})

lib.addKeybind({
    name = 'bdx_skate_ollie',
    description = 'Kaykay Ollie Zıplama (SPACE)',
    defaultKey = 'SPACE',
    onPressed = function()
        -- Ollie jump trigger
    end
})
