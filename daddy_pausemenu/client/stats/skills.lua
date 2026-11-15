-- Skills from the server go into GTA (MP0_<SKILL>: FiveM's engine reads them for any ped), and GTA's feed card
-- marks every 20 points, as Rockstar's stats_controller did.
local cfg = (Config.Stats or {}).Skills or {}
local HASH = PM.Stats.hash -- MP0_<SKILL> hashes (stats/main.lua)
-- Skills whose GTA stat this menu does not drive: the menu still shows the earned value, the engine gets the fixed
-- value here once and Enforce leaves it alone (so the gym's timed perk can own it). STAMINA: earned from running
-- distance it hit 70-100 for most players, and MP0_STAMINA 100 means sprint stamina almost never drains.
local ENGINE_FIXED = cfg.EngineFixed or {}
local ROW = { STAMINA = 'stamina', SHOOTING_ABILITY = 'shooting', STRENGTH = 'strength', STEALTH_ABILITY = 'stealth', FLYING_ABILITY = 'flying', WHEELIE_ABILITY = 'driving', LUNG_CAPACITY = 'lung' }
local ICON = { STAMINA = 2, SHOOTING_ABILITY = 17, STRENGTH = 25, STEALTH_ABILITY = 28, FLYING_ABILITY = 27, WHEELIE_ABILITY = 14, LUNG_CAPACITY = 24 }

-- Rockstar's intended effects (dead code in GTA): melee damage from Strength, noise from Stealth. Off by default:
-- Strength 0 means 0.8x melee damage, and other scripts may own these modifiers.
local function modifiers(name, v)
    if not cfg.ApplyModifiers then return end
    local pid = PlayerId()
    if name == 'STRENGTH' then pcall(function() exports['FeloxAC']:setPlayerDamageModifier('meleeDamage', 0.8 + 0.4 * v / 100) end) --[[FeloxAC:auto]] SetPlayerMeleeWeaponDamageModifier(pid, 0.8 + 0.4 * v / 100) end
    if name == 'STEALTH_ABILITY' then
        local m = math.max(0.05, 1.0 - v / 100)
        SetPlayerNoiseMultiplier(pid, m)
        SetPlayerSneakingNoiseMultiplier(pid, m)
        SetPlayerStealthPerceptionModifier(pid, m)
    end
end

-- The skill card: title and text from our locale, the player's headshot as the picture.
local activeShots = {}
local function feed(name, old, new)
    local title = 'DPM_SKILL_' .. name
    AddTextEntry(title, DL.locale.t(('stats.rows.%s.name'):format(ROW[name])))
    local shot = RegisterPedheadshot(PlayerPedId())
    if shot and shot ~= 0 then activeShots[shot] = true end
    local deadline = GetGameTimer() + 2000
    while not IsPedheadshotReady(shot) and GetGameTimer() < deadline do Wait(0) end
    local txd = IsPedheadshotValid(shot) and IsPedheadshotReady(shot) and GetPedheadshotTxdString(shot) or 'CHAR_DEFAULT'
    local step = (new - old) + old % 20
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(DL.locale.t('stats.feed', new))
    EndTextCommandThefeedPostStats(title, ICON[name], step, new - step, false, txd, txd)
    SetTimeout(10000, function()
        if activeShots[shot] then
            activeShots[shot] = nil
            UnregisterPedheadshot(shot)
        end
    end)
end

RegisterNetEvent('daddy_pausemenu:stats:skills', function(values, notify)
    if not PM.Stats.cid or type(values) ~= 'table' then return end
    PM.Stats.ready = true
    for _, name in ipairs(PMStats.SKILLS) do
        local v = tonumber(values[name])
        if v then
            v = math.max(0, math.min(100, math.floor(v)))
            local old = PM.Stats.skills[name]
            PM.Stats.skills[name] = v
            if cfg.Enabled ~= false then
                local fixed = tonumber(ENGINE_FIXED[name])
                if fixed then
                    if old == nil then StatSetInt(HASH[name], math.floor(fixed), true) end
                else
                    StatSetInt(HASH[name], v, true)
                end
            end
            modifiers(name, v)
            if notify and old and cfg.Feed ~= false and PMStats.crossed(old, v) then
                CreateThread(function() feed(name, old, v) end)
            end
        end
    end
end)

-- Other scripts writing MP0 skills (gyms, admin menus) are put back: the server's values are the only ones.
function PM.Stats.Enforce()
    if cfg.Enabled == false then return end
    for name, v in pairs(PM.Stats.skills) do
        if ENGINE_FIXED[name] == nil then
            local ok, cur = StatGetInt(HASH[name], -1)
            if ok and cur ~= v then StatSetInt(HASH[name], v, true) end
        end
    end
end

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for shot in pairs(activeShots) do
        UnregisterPedheadshot(shot)
    end
    activeShots = {}
    if not cfg.ApplyModifiers then return end
    local pid = PlayerId()
    pcall(function() exports['FeloxAC']:setPlayerDamageModifier('meleeDamage', 1.0) end) --[[FeloxAC:auto]]
    SetPlayerMeleeWeaponDamageModifier(pid, 1.0)
    SetPlayerNoiseMultiplier(pid, 1.0)
    SetPlayerSneakingNoiseMultiplier(pid, 1.0)
    SetPlayerStealthPerceptionModifier(pid, 1.0)
end)
