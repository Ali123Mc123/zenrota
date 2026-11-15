local COOLDOWN_MS = 5000
local lastUse = 0

RegisterCommand('sesyenile', function()
    local now = GetGameTimer()
    if now - lastUse < COOLDOWN_MS then
        return
    end
    lastUse = now

    exports['pma-voice']:setVoiceState('proximity')

    if GetResourceState('ox_lib') == 'started' then
        exports.ox_lib:notify({
            title = 'Ses',
            description = 'Ses kanalin yenilendi.',
            type = 'success',
        })
    else
        TriggerEvent('chat:addMessage', { args = { 'Ses', 'Ses kanalin yenilendi.' } })
    end
end, false)

TriggerEvent('chat:addSuggestion', '/sesyenile', 'Ses kanalini elle yeniler (duyamiyor/duyulamiyor sorununda dene).')
