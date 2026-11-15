-- Client: moves the player's radio to a call's channel (Config.Radio.Switch). pma-voice's own; a radio script on top of
-- it (tgiann-radio ...) may want its own call here instead, so its screen shows the channel too.
function Bridge.setRadio(channel)
    local number = tonumber(channel)
    if not number then return false end
    if Bridge.started('pma-voice') then
        exports['pma-voice']:setRadioChannel(number)
        return true
    end
    return false
end
