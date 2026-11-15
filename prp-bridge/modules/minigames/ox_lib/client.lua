local minigames = {}

-- DaddyRP: prp-minigames yerine ox_lib skillCheck

local playing = false

---@param gameName string
---@param gameOptions table?
---@param otherOptions OtherOptions?
---@return boolean
function minigames.play(gameName, gameOptions, otherOptions)
    if playing then return false end

    gameOptions = gameOptions or {}

    local difficulty = gameOptions.difficulty or { "easy", "easy", "medium" }
    local keys = gameOptions.keys or { "w", "a", "s", "d" }

    playing = true
    local success = lib.skillCheck(difficulty, keys)
    playing = false

    return success == true
end

function minigames.stop()
    if lib.skillCheckActive() then
        lib.cancelSkillCheck()
    end
    playing = false
end

---@return boolean
function minigames.isPlaying()
    return playing or lib.skillCheckActive()
end

return minigames
