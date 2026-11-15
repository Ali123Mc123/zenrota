-- Capture the flag on the client: the flags (at a base, on a carrier's back, on the ground), team marks over
-- heads, the field's edge, and the key: E takes the flag when you touch it, else tags the nearest player.
-- In a game you cannot draw a weapon or punch, and a carrier cannot sprint.
local cfg = Config.Ctf
local t = DL.locale.t
local here = { id = nil, flags = {}, team = nil, tagged = false, stunUntil = 0, playing = false }

local function teamOf(scene, id)
    for _, row in ipairs(scene.public and scene.public.scene and scene.public.scene.teams or {}) do
        if row.id == id then return row.team end
    end
end

-- Flags ----------------------------------------------------------------------------------------------------------

local function deleteFlag(team)
    local entity = here.flags[team]
    if entity and DoesEntityExist(entity) then DeleteEntity(entity) end
    here.flags[team] = nil
end

local function showFlag(team, flag)
    deleteFlag(team)
    if not flag then return end
    local model = joaat(cfg.Flags[team])
    if not lib.requestModel(model, 3000) then return end
    if flag.at == 'carried' then
        local player = GetPlayerFromServerId(flag.carrier)
        if player == -1 then return end
        local ped = GetPlayerPed(player)
        pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
        local entity = CreateObject(model, 0.0, 0.0, 0.0, false, false, false)
        local b = cfg.FlagOnBack
        AttachEntityToEntity(entity, ped, GetPedBoneIndex(ped, b.bone), b.offset.x, b.offset.y, b.offset.z, b.rotation.x, b.rotation.y, b.rotation.z,
            true, true, false, true, 1, true)
        here.flags[team] = entity
    else
        pcall(function() exports['FeloxAC']:CreateObject(model) end) --[[FeloxAC:auto]]
        local entity = CreateObject(model, flag.x, flag.y, flag.z, false, false, false)
        PlaceObjectOnGroundProperly(entity)
        FreezeEntityPosition(entity, true)
        SetEntityCollision(entity, false, false)
        if flag.at == 'dropped' then SetEntityRotation(entity, 0.0, 70.0, 0.0, 2, false) end
        here.flags[team] = entity
    end
    SetModelAsNoLongerNeeded(model)
end

local function clearFlags()
    for team in pairs(here.flags) do deleteFlag(team) end
end

-- The bases' targets: open, join or the sign-up sheet of the field the base stands in.
Games.kind('ctf_base', function(record)
    for _, zone in ipairs(Games.world.zones({ kind = 'ctf_field' })) do
        if DL.geo.contains(DL.geo.fromRecord(zone), record.coords.x, record.coords.y, record.coords.z) then
            return { options = Games.venueOptions(zone, 'fa-solid fa-flag'), distance = 3.0 }
        end
    end
    return {}
end)

-- Playing ----------------------------------------------------------------------------------------------------------

local function scene() return here.id and Games.scenes[here.id] end

-- The flag of the other team, when it is on the ground or at its base within reach.
local function flagInReach()
    local s = scene()
    local data = s and s.public.scene
    if not data or not here.team then return nil end
    local flag = data.flags[here.team == 1 and 2 or 1]
    if flag.at == 'carried' then return nil end
    local me = GetEntityCoords(cache.ped)
    return #(vector2(me.x, me.y) - vector2(flag.x, flag.y)) <= cfg.PickupRange
end

local function iCarry()
    local s = scene()
    for _, flag in ipairs(s and s.public.scene.flags or {}) do
        if flag.at == 'carried' and flag.carrier == cache.serverId then return true end
    end
    return false
end

local function pickUp()
    local result = Games.call('ctf:pickup', { phase = 'begin' })
    if not result.ok then return Games.fail(result) end
    if lib.progressCircle({ duration = math.floor(cfg.PickupHold * 1000) + 100, canCancel = true, disable = { move = true, combat = true } }) then
        result = Games.call('ctf:pickup', { phase = 'end' })
        if not result.ok then Games.fail(result) end
    end
end

local function marks(data)
    for _, row in ipairs(data.teams or {}) do
        local player = row.id ~= cache.serverId and GetPlayerFromServerId(row.id) or -1
        if player ~= -1 then
            local p = GetEntityCoords(GetPlayerPed(player))
            local color = row.team == 1 and { 70, 110, 190 } or { 200, 80, 60 }
            if row.team == here.team then
                DrawMarker(28, p.x, p.y, p.z + 1.15, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.08, 0.08, 0.08, color[1], color[2], color[3], 200, false, false, 2, false, nil, nil, false)
            end
        end
    end
    for team, flag in ipairs(data.flags or {}) do
        if flag.at == 'carried' and flag.carrier ~= cache.serverId then
            local player = GetPlayerFromServerId(flag.carrier)
            if player ~= -1 then
                local p = GetEntityCoords(GetPlayerPed(player))
                local c = team == 1 and { 70, 110, 190 } or { 200, 80, 60 }
                DrawMarker(4, p.x, p.y, p.z + 1.35, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.35, 0.35, 0.35, c[1], c[2], c[3], 220, true, true, 2, false, nil, nil, false)
            end
        end
    end
end

local function playLoop()
    if here.playing then return end
    here.playing = true
    local shown
    while here.id and Games.scenes[here.id] and Games.lobby and Games.lobby.id == here.id do
        local data = Games.scenes[here.id].public.scene or {}
        local ped = cache.ped
        -- No weapons, no punches; a carrier walks or runs but does not sprint.
        if GetSelectedPedWeapon(ped) ~= `WEAPON_UNARMED` then SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true) end
        DisableControlAction(0, 37, true)
        for _, c in ipairs({ 24, 25, 140, 141, 142, 143, 257, 263, 264 }) do DisableControlAction(0, c, true) end
        local carrying = iCarry()
        if carrying and cfg.CarrierNoSprint then DisableControlAction(0, 21, true) end
        if GetGameTimer() < here.stunUntil then
            DisableControlAction(0, 30, true)
            DisableControlAction(0, 31, true)
            DisableControlAction(0, 22, true)
        end
        marks(data)
        local text
        if here.tagged then text = t('ctf.tagged')
        elseif data.prepUntil then text = t('ctf.prep', math.max(0, math.ceil((data.prepUntil - Games.serverNow()) / 1000)))
        elseif carrying then text = t('ctf.you_carry')
        elseif flagInReach() then text = t('ctf.pickup')
        else text = t('ctf.tag_key') end
        if shown ~= text then lib.showTextUI(text) shown = text end
        if not here.tagged and not data.prepUntil and IsControlJustPressed(0, 38) and not Nui.isOpen() then
            if flagInReach() and not carrying then pickUp()
            else
                local result = Games.call('ctf:tag')
                if not result.ok then Games.fail(result) end
            end
        end
        Wait(0)
    end
    here.playing = false
    lib.hideTextUI()
