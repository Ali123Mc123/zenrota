-- No framework: the license is the character id, ACE decides admin.
local function license(source)
    return GetPlayerIdentifierByType(tostring(source), 'license')
end

return {
    server = {
        citizenId = license,
        playerName = function(source) return GetPlayerName(tostring(source)) end,
        job = function() return nil end,
        gang = function() return nil end,
        money = function() return 0 end,
        removeMoney = function() return false end,
        addMoney = function() return false end,
        setJob = function() return false end,
        jobs = function() return {} end,
        dutyCount = function() return 0 end,
        onDuty = function() return true end,
        ownedVehicle = function() return nil end,
        vehiclesOf = function() return {} end,
        searchVehicles = function() return {}, 0 end,

        -- No character database: only players online right now.
        searchCharacters = function(query, limit)
            local out, needle = {}, query:lower()
            for _, id in ipairs(GetPlayers()) do
                local name, cid = GetPlayerName(id), license(id)
                if #out < limit and (name:lower():find(needle, 1, true) or cid == query) then out[#out + 1] = { citizenid = cid, name = name } end
            end
            return out
        end,

        character = function(citizenid)
            for _, id in ipairs(GetPlayers()) do
                if license(id) == citizenid then return { citizenid = citizenid, name = GetPlayerName(id) } end
            end
        end,

        isAdmin = function() return false end,

        onLoaded = function(cb)
            AddEventHandler('playerJoining', function() cb(source) end)
        end,

        onUnloaded = function() end,
        onJobChange = function() end,
        onMoneyChange = function() end,
        registerUsable = function() return false end,
    },

    client = {
        isLoggedIn = function() return NetworkIsPlayerActive(PlayerId()) end,
        citizenId = function() return nil end,

        onLoaded = function(cb)
            AddEventHandler('playerSpawned', function() cb() end)
        end,

        onUnloaded = function() end,
    },
}
