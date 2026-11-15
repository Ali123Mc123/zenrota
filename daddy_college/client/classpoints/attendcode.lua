-- Attendance code on the client: the tablet's code buttons, the code shown to the room, the student's state while a
-- code is open and, for a student without a phone, the paper card (its key takes the screen to write the code) and
-- /attendcode. The cards themselves are the NUI's (attendcode:*).
if not Core.ModuleEnabled('classpoints') then return end

local cfg = Config.ClassPoints
local key = tonumber((cfg.AttendanceCode or {}).PaperKey) or 246 -- Y
local t = DL.locale.t
local card, focused = nil, false -- card: the open code this student writes on paper ({ sessionId })

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:classpoints:' .. name, false, data))
end

-- The tablet and the paper card ask through these; each answers what the server said.
for _, name in ipairs({ 'codeOpen', 'codeRefresh', 'codeClose', 'codeShow', 'codeStatus', 'submitCode' }) do
    Core.Nui.SafeCallback('classpoints:' .. name, function(data) return call(name, data) end)
end

-- The paper card takes the screen while the code is written; never over a College screen or another resource's focus.
local function focus(on)
    if on == focused then return end
    if on and (Core.Nui.IsOpen() or IsNuiFocused()) then return end
    focused = on
    SetNuiFocus(on, on)
    Core.Nui.Send('attendcode:focus', { on = on })
end

-- The paper card is done (signed, locked out, closed): the key goes back to the game. slip: the slip goes too, when the
-- NUI did not answer for itself.
local function drop(slip)
    if card and slip then Core.Nui.Send('attendcode:state', { sessionId = card.sessionId, open = false }) end
    focus(false)
    card = nil
end

-- While the card is up its key takes the screen (the game does not use the key meanwhile); focus taken away elsewhere
-- (a College screen opened and closed over it) lets the card go small again. A card past its code's end goes by itself,
-- in case the close never came.
local function listen(mine)
    CreateThread(function()
        while card == mine do
            DisableControlAction(0, key, true)
            if GetGameTimer() > mine.untilMs then
                drop(true)
            elseif focused and not IsNuiFocused() then
                focused = false
                Core.Nui.Send('attendcode:focus', { on = false })
            elseif not focused and IsDisabledControlJustPressed(0, key) then
                focus(true)
            end
            Wait(0)
        end
    end)
end

-- The code shown to the room, for its seconds; it never goes into the announcement history.
RegisterNetEvent('daddy_college:attendcode:show', function(payload)
    if type(payload) == 'table' then Core.Nui.Send('attendcode:show', payload) end
end)
RegisterNetEvent('daddy_college:attendcode:hide', function(id) Core.Nui.Send('attendcode:hide', { showId = id }) end)

-- The lesson's code opened, changed or closed, or this student's mark moved (never the code itself). On paper the card
-- stays while the student still has to sign; the phone tells its own owner (daddy_studentphone client/college.lua).
RegisterNetEvent('daddy_college:attendcode:state', function(state)
    if type(state) ~= 'table' then return end
    local pending = state.open == true and (state.status or 'pending') == 'pending'
    local mine = card ~= nil and card.sessionId == state.sessionId
    if pending and (state.paper or mine) then
        if not mine then card = { sessionId = state.sessionId } end
        card.untilMs = GetGameTimer() + ((tonumber(state.left) or 0) + 5) * 1000 -- a few seconds past the code's end
        if not mine then listen(card) end
        state.paper, state.key = true, Core.KeyName(key)
    elseif mine then
        drop()
    end
    if state.open and state.notice then
        if state.paper and state.command then
            Core.NotifyL('attendcode.opened_paper', 'inform', state.lesson or '', Core.KeyName(key), state.command)
        elseif GetResourceState('daddy_studentphone') ~= 'started' then
            Core.NotifyL('attendcode.opened_student', 'inform', state.lesson or '')
        end
    end
    Core.Nui.Send('attendcode:state', state)
end)

-- The card's own buttons: the written code (a wrong one keeps the screen to try again) and putting it aside. Signed or
-- locked out the card is done (the server sends no close for a lock); the slip shows its stamp and goes by itself.
local AGAIN = { attend_wrong = true, attend_wait = true, attend_bad = true }
local DONE = { attend_locked = true, already_signed = true }
Core.Nui.SafeCallback('attendcode:submit', function(data)
    local result = call('submitCode', { code = data.code })
    if result.ok or DONE[result.error] then drop() elseif not AGAIN[result.error] then focus(false) end
    return result
end)

Core.Nui.SafeCallback('attendcode:aside', function()
    focus(false)
    return { ok = true }
end)

-- A reply in a notice: the code's own text first, then the lesson module's.
local function fail(result)
    local text = 'attendcode.' .. tostring(result.error or '')
    if t(text) == text then return Core.HandleResult(result, 'classpoints') end
    Core.Notify(t(text, table.unpack(type(result.args) == 'table' and result.args or {})), 'error')
end

-- /attendcode 4821 hands the code in; /attendcode alone takes up the paper card to write it.
local command = cfg.Commands.code
if command and command ~= '' then
    Core.Command(command, function(args)
        if not args[1] then
            if card then return focus(true) end
            return Core.NotifyL('attendcode.usage', 'inform', command)
        end
        local result = call('submitCode', { code = args[1] })
        if not result.ok then
            if DONE[result.error] then drop(true) end
            return fail(result)
        end
        drop()
        Core.NotifyL(result.status == 'late' and 'attendcode.signed_late' or 'attendcode.signed_present', 'success', result.lesson or '')
    end, 'classpoints')
end

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource and focused then SetNuiFocus(false, false) end
end)