end

local function scorebar(s)
    local data = s.public.scene or {}
    if not data.score then return end
    local bases = data.bases or {}
    Games.overlay('games.scorebar', { game = 'ctf', score = data.score, target = data.target, mine = here.team, overtime = data.overtime,
        names = { bases[1] and bases[1].name ~= '' and bases[1].name or t('ctf.team_1'), bases[2] and bases[2].name ~= '' and bases[2].name or t('ctf.team_2') },
        remaining = data.endsAt and math.max(0, math.floor((data.endsAt - Games.serverNow()) / 1000)) or nil })
end

Games.onScene('ctf', function(op, args, _, s)
    s.public = s.public or {}
    local data = s.public.scene or {}
    if op == 'start' or op == 'full' then
        s.public = args
        data = args.scene or {}
        here.id = s.id
        here.team = teamOf(s, cache.serverId)
        here.tagged = false
        for _, id in ipairs(data.tagged or {}) do if id == cache.serverId then here.tagged = true end end
        for team, flag in ipairs(data.flags or {}) do showFlag(team, flag) end
        if here.team then CreateThread(playLoop) end
    elseif op == 'go' then
        data.prepUntil, data.endsAt = nil, args.endsAt
        PlaySoundFrontend(-1, 'Beep_Green', 'DLC_HEIST_HACKING_SNAKE_SOUNDS', true)
        lib.notify({ description = t('ctf.go'), type = 'success' })
    elseif op == 'overtime' then
        data.endsAt, data.overtime = args.endsAt, true
        lib.notify({ description = t('ctf.overtime') })
    elseif op == 'flag' then
        data.flags = data.flags or {}
        local before = data.flags[args.team]
        data.flags[args.team] = args.flag
        showFlag(args.team, args.flag)
        if args.flag.at == 'carried' and args.team == here.team then
            local name = ''
            for _, p in ipairs(s.public.players or {}) do if p.id == args.flag.carrier then name = p.name end end
            lib.notify({ description = t('ctf.taken', name), type = 'error' })
        elseif args.flag.at == 'base' and before and before.at ~= 'base' then
            lib.notify({ description = t('ctf.returned') })
        end
    elseif op == 'tag' then
        data.tagged = data.tagged or {}
        data.tagged[#data.tagged + 1] = args.id
        if args.id == cache.serverId then
            here.tagged = true
            here.stunUntil = GetGameTimer() + (args.stun or 3) * 1000
            if lib.requestAnimDict('anim@mp_player_intcelebrationmale@freakout', 2000) then
                TaskPlayAnim(cache.ped, 'anim@mp_player_intcelebrationmale@freakout', 'freakout', 4.0, 4.0, 1500, 48, 0.0, false, false, false)
            end
        end
    elseif op == 'untag' then
        for i, id in ipairs(data.tagged or {}) do if id == args.id then table.remove(data.tagged, i) break end end
        if args.id == cache.serverId then
            here.tagged = false
            lib.notify({ description = t('ctf.back'), type = 'success' })
        end
    elseif op == 'score' then
        data.score = args.score
        local name = ''
        for _, p in ipairs(s.public.players or {}) do if p.id == args.by then name = p.name end end
        lib.notify({ description = t('ctf.scored', name, t('ctf.team_' .. args.team)), type = args.team == here.team and 'success' or 'error' })
    elseif op == 'joined' or op == 'left' then
        return
    elseif op == 'end' then
        clearFlags()
        here.id, here.team, here.tagged = nil, nil, false
        Games.hideOverlay('games.scorebar')
        return
    end
    s.public.scene = data
    scorebar(s)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then clearFlags() end
end)
