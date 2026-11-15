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

--- This is the function that is triggered when the player wants to interact with the television. You can enter your additional controls here.
--- @return boolean
function CanPlayerInteractWithTelevision()
    if Config.Framework.Framework:find("qb") then
        local PlayerData = wFramework.GetPlayerData()
        if (PlayerData ~= nil) and (PlayerData.metadata?.ishandcuffed or PlayerData.metadata?.inlaststand) then
            Config.Debug('[^1ERROR - TARGET^0] Player is handcuffed or in last stand, cannot interact with television')
            return false
        end
    end

    return true
end

function progressBar(duration, label, anim)
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

-----------------------------------------------------------------------------------------
-- THREAD'S --
-----------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------
-- EXPORT'S --
-----------------------------------------------------------------------------------------