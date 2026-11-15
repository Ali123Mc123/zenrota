-- The side key: hold it to start or pause a focus session, phone in the pocket or in hand.
local RESOURCE = GetCurrentResourceName()
local HOLD_MS = 500
local held = 0

RegisterCommand('+studentphone_focus', function()
    held = GetGameTimer()
    local mine = held
    SetTimeout(HOLD_MS, function()
        if held == mine then TriggerServerEvent(RESOURCE .. ':focusKey') end
    end)
end, false)

RegisterCommand('-studentphone_focus', function() held = 0 end, false)

RegisterKeyMapping('+studentphone_focus', DL.locale.t('command.focus'), 'keyboard', Config.Focus.Key)

-- A short buzz when focus starts or stops.
RegisterNetEvent(RESOURCE .. ':focusState', function(running)
    PlaySoundFrontend(-1, running and 'Menu_Accept' or 'Menu_Back', 'Phone_SoundSet_Default', true)
end)
