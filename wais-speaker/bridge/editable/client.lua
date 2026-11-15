-----------------------------------------------------------------------------------------
-- EVENT'S --
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- CALLBACK'S --
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- FUNCTION'S --
-----------------------------------------------------------------------------------------

--- When a user wants to place a speaker or play a song, the system checks whether they are on the blacklist.
--- @return boolean
function IsPlayerInBlacklistedCoords()
    if #BlacklistZones <= 0 then return false end
    return InBlacklistZone
end

--- This is the function that is triggered when the player wants to interact with the boombox. You can enter your additional controls here.
--- @return boolean
function CanPlayerInteractWithSpeaker()
    if Config.Framework.Framework:find("qb") then
        local PlayerData = wFramework.GetPlayerData()
        if (PlayerData ~= nil) and (PlayerData.metadata?.ishandcuffed or PlayerData.metadata?.inlaststand) then
            Config.Debug('[^1ERROR - TARGET^0] Player is handcuffed or in last stand, cannot interact with boombox')
            return false
        end
    end

    return true
end

function progressBar(duration, label, anim)
    -- DaddyRP: car_play ömürlük, takılınca kimse sökemez. Kurulumdan önce oyuncuya bunu söyleyip onay al.
    if Lang and label == Lang('installing_vehicle_speaker') then
        local answer = lib.alertDialog({
            header = Lang('carplay_permanent_header'),
            content = Lang('carplay_permanent_content'),
            centered = true,
            cancel = true,
            labels = { confirm = Lang('carplay_permanent_confirm'), cancel = Lang('carplay_permanent_cancel') },
        })
        if answer ~= 'confirm' then return false end
    end

    return lib.progressBar({
        duration = duration,
        label = label,
        useWhileDead = false,
        canCancel = true,
        anim = anim or nil,
        disable = {
            car = true,
            move = true,
            combat = true,
        }
    })
end

-----------------------------------------------------------------------------------------
-- COMMAND'S --
-----------------------------------------------------------------------------------------

if Config.StreamerMode ~= nil and Config.StreamerMode.use then
    while not Lang do Wait(0) end

    if Config.StreamerMode.command ~= nil and Config.StreamerMode.command ~= "" then
        RegisterCommand(Config.StreamerMode.command, function()
            StreamerMode = not StreamerMode
            LocalPlayer.state:set('speaker:streamer', StreamerMode, true)
            MuteSounds(StreamerMode)

            lib.notify({
                type = StreamerMode and 'success' or 'inform',
                title = Lang('streamer_mode'),
                description = Lang(StreamerMode and 'streamer_mode_enabled' or 'streamer_mode_disabled'),
            })
        end, false)

        TriggerEvent('chat:addSuggestion', ('/%s'):format(Config.StreamerMode.command), Lang('streamer_mode_suggestion'), {})
    end
end

-----------------------------------------------------------------------------------------
-- THREAD'S --
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- EXPORT'S --
-----------------------------------------------------------------------------------------