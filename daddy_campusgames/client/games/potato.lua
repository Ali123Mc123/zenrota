-- Hot potato on the client: the potato in the holder's hand (every nearby client attaches it), its ticking, the ring
-- on the ground and the key: E passes it when you hold it.
local cfg = Config.Potato
local t = DL.locale.t
local here = { id = nil, holder = nil, hot = false, out = {}, entity = nil, ring = nil }

local function model()
    for _, name in ipairs(cfg.Models) do
        if IsModelInCdimage(joaat(name)) then return joaat(name) end
    end
end

local function drop()
    if here.entity and DoesEntityExist(here.entity) then DeleteEntity(here.entity) end
    here.entity = nil
end

-- The potato goes to the holder's right hand.
local function hold(id)
    drop()
    local ped, hash, h = id and Games.pedOf(id), model(), cfg.Hold
    if not ped or not hash or not pcall(lib.requestModel, hash, 3000) then return end
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    here.entity = CreateObject(hash, 0.0, 0.0, 0.0, false, false, false)
    SetEntityCollision(here.entity, false, false)
    AttachEntityToEntity(here.entity, ped, GetPedBoneIndex(ped, h.bone), h.offset.x, h.offset.y, h.offset.z, h.rotation.x, h.rotation.y, h.rotation.z,
        true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(hash)
end

local function nameOf(scene, id)
    for _, p in ipairs(scene.public and scene.public.players or {}) do
        if p.id == id then return p.name end
    end
    return ''
end

local function bar(scene)
    local alive, total = 0, 0
    for _, p in ipairs(scene.public and scene.public.players or {}) do
        total = total + 1
        if not here.out[p.id] then alive = alive + 1 end
    end
    Games.overlay('games.scorebar', { game = 'party', title = t('games.game_potato'), items = {
        { label = t('potato.holder'), value = here.holder and nameOf(scene, here.holder) or '–', hot = here.hot },
        { label = t('potato.left'), value = ('%d/%d'):format(alive, total) } } })
end

-- While I play: the ring, the ticking, and E to pass.
local function playLoop()
    if here.playing then return end
    here.playing = true
    local shown, tickAt = nil, 0
    while here.id and Games.lobby and Games.lobby.id == here.id do
        local r, c = here.ring, here.center
        if r and c then DrawMarker(1, c.x, c.y, c.z + 0.02, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, r * 2, r * 2, 0.25, 230, 120, 40, 60, false, false, 2, false, nil, nil, false) end
        local now = GetGameTimer()
        if here.entity and now >= tickAt then
            local p = GetEntityCoords(here.entity)
            PlaySoundFromCoord(-1, 'CLICK_BACK', p.x, p.y, p.z, 'WEB_NAVIGATION_SOUNDS_PHONE', false, 10, false)
            tickAt = now + (here.hot and 350 or 1000)
        end
        local mine = here.holder == cache.serverId
        local text = here.out[cache.serverId] and t('potato.out_self') or mine and t('potato.pass_key') or t('potato.run')
        if shown ~= text then lib.showTextUI(text) shown = text end
        if mine and IsControlJustPressed(0, 38) and not Nui.isOpen() then
            CreateThread(function()
                local result = Games.call('potato:pass')
                if not result.ok then Games.fail(result) end
            end)
        end
        Wait(0)
    end
    here.playing = false
    lib.hideTextUI()
end

Games.kind('potato_ring', function(record)
    return { options = Games.venueOptions(record, 'fa-solid fa-fire'), distance = 2.5 }
end)

Games.onScene('potato', function(op, args, _, scene)
    if op == 'start' or op == 'full' then
        local s = args.scene or {}
        here.id, here.holder, here.hot, here.out, here.ring = scene.id, s.holder, s.hot, s.out or {}, s.radius
        here.center = args.venue
        -- A potato set up from an item lies at the spot: it goes into the game's hands meanwhile.
        local marker = Games.entity('potato_ring', args.venue.uid)
        if marker and DoesEntityExist(marker) then SetEntityVisible(marker, false, false) end
        hold(here.holder)
        if Games.lobby and Games.lobby.id == scene.id then CreateThread(playLoop) end
    elseif op == 'round' then
        here.holder, here.hot = args.holder, false
        hold(args.holder)
        lib.notify({ description = t('potato.round', args.round, nameOf(scene, args.holder)) })
    elseif op == 'pass' then
        here.holder = args.to
        hold(args.to)
        local thrower = args.from == cache.serverId and cache.ped or Games.myBot(args.from)
        if thrower and lib.requestAnimDict('mp_common', 1000) then
            TaskPlayAnim(thrower, 'mp_common', 'givetake1_a', 8.0, 4.0, 800, 48, 0.0, false, false, false)
        end
    elseif op == 'hot' then
        here.hot = true
    elseif op == 'out' then
        here.out[args.id] = args.place or true
        if args.id == here.holder then
            here.holder = nil
            drop()
        end
        if args.id == cache.serverId then
            SetPedToRagdoll(cache.ped, 2500, 2500, 0, false, false, false)
            ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.3)
        elseif Games.myBot(args.id) then
            SetPedToRagdoll(Games.myBot(args.id), 2500, 2500, 0, false, false, false)
        end
        PlaySoundFrontend(-1, 'TIMER_STOP', 'HUD_MINI_GAME_SOUNDSET', true)
        lib.notify({ description = t('potato.out_' .. (args.why == 'pop' and 'pop' or 'away'), args.name or ''), type = args.id == cache.serverId and 'error' or 'inform' })
    elseif op == 'end' then
        drop()
        local marker = here.center and Games.entity('potato_ring', here.center.uid)
        if marker and DoesEntityExist(marker) then SetEntityVisible(marker, true, false) end
        here.id, here.holder = nil, nil
        Games.hideOverlay('games.scorebar')
        return
    end
    bar(scene)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then drop() end
end)
