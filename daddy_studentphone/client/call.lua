-- Calls on the student phone (server/calls.lua runs the lines). The server says what each call is doing; the page shows
-- it, the hand holds the phone to the ear while it is away in a call, and two keys answer and hang up without taking
-- it out of the pocket. Here too: pma-voice's mute on the voices the others muted, who is talking (this player's own
-- state goes to the others, theirs comes back for the page), the ring other players' phones make close by, speaker
-- calls this player stands next to, and the voice disguises of anonymous calls.
local RESOURCE = GetCurrentResourceName()

Call = { id = nil, state = nil, calls = {} }

local function key(action, id)
    id = id or Call.id
    if not id then return end
    CreateThread(function() lib.callback.await(RESOURCE .. ':callKey', false, action, id) end)
end

local function pma() return GetResourceState('pma-voice') == 'started' end

-- Mutes: the voices this phone muted on pma-voice (only those it muted itself are given back, never an admin's), and
-- those it should: a member's views carry who is muted; a speaker guest gets no views, so the server's mute words are
-- kept for it. pma-voice's mute silences the voice in person too, so a muted member standing within their own voice
-- range of this player is not muted here (they would be heard anyway). Its unmute leaves the voice at no volume, and a
-- far voice at none is not heard at all: the call volume goes back on the call's voices after one.
local mutedHere, muteWant = {}, {}
local guestOf -- the call this player is in as a speaker guest
local guestDisguise = {} -- src -> disguise, for the call this player is a guest in
local applyDisguises

local function within(src)
    local player = GetPlayerFromServerId(src)
    if player == -1 then return false end
    local prox = Player(src).state.proximity
    local range = type(prox) == 'table' and tonumber(prox.distance) or 3.0
    return #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(player))) <= range
end

local function callVolume()
    local ok, volume = pcall(function() return exports['pma-voice']:getCallVolume() end)
    return ok and tonumber(volume) or nil
end

-- pma-voice puts the call volume on every voice of the call (muted ones too): those muted here go quiet again.
local function hushMuted()
    for src in pairs(mutedHere) do MumbleSetVolumeOverrideByServerId(src, 0.0) end
end

local function applyMutes()
    if not pma() then return end
    local want = {}
    for src in pairs(muteWant) do want[src] = true end
    for _, c in pairs(Call.calls) do
        for _, m in ipairs(c.members or {}) do
            if m.src and m.muted then want[m.src] = true end
        end
    end
    for src in pairs(want) do
        if within(src) then want[src] = nil end
    end
    for src in pairs(want) do
        if not mutedHere[src] then
            local ok, already = pcall(function() return exports['pma-voice']:isPlayerMuted(src) end)
            if ok and not already then
                pcall(function() exports['pma-voice']:toggleMutePlayer(src) end)
                mutedHere[src] = true
            end
        end
    end
    local gaveBack = false
    for src in pairs(mutedHere) do
        if not want[src] then
            local ok, muted = pcall(function() return exports['pma-voice']:isPlayerMuted(src) end)
            if ok and muted then
                pcall(function() exports['pma-voice']:toggleMutePlayer(src) end)
                gaveBack = true
            end
            mutedHere[src] = nil
        end
    end
    if gaveBack then
        local volume = callVolume()
        if volume then pcall(function() exports['pma-voice']:setCallVolume(volume) end) end
        hushMuted()
    end
end

-- The call this player is talking on (answered, not held), and the one ringing for them.
local function current()
    local active, ringing
    for id, c in pairs(Call.calls) do
        if c.state == 'active' and not c.held then active = id elseif c.state == 'incoming' then ringing = id end
    end
    return active, ringing
end

local talkLoop = false
local startTalkLoop

local function settle()
    local active, ringing = current()
    Call.id = active or ringing or next(Call.calls)
    Call.state = Call.id and Call.calls[Call.id].state or nil
    PhoneUI.setCall(active ~= nil)
    applyMutes()
    applyDisguises()
    if active and not talkLoop then startTalkLoop() end
end

RegisterNetEvent(RESOURCE .. ':callState', function(data)
    if type(data) ~= 'table' or not data.id then return end
    -- An end for a call this phone is not on (a school line someone else took) is only for the page.
    if data.state == 'ended' then Call.calls[data.id] = nil else Call.calls[data.id] = data end
    SendNUIMessage({ action = 'call', data = data })
    settle()
end)

RegisterNetEvent(RESOURCE .. ':callMute', function(src, on)
    src = tonumber(src)
    if not src or not guestOf then return end
    muteWant[src] = on == true or nil
    applyMutes()
end)

-- Walking into or out of a muted member's voice range changes whether they are muted here.
CreateThread(function()
    while true do
        Wait(1000)
        if next(Call.calls) or guestOf or next(mutedHere) then applyMutes() end
    end
end)

-- Dying drops the call (main.lua's ear hold asks, once per call).
local died
AddEventHandler(RESOURCE .. ':callDied', function()
    if not Call.id or died == Call.id then return end
    died = Call.id
    key('hangup')
end)

RegisterCommand('studentphone_answer', function()
    local _, ringing = current()
    if ringing then key('answer', ringing) end
end, false)

RegisterCommand('studentphone_hangup', function()
    local active, ringing = current()
    if ringing then key('decline', ringing) elseif active then key('hangup', active) end
end, false)

RegisterKeyMapping('studentphone_answer', DL.locale.t('command.answer'), 'keyboard', Config.Calls.Keys.Answer)
RegisterKeyMapping('studentphone_hangup', DL.locale.t('command.hangup'), 'keyboard', Config.Calls.Keys.HangUp)

-- Talking: this player's own voice state goes to the others while a call is on (again every 3 s while it lasts, so a
-- lost word does not leave a voice drawn), and the others' come back for the page.
startTalkLoop = function()
    talkLoop = true
    CreateThread(function()
        local was, sent = false, 0
        while current() do
            local now = GetGameTimer()
            local talking = NetworkIsPlayerTalking(PlayerId()) == true
            if talking ~= was or (talking and now - sent > 3000) then
                was, sent = talking, now
                TriggerServerEvent(RESOURCE .. ':callTalk', talking)
            end
            Wait(150)
        end
        if was then TriggerServerEvent(RESOURCE .. ':callTalk', false) end
        talkLoop = false
    end)
end

-- Video in a call: the asking and the connection's messages, for the page (lib/video.ts).
RegisterNetEvent(RESOURCE .. ':video', function(data)
    if type(data) == 'table' then SendNUIMessage({ action = 'video', data = data }) end
end)

-- Clips' live streams: viewers joining and leaving, the connection's messages (lib/live.ts).
RegisterNetEvent(RESOURCE .. ':live', function(data)
    if type(data) == 'table' then SendNUIMessage({ action = 'live', data = data }) end
end)

RegisterNetEvent(RESOURCE .. ':callTalk', function(src, on)
    SendNUIMessage({ action = 'callTalk', src = tonumber(src), on = on == true })
end)

-- Standing next to a phone on speaker: this player is in that call too (server/calls.lua) and hears its mutes and
-- its voice disguises.
RegisterNetEvent(RESOURCE .. ':callGuest', function(data)
    if type(data) ~= 'table' then return end
    if data.on then
        guestOf = data.call
        for _, src in ipairs(data.muted or {}) do muteWant[tonumber(src)] = true end
        guestDisguise = {}
        for _, d in ipairs(data.disguise or {}) do
            if tonumber(d.src) then guestDisguise[tonumber(d.src)] = d.kind end
        end
    elseif guestOf == data.call then
        guestOf = nil
        muteWant, guestDisguise = {}, {}
    end
    applyMutes()
    applyDisguises()
    SendNUIMessage({ action = 'callGuest', on = data.on == true })
end)

RegisterNetEvent(RESOURCE .. ':callDisguise', function(src, kind)
    src = tonumber(src)
    if not src or not guestOf then return end
    guestDisguise[src] = type(kind) == 'string' and kind or nil
    applyDisguises()
end)

-- Other players' phones ringing close by: full within 1 m, then falling off fast to nothing at the range (on silent
-- only a buzz within 2 m), following where they go until the ringing stops.
local near = {}

