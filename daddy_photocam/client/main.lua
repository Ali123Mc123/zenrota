-- Keys, the panel and photos. Hold V: free camera without the panel. F6: photo mode.
local t = DL.locale.t
local RESOURCE = GetCurrentResourceName()

local panel = { open = false, shown = false, mouse = false }
local damagedAt = 0
local Close
local UNARMED = GetHashKey('WEAPON_UNARMED')

local function notify(text, kind)
    lib.notify({ description = text, type = kind or 'inform' })
end

AddEventHandler('gameEventTriggered', function(name, args)
    if name ~= 'CEventNetworkEntityDamage' then return end
    local ped = PlayerPedId()
    if args[1] == ped or args[2] == ped then
        damagedAt = GetGameTimer()
        if Cam.mode() then Close() end
    end
end)

local function cuffedOrDown(ped)
    local state = LocalPlayer.state
    return IsPedCuffed(ped) or state.isCuffed or state.isDead or state.dead or IsPedDeadOrDying(ped, true)
        or IsPedRagdoll(ped) or IsPedFalling(ped)
end

-- Why the camera cannot open now, or nil.
local function refusal(kind)
    local ped = PlayerPedId()
    if IsPauseMenuActive() or cuffedOrDown(ped) then return t('errors.busy') end
    local left = math.ceil((damagedAt + Config.Block.DamageSeconds * 1000 - GetGameTimer()) / 1000)
    if damagedAt > 0 and left > 0 then return t('errors.damage', left) end
    if kind ~= 'look' and Config.Block.Weapon and GetSelectedPedWeapon(ped) ~= UNARMED then return t('errors.weapon') end
    local veh = GetVehiclePedIsIn(ped, false)
    local moving = veh ~= 0 and GetEntitySpeed(veh) > 1.0
    if moving and (kind ~= 'look' or (Config.Block.Driving and GetPedInVehicleSeat(veh, -1) == ped)) then
        return t('errors.driving')
    end
    if kind ~= 'look' and IsNuiFocused() then return t('errors.busy') end
end

local function page(action, data)
    data = data or {}
    data.action = action
    SendNUIMessage(data)
end

local function setFocus(on)
    SetNuiFocus(on, on)
    SetNuiFocusKeepInput(on)
end

-- Panel shown: the cursor works the panel and the keys still move the camera; hidden: the mouse looks.
local function showPanel(shown)
    panel.shown, panel.mouse = shown, false
    setFocus(shown)
    page('panel', { shown = shown })
end

Close = function()
    if not Cam.mode() then return end
    Cam.close()
    if panel.open then
        panel.open = false
        setFocus(false)
        page('close')
    end
    World.reset()
end

local generation = 0
local tiltSent, tiltHeld = 0, false -- the panel hears a held tilt at most every 80 ms, and once more on release

