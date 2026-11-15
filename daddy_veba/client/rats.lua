-- Decoration rats: made on this player's screen only (never networked), near the spots inside the school.
-- They wander around their spot, run from people and are removed when the player walks off or the admin turns them off.
local cfg = Config.Rats
local hash = joaat(cfg.Model)
local rats = {} -- spot index -> { peds }
local count = 0
local fled = {} -- rat -> game time its flight ends

local function clearSpot(i)
    for _, ped in ipairs(rats[i] or {}) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
        count = count - 1
    end
    rats[i] = nil
end

local function clearAll()
    for i in pairs(rats) do clearSpot(i) end
    count = 0
end

local function fillSpot(i, spot)
    if not lib.requestModel(hash, 5000) then return end
    rats[i] = {}
    for _ = 1, cfg.PerSpot do
        if count >= cfg.Max then break end
        local x, y = spot.x + math.random(-15, 15) / 10, spot.y + math.random(-15, 15) / 10
        local ped = CreatePed(28, hash, x, y, spot.z, math.random(0, 359) + 0.0, false, false)
        if ped ~= 0 then
            SetEntityInvincible(ped, false)
            TaskWanderInArea(ped, spot.x, spot.y, spot.z, 4.0, 2.0, 3.0)
            rats[i][#rats[i] + 1] = ped
            count = count + 1
        end
    end
    SetModelAsNoLongerNeeded(hash)
end

CreateThread(function()
    while true do
        local on = GlobalState.vebaRats == true
        local ped = PlayerPedId()
        local at = GetEntityCoords(ped)
        if on and #(at - Config.Zone.center) <= Config.Zone.radius then
            for i, spot in ipairs(cfg.Spots) do
                local close = #(at - spot) <= cfg.Near
                if close and not rats[i] and count < cfg.Max then fillSpot(i, spot)
                elseif not close and rats[i] then clearSpot(i) end
            end
            local now = GetGameTimer()
            for i, list in pairs(rats) do -- run from a player close by, then wander again; a dead rat is replaced
                local spot = cfg.Spots[i]
                for k = #list, 1, -1 do
                    local rat = list[k]
                    if not DoesEntityExist(rat) or IsEntityDead(rat) then
                        if DoesEntityExist(rat) then DeleteEntity(rat) end
                        table.remove(list, k)
                        count = count - 1
                    elseif #(GetEntityCoords(rat) - at) < 2.5 then
                        TaskSmartFleePed(rat, ped, 8.0, 4000, false, false)
                        fled[rat] = now + 4500
                    elseif fled[rat] and now > fled[rat] then
                        fled[rat] = nil
                        TaskWanderInArea(rat, spot.x, spot.y, spot.z, 4.0, 2.0, 3.0)
                    end
                end
                if #list == 0 then rats[i] = nil end
            end
            Wait(1000)
        else
            if count > 0 or next(rats) then clearAll() end
            Wait(3000)
        end
    end
end)

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() then clearAll() end
end)