RegisterNetEvent(RESOURCE .. ':ringNear', function(data)
    if type(data) ~= 'table' or not data.src then return end
    local id = data.call .. ':' .. data.src
    if not data.on then
        if near[id] then near[id] = nil end
        SendNUIMessage({ action = 'ringNear', id = id, on = false })
        return
    end
    if near[id] then return end
    near[id] = true
    local range = tonumber(data.range) or 7.0
    CreateThread(function()
        local untilAt, level = GetGameTimer() + (Config.Calls.RingSeconds + 5) * 1000, -1
        while near[id] and GetGameTimer() < untilAt do
            local player = GetPlayerFromServerId(data.src)
            local loud = 0.0
            if player ~= -1 then
                local d = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(player)))
                local reach = data.silent and 2.0 or range
                if d < reach then loud = (1.0 - math.max(0.0, d - 1.0) / (reach - 1.0)) ^ 3 end
            end
            loud = math.floor(loud * 20 + 0.5) / 20
            if loud ~= level then
                level = loud
                SendNUIMessage({ action = 'ringNear', id = id, on = loud > 0, tone = data.tone, silent = data.silent == true, volume = loud })
            end
            Wait(300)
        end
        near[id] = nil
        SendNUIMessage({ action = 'ringNear', id = id, on = false })
    end)
