-- Star Skill Tree locks on the client (BDX-Fighting styles, krypton-farming menu), read from the state bag.
local function state() return LocalPlayer.state['daddy_college:academics'] end

local function gate(keys, silent)
    if SkillGate.config().Enabled == false or Core.IsAdmin() then return true end
    local allowed, key = SkillGate.allowedAny(state(), keys)
    if not allowed and not silent then Core.Notify(SkillGate.message(key), 'error') end
    return allowed
end

exports('SkillGate', gate)

-- Certificate locks on the client (the state bag's certs): bostra_poledance asks before the dance menu opens.
local function certificate(key, silent)
    if SkillGate.config().Enabled == false or Core.IsAdmin() then return true end
    if SkillGate.hasCertificate(state(), key) then return true end
    if not silent then Core.NotifyL('skillgate.need_certificate', 'error', DL.locale.t('academics.certificate_' .. key)) end
    return false
end
exports('CertificateAllowed', certificate)
exports('PoleDanceAllowed', function(silent) return certificate(SkillGate.config().PoleDance, silent) end)

-- BDX-Fighting: style 1 Dojo (Karate), 2 Boxing, 3 MMA in Skills.Fighting.
exports('FightStyleAllowed', function(style, silent)
    return gate((SkillGate.config().Fighting or {})[tonumber(style)], silent)
end)

exports('FarmingShortcut', function(difficulty)
    return SkillGate.grants(state(), (SkillGate.config().Farming or {})[difficulty])
end)

-- qbx_ambulancejob: a student with Skills.WoundCare treats the nearest player's wounds with a bandage by command.
local function woundCare() return SkillGate.grants(state(), SkillGate.config().WoundCare) end
exports('WoundCareAllowed', woundCare)

if SkillGate.config().WoundCare and (SkillGate.config().WoundCareCommand or '') ~= '' then
    Core.Command(SkillGate.config().WoundCareCommand, function()
        if GetResourceState('qbx_ambulancejob') ~= 'started' then return end
        if not woundCare() then return Core.NotifyL('common.no_permission', 'error') end
        TriggerEvent('hospital:client:TreatWounds')
    end)
end

-- BDX-Fighting checks only when a style is learned: a student who loses the skill (withdrawn, levels reset) drops the
-- style when their state bag changes. No loop; the bag change is the only trigger.
local STYLES = { { 'IsFighting1', 'UnlearnFight1' }, { 'IsFighting2', 'UnlearnFight2' }, { 'IsFighting3', 'UnlearnFight3' } }
AddStateBagChangeHandler('daddy_college:academics', ('player:%s'):format(cache.serverId), function(_, _, value)
    if GetResourceState('BDX-Fighting') ~= 'started' or SkillGate.config().Enabled == false or Core.IsAdmin() then return end
    for style, pair in ipairs(STYLES) do
        local ok, fighting = pcall(function() local res = exports['BDX-Fighting'] return res[pair[1]](res) end)
        if ok and fighting and not SkillGate.allowedAny(value, (SkillGate.config().Fighting or {})[style]) then
            TriggerEvent(pair[2])
            Core.Notify(SkillGate.message((SkillGate.config().Fighting or {})[style]), 'error')
        end
    end
end)
