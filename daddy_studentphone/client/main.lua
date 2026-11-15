-- Student Phone client: open and close, the phone in hand and the NUI bridge. The player can walk while it is open.
local RESOURCE = GetCurrentResourceName()
local CLOSE_GRACE_MS = 1000

-- Config.Controls.Blocked stay off while the phone is up; looking around (LOOK) too, until the look key frees it.
local LOOK = { 1, 2 }

PhoneUI = { open = false }

local typing
local disabled = false -- another resource keeps the phone in the pocket (ToggleDisabled)

local function notify(key)
    lib.notify({ description = DL.locale.t(key), type = 'error' })
end

-- Why the phone cannot be in hand now: 'dead' (it goes quietly), 'restrained' (down, cuffed or swimming, as
-- Config.PutAway says), or nil.
local function unfit(ped)
    if IsEntityDead(ped) then return 'dead' end
    local rule, st = Config.PutAway, LocalPlayer.state
    if rule.Downed and (IsPedDeadOrDying(ped, true) or st.isDead or st.laststand or st.inLastStand) then return 'restrained' end
    if rule.Cuffed and (IsPedCuffed(ped) or st.isCuffed or st.handcuffed or st.isHandcuffed) then return 'restrained' end
    if rule.Water and IsPedSwimming(ped) then return 'restrained' end
end

-- The server's main phone (cylex_phone) is up or in a call: the student phone stays in the pocket then, so the two never
-- share the hands, the cursor or the screen.
local function mainPhoneBusy()
    if GetResourceState('cylex_phone') ~= 'started' then return false end
    local ok, open = pcall(function() return exports.cylex_phone:IsOpen() end)
    if ok and open then return true end
    local call = LocalPlayer.state.callData
    return type(call) == 'table' and next(call) ~= nil
end

-- A call was answered or ended (client/call.lua); client/pose.lua moves the hand.
function PhoneUI.setCall(active) Pose.set('call', active) end

-- The camera is up (client/camera.lua): the hand holds the phone up for it, and reads again after.
function PhoneUI.setCamera(on) Pose.set('camera', on) end

-- The prop in the hand, for the camera to hide it from the player's own picture.
function PhoneUI.propEntity() return Pose.prop() end

-- A weapon in hand goes away as the phone comes out (ox_inventory puts its own away, so it stays in step).
local UNARMED = joaat('WEAPON_UNARMED')
local function disarm()
    local ped = PlayerPedId()
    if GetSelectedPedWeapon(ped) == UNARMED then return end
    if GetResourceState('ox_inventory') == 'started' then TriggerEvent('ox_inventory:disarm', true) else SetCurrentPedWeapon(ped, UNARMED, true) end
end

