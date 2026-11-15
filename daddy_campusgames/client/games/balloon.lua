-- Balloon date on the client: everyone walks to their spot, a balloon in every hand on the half moon, the strip at the
-- top, RED FLAG over a popped player, an arrow over the one the dater points at, and the date scene at the end.
-- Keys: the others hold E to pop; the dater E for the next round, then left / right and E to pick.
local cfg = Config.Balloon
local t = DL.locale.t
local Spot = GameRules.balloon
local here = { id = nil, s = nil, venue = nil, players = {}, balloons = {}, flags = {}, me = false }
local busy = false

-- The listed models the game has; players get them in turn by their id.
local function modelFor(list, id)
    local have = {}
    for _, name in ipairs(list or {}) do
        if IsModelInCdimage(joaat(name)) then have[#have + 1] = joaat(name) end
    end
    return have[1] and have[math.abs(id) % #have + 1]
end

local function nameOf(id) return id and here.players[id] and here.players[id].name or '' end
local function playing() return here.id ~= nil and Games.lobby ~= nil and Games.lobby.id == here.id end
local function mine(id) return id == cache.serverId and cache.ped or Games.myBot(id) end
local function near(range)
    local v = here.venue
    return v ~= nil and #(GetEntityCoords(cache.ped) - vector3(v.x, v.y, v.z)) <= range
end

local function holding(id)
    local s = here.s
    return s ~= nil and id ~= s.dater and s.spots and s.spots[id] ~= nil and not s.popped[id] and here.players[id] ~= nil
end

local function anim(ped, a, loop)
    local clip = type(a.clip) == 'table' and a.clip[math.random(#a.clip)] or a.clip
    if not ped or not pcall(lib.requestAnimDict, a.dict, 1500) then return end
    TaskPlayAnim(ped, a.dict, clip, 4.0, 4.0, loop and -1 or (a.ms or -1), loop and 49 or (a.full and 0 or 48), 0.0, false, false, false)
end

local function sfx(name, at)
    local d = at and #(GetEntityCoords(cache.ped) - at) or 0.0
    if d > cfg.WatchRange then return end
    SendNUIMessage({ action = 'sfx', name = name, volume = math.max(0.25, 1.0 - d / cfg.WatchRange) })
end

-- One effect, or a list of layers played together (a pop: the torn skin and a light puff).
local function burst(fx, at)
    if fx[1] then
        for _, layer in ipairs(fx) do burst(layer, at) end
        return
    end
    if not pcall(lib.requestNamedPtfxAsset, fx.asset, 2000) then return end
    UseParticleFxAsset(fx.asset)
    if fx.color then SetParticleFxNonLoopedColour(fx.color[1], fx.color[2], fx.color[3]) end
    StartParticleFxNonLoopedAtCoord(fx.name, at.x, at.y, at.z, 0.0, 0.0, 0.0, fx.scale or 1.0, false, false, false)
end

-- Balloons ------------------------------------------------------------------------------------------------------

local function unballoon(id)
    local entity = here.balloons[id]
    here.balloons[id] = nil
    if entity and DoesEntityExist(entity) then DeleteEntity(entity) end
end

-- A balloon in the player's hand; again when the ped changed (a bot's ped may come late).
local function balloon(id)
    local ped, entity = Games.pedOf(id), here.balloons[id]
    if entity and DoesEntityExist(entity) and ped and IsEntityAttachedToEntity(entity, ped) then return end
    unballoon(id)
    local hash, h = modelFor(cfg.Models, id), cfg.Hold
    if not ped or not hash or not pcall(lib.requestModel, hash, 2000) then return end
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    entity = CreateObject(hash, 0.0, 0.0, 0.0, false, false, false)
    SetEntityCollision(entity, false, false)
    AttachEntityToEntity(entity, ped, GetPedBoneIndex(ped, h.bone), h.offset.x, h.offset.y, h.offset.z, h.rotation.x, h.rotation.y, h.rotation.z,
        true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(hash)
    here.balloons[id] = entity
end

local function unballoonAll()
    for id in pairs(here.balloons) do unballoon(id) end
end

-- The balloons in hand, the hold pose for my ped and my bots, nothing for the dater or the popped.
local function refresh()
    local s = here.s
    if not s then return end
    for id in pairs(here.players) do
        local pair = s.phase == 'date' and id == s.chosen -- the chosen one lets theirs go in the scene
        if holding(id) and not pair then
            balloon(id)
            local ped = mine(id)
            if ped and not IsEntityPlayingAnim(ped, cfg.Anim.hold.dict, cfg.Anim.hold.clip, 3) then anim(ped, cfg.Anim.hold, true) end
        elseif not pair then
            unballoon(id)
        end
    end
end

-- A balloon let go: it rises and drifts off, then goes.
local function release(id)
    local entity = here.balloons[id]
    here.balloons[id] = nil
    if not entity or not DoesEntityExist(entity) then return end
    DetachEntity(entity, false, false)
    CreateThread(function()
        local from, till = GetEntityCoords(entity), GetGameTimer() + 7000
        while GetGameTimer() < till and DoesEntityExist(entity) do
            local k = 1.0 - (till - GetGameTimer()) / 7000
            SetEntityCoordsNoOffset(entity, from.x + math.sin(k * 6.0) * 0.4, from.y + k * 1.5, from.z + k * 9.0, false, false, false)
            Wait(0)
        end
        if DoesEntityExist(entity) then DeleteEntity(entity) end
    end)
end

-- Spots ----------------------------------------------------------------------------------------------------------

local function spotOf(id)
    local s, v = here.s, here.venue
    if id == s.dater then return v.x, v.y, v.h or 0.0 end
    return Spot.spot({ x = v.x, y = v.y, w = v.h }, s.spots[id], s.n, s.radius, s.arc)
end

-- My ped and my bots walk to their spots and face the right way; far away they are put there.
local function place(id)
    local ped = mine(id)
    if not ped or (id ~= here.s.dater and not here.s.spots[id]) then return end
    local x, y, h = spotOf(id)
    local z = here.venue.z
    ClearPedTasks(ped)
    if #(GetEntityCoords(ped).xy - vector2(x, y)) > 8.0 then
        SetEntityCoords(ped, x, y, z, false, false, false, false)
        SetEntityHeading(ped, h)
    else
        TaskGoStraightToCoord(ped, x, y, z, 1.0, 8000, h, 0.15)
    end
end

-- The strip ------------------------------------------------------------------------------------------------------

local function strip()
    local s = here.s
    if not s then return end
    if not playing() and not near(cfg.WatchRange) then return Games.hideOverlay('games.scorebar') end
    local left = 0
    for id in pairs(s.spots or {}) do
        if holding(id) then left = left + 1 end
    end
    local items = { { label = t('balloon.dater'), value = nameOf(s.dater) } }
    if s.phase == 'round' or s.phase == 'break' then
        items[#items + 1] = { label = t('balloon.round', s.round, #s.rounds), value = t('balloon.round_' .. (s.rounds[s.round] or 'intro')) }
    elseif s.phase == 'choice' then
        items[#items + 1] = { label = t('balloon.choice'), value = s.aim and s.aim ~= 0 and nameOf(s.aim) or t('balloon.nobody') }
    elseif s.phase == 'date' then
        items[#items + 1] = { label = t('balloon.date'), value = ('%s & %s'):format(nameOf(s.dater), nameOf(s.chosen)), hot = true }
    end
    items[#items + 1] = { label = t('balloon.left'), value = ('%d/%d'):format(left, s.n or 0), hot = left <= 1 }
    local timed = s.phase == 'round' or s.phase == 'choice'
    Games.overlay('games.scorebar', { game = 'party', title = t('games.game_balloon'), items = items,
        remaining = timed and math.max(0, math.ceil((s.endsAt - Games.serverNow()) / 1000)) or nil })
end

-- Over the heads -------------------------------------------------------------------------------------------------

local function text3d(at, text, color, scale)
    SetDrawOrigin(at.x, at.y, at.z, 0)
    SetTextScale(0.0, scale)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(color[1], color[2], color[3], 240)
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

local function drawLoop()
    if here.drawing then return end
    here.drawing = true
    local red, pink = { 235, 70, 70 }, { 255, 150, 190 }
    while here.s do
        local s, now = here.s, GetGameTimer()
        if near(cfg.DrawRange) then
            -- the spots on the ground while everyone walks there
            if s.phase == 'intro' and playing() then
                for id in pairs(here.players) do
                    if id == s.dater or s.spots[id] then
                        local x, y = spotOf(id)
                        DrawMarker(25, x, y, here.venue.z + 0.03, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.8, 0.8, 0.8, 255, 120, 160, 140, false, false, 2, false, nil, nil, false)
                    end
                end
            end
            for id, untilMs in pairs(here.flags) do
                local ped = now < untilMs and Games.pedOf(id)
                if ped then text3d(GetPedBoneCoords(ped, 31086, 0.0, 0.0, 0.0) + vector3(0.0, 0.0, 0.42), t('balloon.red_flag'), red, 0.5)
                elseif now >= untilMs then here.flags[id] = nil end
            end
            local aimed = s.phase == 'choice' and s.aim and s.aim ~= 0 and Games.pedOf(s.aim)
            if aimed then
                local head = GetPedBoneCoords(aimed, 31086, 0.0, 0.0, 0.0)
                DrawMarker(2, head.x, head.y, head.z + 0.7, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.22, 0.22, 0.22, 255, 120, 160, 230, true, true, 2, false, nil, nil, false)
                text3d(head + vector3(0.0, 0.0, 0.42), nameOf(s.aim), pink, 0.42)
            end
            Wait(0)
        else
            Wait(500)
        end
    end
    here.drawing = false
end

-- The date scene ------------------------------------------------------------------------------------------------

local cam

local function endCam(ease)
    if not cam then return end
    RenderScriptCams(false, ease > 0, ease, true, false)
    local old = cam
    cam = nil
    SetTimeout(ease + 100, function()
        if DoesCamExist(old) then DestroyCam(old, false) end
    end)
end

local function norm(v)
    local l = #v
    return l > 0.001 and v / l or v
end

-- A slow two-shot of the pair from the side, swinging a little round them; the skip key or the end eases back.
local function film(ha, hb, ms)
    local c = cfg.Cinema
    local mid = (ha + hb) / 2 - vector3(0.0, 0.0, 0.15)
    local line = norm(vector3(hb.x - ha.x, hb.y - ha.y, 0.0))
    local side = vector3(-line.y, line.x, 0.0)
    if #(GetEntityCoords(cache.ped) - (mid + side)) > #(GetEntityCoords(cache.ped) - (mid - side)) then side = -side end -- the side I stand on
    local swing = math.rad(c.Swing)
    local turned = norm(side * math.cos(swing) + line * math.sin(swing))
    local from, to = mid + side * c.From + vector3(0.0, 0.0, 0.25), mid + turned * c.To + vector3(0.0, 0.0, 0.1)
    local wide = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', from.x, from.y, from.z, 0.0, 0.0, 0.0, c.Fov, false, 2)
    local close = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', to.x, to.y, to.z, 0.0, 0.0, 0.0, c.Fov - 6.0, false, 2)
    PointCamAtCoord(wide, mid.x, mid.y, mid.z)
    PointCamAtCoord(close, mid.x, mid.y, mid.z)
    SetCamActive(wide, true)
    RenderScriptCams(true, true, 1000, true, false)
    SetCamActiveWithInterp(close, wide, ms, 1, 1)
    cam = close
    SetTimeout(ms + 200, function() if DoesCamExist(wide) then DestroyCam(wide, false) end end)
    local till = GetGameTimer() + ms
    while GetGameTimer() < till and here.s and cam == close do
        HideHudAndRadarThisFrame()
        DisableAllControlActions(0)
        EnableControlAction(0, 249, true) -- push to talk
        if IsDisabledControlJustPressed(0, c.Skip) or IsEntityDead(cache.ped) then break end
        Wait(0)
    end
    endCam(1000)
end

local function date(dater, chosen)
    local da, ch = Games.pedOf(dater), Games.pedOf(chosen)
    if not da or not ch then return end
    sfx('date', GetEntityCoords(da))
    -- the chosen one walks up to the dater; each client moves only its own ped (and its bots)
    local mineCh, mineDa = mine(chosen), mine(dater)
    local f = GetEntityForwardVector(da)
    local meet = GetEntityCoords(da) + f * 0.9
    if mineCh then
        ClearPedTasks(mineCh)
        TaskGoStraightToCoord(mineCh, meet.x, meet.y, here.venue.z, 1.0, cfg.Cinema.WalkMs, (GetEntityHeading(da) + 180.0) % 360, 0.1)
    end
    if mineDa then ClearPedTasks(mineDa) end
    CreateThread(function()
        local filming = cfg.Cinema.Enabled and playing()
        local head = GetPedBoneCoords(da, 31086, 0.0, 0.0, 0.0)
        if filming then CreateThread(function() film(head, vector3(meet.x, meet.y, head.z), cfg.DateSeconds * 1000 - 1500) end) end
        Wait(cfg.Cinema.WalkMs)
        if not here.s then return end
        if mineCh then anim(mineCh, cfg.Anim.chosen, false) end
        if mineDa then anim(mineDa, cfg.Anim.dater, false) end
        release(chosen)
        local at = (GetEntityCoords(da) + GetEntityCoords(ch)) / 2 + vector3(0.0, 0.0, 1.0)
        for _ = 1, cfg.Confetti.bursts or 1 do
            burst(cfg.Confetti, at)
            Wait(700)
        end
    end)
end

-- Keys -------------------------------------------------------------------------------------------------------------

local function act(name, data)
    if busy then return end
    busy = true
    CreateThread(function()
        local result = Games.call('balloon:' .. name, data)
        busy = false
        if not result.ok then Games.fail(result) end
    end)
end

-- The dater's pick moves along the balloons still up, then to nobody, and round again.
local function choices()
    local s, list = here.s, {}
    for id in pairs(s.spots) do
        if holding(id) then list[#list + 1] = id end
    end
    table.sort(list, function(a, b) return s.spots[a] < s.spots[b] end)
    list[#list + 1] = 0
    return list
end

local function step(dir)
    local list, at = choices(), 1
    for i, id in ipairs(list) do
        if id == (here.s.aim or 0) then at = i end
    end
    act('aim', { id = list[(at - 1 + dir) % #list + 1] })
end

local function playLoop()
    if here.loop then return end
    here.loop = true
    local shown, held = nil, nil
    while here.s and playing() do
        local s, me = here.s, cache.serverId
        local text
        if s.phase == 'intro' then text = t(me == s.dater and 'balloon.keys_intro_dater' or 'balloon.keys_intro')
        elseif me == s.dater then
            if s.phase == 'round' then text = t('balloon.keys_dater')
            elseif s.phase == 'choice' then text = t('balloon.keys_choice') end
        elseif holding(me) and (s.phase == 'round' or s.phase == 'break') then
            text = t(held and 'balloon.keys_popping' or 'balloon.keys_pop')
        elseif s.popped[me] then text = t('balloon.keys_out') end
        if shown ~= text then
            if text then lib.showTextUI(text) else lib.hideTextUI() end
            shown = text
        end
        if not Nui.isOpen() then
            if me == s.dater then
                if s.phase == 'round' and IsControlJustPressed(0, 38) then act('next')
                elseif s.phase == 'choice' then
                    if IsControlJustPressed(0, 174) then step(-1)
                    elseif IsControlJustPressed(0, 175) then step(1)
                    elseif IsControlJustPressed(0, 38) then
                        anim(cache.ped, cfg.Anim.point, false)
                        act('pick', { id = s.aim or 0 })
                    end
                end
            elseif holding(me) and (s.phase == 'round' or s.phase == 'break') then
                -- held a little, so a stray E never pops it
                if IsControlPressed(0, 38) then
                    held = held or GetGameTimer()
                    if GetGameTimer() - held >= cfg.PopHoldMs then
                        held = nil
                        act('pop')
                        while IsControlPressed(0, 38) do Wait(0) end
                    end
                else
                    held = nil
                end
            end
        end
        Wait(0)
    end
    here.loop = false
    lib.hideTextUI()
end

-- The game ---------------------------------------------------------------------------------------------------------

Games.kind('balloon_stage', function(record)
    return { options = Games.venueOptions(record, 'fa-solid fa-heart'), distance = 2.5, targetSphere = { radius = 1.0, height = 0.6 } }
end)

local function stop()
    unballoonAll()
    endCam(0)
    for id in pairs(here.players) do
        local ped = mine(id)
        if ped then StopAnimTask(ped, cfg.Anim.hold.dict, cfg.Anim.hold.clip, 1.0) end
    end
    here.id, here.s, here.venue, here.players, here.flags = nil, nil, nil, {}, {}
    Games.hideOverlay('games.scorebar')
end

Games.onScene('balloon', function(op, args, _, scene)
    local s = here.s
    if op == 'start' or op == 'full' then
        local again = here.id == scene.id
        here.id, here.venue, here.s = scene.id, args.venue, args.scene or {}
        here.s.popped = here.s.popped or {}
        here.players = {}
        for _, p in ipairs(args.players or {}) do here.players[p.id] = p end
        -- the popped and spots tables come keyed by strings over the wire
        local popped, spots = {}, {}
        for id, n in pairs(here.s.popped) do popped[tonumber(id)] = n end
        for id, n in pairs(here.s.spots or {}) do spots[tonumber(id)] = n end
        here.s.popped, here.s.spots = popped, spots
        if not again then here.flags = {} end
        if op == 'start' then
            for id in pairs(here.players) do place(id) end
        end
        refresh()
        CreateThread(drawLoop)
        if playing() then CreateThread(playLoop) end
    elseif not s then
        return
    elseif op == 'phase' then
        s.phase, s.round, s.endsAt = args.phase, args.round, args.endsAt
        if args.aim ~= nil then s.aim = args.aim end
        if args.phase == 'round' then
            sfx('bell', here.venue and vector3(here.venue.x, here.venue.y, here.venue.z))
            if playing() then lib.notify({ description = t('balloon.round_start', t('balloon.round_' .. (args.key or 'intro'))) }) end
        elseif args.phase == 'choice' and playing() then
            lib.notify({ description = s.dater == cache.serverId and t('balloon.you_choose') or t('balloon.choosing', nameOf(s.dater)) })
        elseif args.phase == 'date' then
            s.chosen = args.chosen
            lib.notify({ description = t('balloon.dated', nameOf(args.dater), nameOf(args.chosen)), type = 'success' })
            date(args.dater, args.chosen)
        elseif args.phase == 'over' then
            lib.notify({ description = args.alone and t('balloon.alone', nameOf(s.dater)) or t('balloon.no_pick', nameOf(s.dater)) })
        end
    elseif op == 'pop' then
        s.popped[args.id] = args.n
        here.flags[args.id] = GetGameTimer() + cfg.FlagSeconds * 1000
        local entity = here.balloons[args.id]
        local ped = Games.pedOf(args.id)
        local at = entity and DoesEntityExist(entity) and GetEntityCoords(entity) or ped and GetEntityCoords(ped) + vector3(0.0, 0.0, 1.0)
        unballoon(args.id)
        if at then
            burst(cfg.Pop, at)
            sfx('pop', at)
        end
        local own = mine(args.id)
        if own then anim(own, cfg.Anim.pop, false) end
        if playing() or near(cfg.WatchRange) then lib.notify({ description = t('balloon.popped', nameOf(args.id)) }) end
    elseif op == 'aim' then
        s.aim = args.id
    elseif op == 'left' then
        here.players[args.id] = nil
        unballoon(args.id)
    elseif op == 'end' then
        return stop()
    end
    refresh()
    strip()
end)

-- Balloons for peds that came late, the hold pose back after a bump, and the strip's clock.
CreateThread(function()
    while true do
        Wait(here.s and 1000 or 5000)
        if here.s then
            refresh()
            strip()
        end
    end
end)

-- The admin test: a stage where you stand with you as the dater, and test bots on the half moon.
if (cfg.TestCommand or '') ~= '' then
    RegisterCommand(cfg.TestCommand, function(_, args)
        CreateThread(function()
            local result = Games.call('balloon:test', { h = GetEntityHeading(cache.ped) })
            if not result.ok then return Games.fail(result) end
            Wait(300)
            if Config.Bots.Enabled and Config.Bots.Command ~= '' then ExecuteCommand(('%s %d'):format(Config.Bots.Command, tonumber(args[1]) or 6)) end
            Wait(500)
            Games.openLobby()
        end)
    end, false)
    TriggerEvent('chat:addSuggestion', '/' .. cfg.TestCommand, t('balloon.command_test'), { { name = 'bots', help = t('balloon.command_test_arg') } })
end

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource and here.s then stop() end
end)