end)

-- Voice disguises for anonymous calls: the other side's voice through a radio effect of its choosing (the game's
-- RadioFX: it hides a voice's colour, not its pitch, which the game's audio cannot shift), so only robot and cassette
-- stay on the live line; the pitched voices are for recorded notes (web/src/lib/recorder.ts). pma-voice puts a call
-- voice through its own call effect whenever it adds one (a member joining, the call's list coming in, a word on the
-- radio), so ours goes back on the next frame after those; nothing is set again in between, as every change starts
-- that voice's audio afresh.
local DISGUISE = {
    robot = { freq_low = 180.0, freq_hi = 4800.0, rm_mod_freq = 52.0, rm_mix = 0.9, fudge = 0.0, o_freq_lo = 150.0, o_freq_hi = 5200.0 },
    tape = { freq_low = 250.0, freq_hi = 3800.0, rm_mod_freq = 0.0, rm_mix = 0.0, fudge = 3.0, o_freq_lo = 300.0, o_freq_hi = 3400.0 },
}
local submix = {}

local function effect(kind)
    if submix[kind] ~= nil then return submix[kind] end
    local p = DISGUISE[kind]
    if not p then return nil end
    local id = CreateAudioSubmix('sp_' .. kind)
    SetAudioSubmixEffectRadioFx(id, 0)
    SetAudioSubmixEffectParamInt(id, 0, GetHashKey('default'), 1)
    for name, value in pairs(p) do SetAudioSubmixEffectParamFloat(id, 0, GetHashKey(name), value) end
    AddAudioSubmixOutput(id, 0)
    submix[kind] = id
    return id
end

local disguised = {} -- src -> kind put on here

applyDisguises = function(again)
    local want = {}
    for _, c in pairs(Call.calls) do
        if c.kind == 'anon' and c.state == 'active' and not c.held then
            for _, m in ipairs(c.members or {}) do
                if m.src and m.disguise and DISGUISE[m.disguise] then want[m.src] = m.disguise end
            end
        end
    end
    for src, kind in pairs(guestDisguise) do
        if DISGUISE[kind] then want[src] = kind end
    end
    for src, kind in pairs(want) do
        if again or disguised[src] ~= kind then
            local id = effect(kind)
            if id then MumbleSetSubmixForServerId(src, id) end
            disguised[src] = kind
        end
    end
    for src in pairs(disguised) do
        if not want[src] then
            MumbleSetSubmixForServerId(src, -1)
            disguised[src] = nil
        end
    end
end

local function reassert()
    if next(disguised) then SetTimeout(0, function() applyDisguises(true) end) end
end
RegisterNetEvent('pma-voice:addPlayerToCall', reassert)
RegisterNetEvent('pma-voice:syncCallData', reassert)
RegisterNetEvent('pma-voice:setTalkingOnRadio', reassert)

-- The call's volume on the voice line (pma-voice), 0-100.
RegisterNUICallback('phone:callVolume', function(data, cb)
    local volume = math.floor(math.max(0, math.min(100, tonumber(data.volume) or 0)))
    local ok = pma() and pcall(function() exports['pma-voice']:setCallVolume(volume) end)
    if ok then hushMuted() end
    cb({ ok = ok == true })
end)

RegisterNUICallback('phone:callVolumeGet', function(_, cb)
    local ok, volume = false, nil
    if pma() then ok, volume = pcall(function() return exports['pma-voice']:getCallVolume() end) end
    cb({ ok = ok, volume = ok and tonumber(volume) or nil })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= RESOURCE then return end
    muteWant, Call.calls, guestDisguise = {}, {}, {}
    applyMutes()
    applyDisguises()
end)