-- When the phone was last put away: what the page sends as it closes (Screen Time's last app) still goes through.
local closedAt

function PhoneUI.close()
    if not PhoneUI.open then return end
    if Camera and Camera.on then Camera.stop(true) end
    PhoneUI.open, typing, closedAt = false, false, GetGameTimer()
    SendNUIMessage({ action = 'close' })
    SetNuiFocusKeepInput(false)
    DL.focus.release()
    Pose.set({ open = false, camera = false, landscape = false })
    -- Give in-flight requests a moment before the server drops the session.
    SetTimeout(CLOSE_GRACE_MS, function()
        if not PhoneUI.open then TriggerServerEvent(RESOURCE .. ':close') end
    end)
end

-- Held, the look key lets go of the cursor so the player can look around with the phone still up.
local looking = false
local gen = 0 -- each opening has its own loop; a quick close and open ends the old one

-- The one loop while the phone is up: the controls every frame; every half second death, cuffs, water and the pause
-- menu (they put it away) and the hold; the game clock every two seconds when the server shows game time. None in the
-- pocket.
local function hold()
    gen = gen + 1
    local mine, check, clock = gen, 0, 0
    CreateThread(function()
        while PhoneUI.open and gen == mine do
            -- The camera aims with the mouse and holds the game's own phone: its loop (client/camera.lua) keeps the keys.
            if not looking and not Pose.get('camera') then
                for _, control in ipairs(LOOK) do DisableControlAction(0, control, true) end
            end
            for _, control in ipairs(Config.Controls.Blocked) do DisableControlAction(0, control, true) end
            local now = GetGameTimer()
            if now >= check then
                check = now + 500
                local why = unfit(PlayerPedId())
                if why or IsPauseMenuActive() or mainPhoneBusy() then PhoneUI.close() end
                if why == 'restrained' then notify('errors.blocked') end
            end
            if Config.Clock == 'game' and now >= clock then
                clock = now + 2000
                SendNUIMessage({ action = 'clock', h = GetClockHours(), m = GetClockMinutes() })
            end
            Wait(0)
        end
    end)
end

-- The player's own language for the phone (kept on this machine), else the server's.
function PhoneUI.language()
    local lang = GetResourceKvpString('language')
    return lang and Locales[lang] and lang or DL.locale.language()
end

-- Config.Screen for the page, with the phone key's name (an incoming call in the pocket says which key takes it out).
function PhoneUI.screen()
    local out = {}
    for k, v in pairs(Config.Screen) do out[k] = v end
    out.Key = Config.Key
    return out
end

-- The page asks once it has loaded: the language and the screen corner, for banners before the phone first opens.
RegisterNUICallback('phone:init', function(_, cb)
    cb({ ok = true, locale = Locales[PhoneUI.language()] or DL.locale.table(), language = PhoneUI.language(), screen = PhoneUI.screen() })
end)

-- Face ID looks at the face: anything in the mask slot but Config.Passcode.NoMask covers it.
RegisterNUICallback('phone:face', function(_, cb)
    local drawable = GetPedDrawableVariation(PlayerPedId(), 1)
    cb({ ok = true, masked = not DL.util.contains(Config.Passcode.NoMask, drawable) })
end)

RegisterNUICallback('phone:language', function(data, cb)
    local lang = tostring(data.lang or '')
    if not Locales[lang] then return cb({ ok = false }) end
    SetResourceKvp('language', lang)
    cb({ ok = true, locale = Locales[lang], language = lang })
end)

-- FiveM draws the page in a GPU process of its own, which a game using all of the GPU starves: the phone then catches
-- however light the page is. The client's "Fix 'UI Lag' at high GPU usage" (nui_useInProcessGpu) cures it; the phone
-- says so once, a moment after it comes out.
local function uiLagTip()
    if GetConvarInt('nui_useInProcessGpu', 0) ~= 0 or GetResourceKvpInt('ui_lag_tip') == 1 then return end
    SetTimeout(2500, function()
        if not PhoneUI.open then return end
        SetResourceKvpInt('ui_lag_tip', 1)
        SendNUIMessage({ action = 'notify', app = 'settings', title = DL.locale.t('notify.ui_lag_title'), body = DL.locale.t('notify.ui_lag_body') })
    end)
end

-- Takes the phone out; launch = { app, params } opens that app once it has booted (OpenApp). The item is asked of the
-- server first (checked: the server just did, using the item), so a player without it never sees the phone in hand
-- and gets no notice either.
local asking = false

function PhoneUI.openPhone(launch, checked)
    if PhoneUI.open or disabled or asking or IsPauseMenuActive() or mainPhoneBusy() then return end
    local why = unfit(PlayerPedId())
    if why == 'restrained' then notify('errors.blocked') end
    if why then return end
    if not checked then
        asking = true
        local has = lib.callback.await(RESOURCE .. ':hasPhone', false)
        asking = false
        if not has then return end -- no phone: the key does nothing, quietly
        if PhoneUI.open or disabled or mainPhoneBusy() or unfit(PlayerPedId()) then return end
    end
    PhoneUI.open, looking = true, false
    DL.focus.acquire(PhoneUI.close)
    SetNuiFocusKeepInput(true)
    hold()
    disarm()
    -- A call held at the ear while away stays there until the page says the call screen is not up.
    Pose.set({ open = true, landscape = false, ear = Pose.mode() == 'call' })
    SendNUIMessage({ action = 'open', locale = Locales[PhoneUI.language()] or DL.locale.table(), language = PhoneUI.language(), screen = PhoneUI.screen(),
        payload = type(launch) == 'table' and launch or nil })
    uiLagTip()
end

-- Open, or (late) put away so recently that the server still keeps the session.
local function guarded(cb, late)
    if PhoneUI.open or (late and closedAt and GetGameTimer() - closedAt < CLOSE_GRACE_MS) then return true end
    cb({ ok = false, error = 'session_expired' })
end

-- Live topics that came while the phone was away wait for the next opening, so kept apps reload then and not in the
-- pocket: the last of each topic and of each chat or College topic it names, in the order they came. Those the opening
-- reads anew anyway are dropped, and so is typing; an alarm or a finished timer rings in the pocket at once.
local FRESH = { lesson = true, exam = true, blocked = true, focus = true, badges = true, peek = true, wifi = true, timers = true, typing = true, whisper = true }
local POCKET = { alarm = true }
local waiting = {} -- { key, data }, oldest first

-- Keeps a topic for the next opening; a newer one under the same key (topic, payload id or topic) takes the older's place.
local function later(data)
    local p = type(data.payload) == 'table' and data.payload or {}
    local key = data.topic .. ':' .. tostring(p.topic or p.id or '')
    for i, w in ipairs(waiting) do
        if w.key == key then
            table.remove(waiting, i)
            break
        end
    end
    waiting[#waiting + 1] = { key = key, data = data }
end

RegisterNUICallback('pad:bootstrap', function(_, cb)
    if not guarded(cb) then return end
    local result = lib.callback.await(RESOURCE .. ':open', false)
    -- No phone, or a rule keeps it in the pocket (cuffed, another resource's check): back it goes, with a word why.
    local refused = type(result) == 'table' and ({ no_item = 'notify.no_item', blocked = 'errors.blocked' })[result.error]
    if refused then
        PhoneUI.close()
        notify(refused)
    end
    cb(result or { ok = false, error = 'integration_unavailable' })
    local prefs = type(result) == 'table' and result.ok and type(result.data) == 'table' and result.data.prefs
    if prefs then PhoneUI.setFrame(prefs.frame) end
    if PhoneUI.open and type(result) == 'table' and result.ok then
        for _, w in ipairs(waiting) do SendNUIMessage({ action = 'sync', data = w.data }) end
        waiting = {}
    end
end)

-- Every endpoint goes through one callback; the server checks the name.
-- A new case colour: kept, and a phone in the hand becomes the new one.
function PhoneUI.setFrame(value)
    Pose.frame(value)
end

RegisterNUICallback('phone:frame', function(data, cb)
    cb({ ok = true })
    PhoneUI.setFrame(type(data) == 'table' and data.frame)
end)

RegisterNUICallback('pad:call', function(data, cb)
    if not guarded(cb, true) then return end
    local result = lib.callback.await(RESOURCE .. ':call', false, data.name, data.data)
    cb(result or { ok = false, error = 'integration_unavailable' })
end)

RegisterNUICallback('pad:heartbeat', function(_, cb)
    cb({ ok = true })
    if PhoneUI.open then TriggerServerEvent(RESOURCE .. ':heartbeat') end
end)

RegisterNUICallback('pad:close', function(_, cb)
    cb({ ok = true })
    PhoneUI.close()
end)

-- While a text field has focus, keys type instead of moving the player.
RegisterNUICallback('phone:typing', function(data, cb)
    cb({ ok = true })
    typing = data.on == true
    if PhoneUI.open then SetNuiFocusKeepInput(not typing) end
end)

-- The call screen is up on a call that is on (not on speaker or video): the phone goes to the ear, and back to
-- reading when the screen goes or the call changes.
RegisterNUICallback('phone:ear', function(data, cb)
    cb({ ok = true })
    local on = data.on == true
    if PhoneUI.open and on ~= Pose.get('ear') then Pose.set('ear', on) end
end)

-- Camera Control: with the phone out it opens the camera, in the camera it takes the shot (it never takes the phone out).
RegisterCommand('studentphone_camera', function()
    if PhoneUI.open then SendNUIMessage({ action = 'cameraKey' }) end
end, false)

RegisterKeyMapping('studentphone_camera', DL.locale.t('command.camera'), 'keyboard', Config.Camera.Key)

RegisterNetEvent(RESOURCE .. ':sync', function(data)
    local topic = type(data) == 'table' and data.topic
    if PhoneUI.open or POCKET[topic] then return SendNUIMessage({ action = 'sync', data = data }) end
    if type(topic) == 'string' and not FRESH[topic] then later(data) end
end)

RegisterNetEvent(RESOURCE .. ':open', function() PhoneUI.openPhone(nil, true) end)
RegisterNetEvent(RESOURCE .. ':close', PhoneUI.close)
RegisterNetEvent(RESOURCE .. ':notify', notify)

-- The server put the phone away (a check refuses it now): with a word why, unless it went away already.
RegisterNetEvent(RESOURCE .. ':putAway', function()
    if not PhoneUI.open then return end
    PhoneUI.close()
    notify('errors.blocked')
end)

-- The phone key opens it or puts it away; opening still goes through the server's item check. The command name is new
-- (it was studentphone_toggle): the game keeps a player's first default, so players who joined before get M only under
-- a new name.
RegisterCommand('studentphone_key', function()
    if PhoneUI.open then PhoneUI.close() else PhoneUI.openPhone() end
end, false)

RegisterKeyMapping('studentphone_key', DL.locale.t('command.toggle'), 'keyboard', Config.Key)

RegisterCommand('+studentphone_look', function()
    if not PhoneUI.open or typing or Pose.get('camera') then return end
    looking = true
    SetNuiFocus(false, false)
end, false)

RegisterCommand('-studentphone_look', function()
    if not looking then return end
    looking = false
    if PhoneUI.open and not Pose.get('camera') then SetNuiFocus(true, true) end
end, false)

-- The camera lets go of the cursor (the mouse aims it) and gives it back when it closes.
function PhoneUI.focus(on)
    if not PhoneUI.open then return end
    if Camera and Camera.on and not Camera.video then typing = false end
    SetNuiFocus(on, on)
    if on then SetNuiFocusKeepInput(not typing) end
end

RegisterKeyMapping('+studentphone_look', DL.locale.t('command.look'), 'keyboard', Config.Look.Key)

exports('Open', function() PhoneUI.openPhone() end)
exports('Close', PhoneUI.close)
exports('IsOpen', function() return PhoneUI.open end)

-- Opens the phone at an app ('card', 'x-cafe'), past the lock screen; params reach the app as a deep link. A locked
-- app (class lock, exam) says why and the phone stays home.
exports('OpenApp', function(id, params)
    if type(id) ~= 'string' or id == '' then return false end
    params = type(params) == 'table' and params or {}
    if PhoneUI.open then
        SendNUIMessage({ action = 'openApp', app = id, params = params })
    else
        PhoneUI.openPhone({ app = id, params = params })
    end
    return PhoneUI.open
end)

-- Another resource keeps the phone in the pocket (true) or lets it out again (false); an open phone goes away.
exports('ToggleDisabled', function(on)
    disabled = on == true
    if disabled then PhoneUI.close() end
end)

-- Logging out or switching characters: the phone goes away, topics held for it go, and the page starts afresh, so
-- nothing of the last character stays on it.
DL.fw.onUnloaded(function()
    PhoneUI.close()
    waiting = {}
    SendNUIMessage({ action = 'reset' })
end)


AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE then return end
    if PhoneUI.open then
        SetNuiFocusKeepInput(false)
        SetNuiFocus(false, false)
    end
end)
