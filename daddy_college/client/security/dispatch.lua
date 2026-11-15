-- Dispatch on the client: what happens to this player on campus is reported, a downed player can call
-- security, and security sees each alert as a card, a blip and, on [E], a marker.
if not Core.ModuleEnabled('security') then return end

local cfg = Config.Security.Dispatch
local t = DL.locale.t
local exempt, hits, lastHit, latest, historyOpen = {}, 0, 0, nil, false
for _, hash in ipairs(cfg.ExemptWeapons) do exempt[hash] = true end
exempt[`WEAPON_PAINTBALL`] = true

local BLADES = {
    [`WEAPON_KNIFE`] = true, [`WEAPON_DAGGER`] = true, [`WEAPON_MACHETE`] = true, [`WEAPON_SWITCHBLADE`] = true,
    [`WEAPON_BATTLEAXE`] = true, [`WEAPON_HATCHET`] = true, [`WEAPON_STONE_HATCHET`] = true, [`WEAPON_BOTTLE`] = true,
}
local BLIPS = { gunshot = { 161, 1 }, melee_weapon = { 154, 49 }, fight = { 126, 5 }, trespassing = { 480, 3 }, downed = { 153, 8 }, contraband = { 586, 17 } }

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:security:' .. name, false, data))
end

-- Reporting ------------------------------------------------------------------------------------------

local function report(kind, coords, suspectPed)
    local player = suspectPed and NetworkGetPlayerIndexFromPed(suspectPed) or -1
    TriggerServerEvent('daddy_college:security:report', {
        type = kind, coords = { x = coords.x, y = coords.y, z = coords.z },
        suspect = player ~= -1 and GetPlayerServerId(player) or nil, masked = suspectPed ~= nil and GetPedDrawableVariation(suspectPed, 1) > 0,
    })
end

-- Shots this player fires, and the hits they give or take; four blows within five seconds make a fight.
AddEventHandler('gameEventTriggered', function(name, args)
    if not cfg.Enabled or not Core.HasCampus() then return end
    local me = cache.ped
    if name == 'CEventGunShot' then
        if args[1] == me and not Core.IsSecurity() and not exempt[GetSelectedPedWeapon(me)] and Core.OnCampus() then report('gunshot', GetEntityCoords(me), me) end
        return
    end
    if name ~= 'CEventNetworkEntityDamage' then return end
    local victim, attacker, weapon = args[1], args[2], args[7]
    if (victim ~= me and attacker ~= me) or exempt[weapon] then return end
    if not DoesEntityExist(victim) or not IsEntityAPed(victim) or not DoesEntityExist(attacker) or not IsEntityAPed(attacker) then return end
    if GetPedType(victim) == 28 or GetPedType(attacker) == 28 then return end
    local coords = GetEntityCoords(victim)
    if not Core.OnCampus(coords) then return end
    if GetWeaponDamageType(weapon) == 3 or GetWeapontypeGroup(weapon) == 416676503 then return report('gunshot', coords, attacker) end
    if BLADES[weapon] then return report('melee_weapon', coords, attacker) end
    local now = GetGameTimer()
    hits = now - lastHit <= 5000 and hits + 1 or 1
    lastHit = now
    if hits >= 4 then
        hits = 0
        report('fight', coords, attacker)
    end
end)

-- Down on campus: [G] calls security.
CreateThread(function()
    local shown = false
    while true do
        local state = LocalPlayer.state
        local down = IsEntityDead(cache.ped) or state.isDead or state.laststand
        if cfg.Enabled and down and Core.HasCampus() and Core.OnCampus() then
            if not shown then
                shown = true
                Core.Prompt('downed', { title = t('security.downed_title'), tone = 'alert',
                    keys = { { keys = { Core.KeyName(cfg.DownedKey) }, label = t('security.downed_call') } } })
            end
            if IsControlJustPressed(0, cfg.DownedKey) or IsDisabledControlJustPressed(0, cfg.DownedKey) then
                local result = call('callDowned')
                if not result.ok then Core.HandleResult(result, 'security') end
                Wait(2000)
            end
            Wait(0)
        else
            if shown then
                shown = false
                Core.Prompt('downed')
            end
            Wait(1000)
        end
    end
end)

-- Alerts ---------------------------------------------------------------------------------------------

local function blip(alert)
    local c, look = alert.coords, BLIPS[alert.type] or BLIPS.gunshot
    local area = AddBlipForRadius(c.x, c.y, c.z, 40.0)
    SetBlipColour(area, look[2])
    SetBlipAlpha(area, 120)
    local icon = AddBlipForCoord(c.x, c.y, c.z)
    SetBlipSprite(icon, look[1])
    SetBlipColour(icon, look[2])
    SetBlipFlashes(icon, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(('%s %s'):format(alert.code, alert.title))
    EndTextCommandSetBlipName(icon)
    SetTimeout(cfg.BlipSeconds * 1000, function()
        RemoveBlip(area)
        RemoveBlip(icon)
    end)
end

-- The same alert marked again clears its marker.
local function mark(alert)
    Core.Waypoint.mark(('%s: %s'):format(alert.code, alert.title), alert.coords, alert.id, true, 'incident')
    Core.Nui.Send('dispatch:marked', { id = Core.Waypoint.marked() })
end

RegisterNetEvent('daddy_college:security:dispatch', function(alert)
    latest = alert
    blip(alert)
    Core.Nui.Send('dispatch:show', {
        id = alert.id, code = alert.code, type = alert.type, title = alert.title, landmark = alert.landmark,
        suspectName = alert.suspectName, priority = alert.priority, coords = alert.coords, duration = cfg.HudMs,
    })
    PlaySoundFrontend(-1, 'Event_Start_Text', 'GTAO_FM_Events_Soundset', true)
    -- [E] marks it while the card is on screen.
    local deadline = GetGameTimer() + cfg.HudMs
    CreateThread(function()
        while latest == alert and GetGameTimer() < deadline do
            if IsControlJustPressed(0, 38) and not Core.Nui.IsOpen() then
                latest = nil
                Core.Nui.Send('dispatch:hide', {})
                return mark(alert)
            end
            Wait(0)
        end
    end)
end)

Core.Nui.SafeCallback('security:setGps', function(data)
    if type(data.coords) ~= 'table' then return { ok = false, error = 'validation' } end
    mark({ id = data.id, code = data.code or '', title = data.title or '', coords = data.coords })
    return { ok = true }
end)

Core.Nui.SafeCallback('security:clearGps', function()
    Core.Waypoint.clear()
    Core.Nui.Send('dispatch:marked', { id = false })
    return { ok = true }
end)

-- The list of recent alerts takes the cursor while it is open.
local function showHistory(open)
    historyOpen = open
    SetNuiFocus(open, open)
end

Core.Nui.SafeCallback('security:closeDispatchHistory', function()
    showHistory(false)
    return { ok = true }
end)

RegisterCommand(Config.Security.Commands.history, function()
    if not Core.IsSecurity() or historyOpen or Core.Nui.IsOpen() then return end
    showHistory(true)
    Core.Nui.Send('dispatch:toggleHistory', {})
end, false)
RegisterKeyMapping(Config.Security.Commands.history, t('security.dispatch_history_key'), 'keyboard', cfg.HistoryKey)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource and historyOpen then SetNuiFocus(false, false) end
end)