local function frame()
    generation = generation + 1
    local mine = generation
    CreateThread(function()
        while Cam.mode() and mine == generation do
            DisableAllControlActions(0)
            EnableControlAction(0, 249, true) -- push to talk
            if cuffedOrDown(PlayerPedId()) then Close() break end
            if panel.open then
                local free = not panel.shown or panel.mouse
                if panel.mouse and not IsDisabledControlPressed(0, 25) and GetGameTimer() - panel.mouseAt > 150 then
                    panel.mouse = false
                    setFocus(true)
                end
                if not panel.shown then
                    if IsDisabledControlPressed(0, 15) then page('fov', { value = Cam.zoom(-1.5) }) end
                    if IsDisabledControlPressed(0, 14) then page('fov', { value = Cam.zoom(1.5) }) end
                    if IsDisabledControlJustPressed(0, 74) then showPanel(true) end
                    if IsDisabledControlJustPressed(0, 174) then page('filter', { dir = -1 }) end
                    if IsDisabledControlJustPressed(0, 175) then page('filter', { dir = 1 }) end
                    if IsDisabledControlJustPressed(0, 191) or IsDisabledControlJustPressed(0, 22) then page('shoot') end
                    if IsDisabledControlJustPressed(0, 200) or IsDisabledControlJustPressed(0, 177) then Close() end
                end
                -- Tilt works with the panel shown too (the panel keeps the game's keys, as for WASD).
                local tilt, way = Config.Keys.TiltSpeed * GetFrameTime(), 0
                if IsDisabledControlPressed(0, Config.Keys.TiltLeft.Control) then way = way - 1 end
                if IsDisabledControlPressed(0, Config.Keys.TiltRight.Control) then way = way + 1 end
                if way ~= 0 then
                    local value = Cam.roll(tilt * way)
                    if GetGameTimer() - tiltSent > 80 then tiltSent = GetGameTimer() page('roll', { value = value }) end
                    tiltHeld = true
                elseif tiltHeld then
                    tiltHeld = false
                    page('roll', { value = Cam.roll(0) })
                end
                Cam.tick(free)
            else
                Cam.tick(true)
            end
            Wait(0)
        end
    end)
end

local function openPanel(shown)
    local why = refusal('free')
    if why then return notify(why, 'error') end
    if not Cam.open('free') then return end
    World.hud(true)
    panel.open = true
    local lang = DL.locale.language()
    page('open', {
        locale = Locales[lang],
        language = lang,
        shown = shown,
        cam = Cam.state(),
        filters = Config.Filters,
        weathers = Config.Weathers,
        accent = Config.Accent,
        phone = GetResourceState('daddy_studentphone') == 'started' or GetResourceState('cylex_phone') == 'started',
        tiltKeys = { Config.Keys.TiltLeft.Label, Config.Keys.TiltRight.Label },
    })
    showPanel(shown)
    frame()
end

-- V: hold to open the free camera (no panel), press again to close; a short tap stays the game's own V.
local held, press, opened = false, 0, false

-- Letting V go must not also switch the game's view.
local function keepView()
    local stop = GetGameTimer() + 300
    CreateThread(function()
        while GetGameTimer() < stop do
            DisableControlAction(0, 0, true)
            Wait(0)
        end
    end)
end

RegisterCommand('+daddy_photocam_look', function()
    if Cam.mode() then
        if not panel.shown then Close() keepView() end
        return
    end
    held = true
    press = press + 1
    local mine = press
    SetTimeout(Config.Keys.HoldMs, function()
        if held and mine == press and not Cam.mode() then
            opened = true
            openPanel(false)
        end
    end)
end, false)

RegisterCommand('-daddy_photocam_look', function()
    held = false
    if opened then
        opened = false
        keepView()
    end
end, false)

RegisterKeyMapping('+daddy_photocam_look', t('keys.look'), 'keyboard', Config.Keys.Look)

RegisterCommand('daddy_photocam', function()
    if Cam.mode() and panel.shown then return Close() end
    if Cam.mode() then return showPanel(true) end
    openPanel(true)
end, false)

RegisterKeyMapping('daddy_photocam', t('keys.photo'), 'keyboard', Config.Keys.Photo)

-- Page callbacks -------------------------------------------------------------

local function reply(cb, value) cb(value == nil and {} or value) end

RegisterNUICallback('close', function(_, cb) Close() reply(cb) end)

RegisterNUICallback('panel', function(data, cb)
    showPanel(data.shown == true)
    reply(cb)
end)

-- Right mouse held on the game: the mouse turns the camera until it is let go.
RegisterNUICallback('look', function(_, cb)
    if panel.open and panel.shown then
        panel.mouse, panel.mouseAt = true, GetGameTimer()
        SetNuiFocus(false, false)
    end
    reply(cb)
end)

RegisterNUICallback('set', function(data, cb)
    local key = data.key
    if key == 'fov' or key == 'roll' or key == 'dof' then Cam.set(key, data.value)
    elseif key == 'filter' then World.filter(data.value, data.strength)
    elseif key == 'scene' then World.scene(data.weather, data.hour) end
    reply(cb, Cam.state())
end)

RegisterNUICallback('zoom', function(data, cb)
    reply(cb, { fov = Cam.zoom(tonumber(data.delta) or 0) })
end)

local function result(res, okText)
    if type(res) ~= 'table' then return notify(t('errors.upload'), 'error') end
    if res.ok then
        if okText then notify(okText, 'success') end
    else
        notify(t(res.err or 'errors.upload', table.unpack(res.args or {})), 'error')
    end
end

RegisterNUICallback('presign', function(_, cb)
    local res = lib.callback.await('daddy_photocam:presign', false)
    if type(res) ~= 'table' or not res.ok then result(res) end
    reply(cb, res)
end)

RegisterNUICallback('saved', function(data, cb)
    local res = lib.callback.await('daddy_photocam:saved', false, data)
    result(res, t('notify.saved'))
    if type(res) == 'table' and res.ok and res.photo then lib.setClipboard(res.photo.url) end
    reply(cb, res)
end)

RegisterNUICallback('failed', function(data, cb)
    notify(t(data.err == 'empty' and 'errors.empty' or 'errors.upload'), 'error')
    reply(cb)
end)

RegisterNUICallback('photos', function(_, cb)
    reply(cb, lib.callback.await('daddy_photocam:list', false))
end)

RegisterNUICallback('copy', function(data, cb)
    if type(data.url) == 'string' and data.url:find('^https://') then
        lib.setClipboard(data.url)
        notify(t('notify.copied'), 'success')
    end
    reply(cb)
end)

RegisterNUICallback('phone', function(data, cb)
    local res = lib.callback.await('daddy_photocam:phone', false, tonumber(data.id))
    result(res, t(type(res) == 'table' and res.msg or 'notify.phone'))
    reply(cb, res)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == RESOURCE then Close() end
end)
