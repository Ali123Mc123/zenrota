-- The lesson quiz on paper, for students without a phone (the server says who): the question slip in the corner for
-- the one asked, a small note "asked to ..." with the countdown for the rest. Keys 1-4 answer choices without the
-- mouse; a short answer or an activity waits until 1 is pressed, then takes the screen while it is written or played.
if Config.Modules.lessonquiz == false or not Config.LessonQuiz then return end

local cfg = Config.LessonQuiz
local card, focused, shownRun = nil, false, nil

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:lessonquiz:' .. name, false, data or {}))
end

local function focus(on)
    if on == focused then return end
    if on and Core.Nui.IsOpen() then return end -- another College view has the screen
    focused = on
    SetNuiFocus(on, on)
    Core.Nui.Send('quiz:focus', { on = on })
end

local function send(answer)
    if not card or card.sent then return end
    local result = call('answer', { roundId = card.roundId, answer = answer })
    if not result.ok then return Core.HandleResult(result, 'lessonquiz') end
    card.sent = true
    focus(false)
    Core.Nui.Send('quiz:sent', { roundId = card.roundId, answer = answer })
end

-- While the slip is up: 1-4 pick a choice, or 1 starts writing or playing; those keys do not change weapons meanwhile.
local function listen(mine)
    CreateThread(function()
        while card == mine and not mine.sent do
            for i, control in ipairs(cfg.PaperKeys) do
                DisableControlAction(0, control, true)
                if IsDisabledControlJustPressed(0, control) then
                    if mine.keys and i <= mine.count then
                        if mine.kind == 'bool' then send(i == 1) else send(i) end
                    elseif not mine.keys and i == 1 and not focused then
                        focus(true)
                    end
                end
            end
            Wait(0)
        end
    end)
end

local function show(round)
    card = { roundId = round.roundId, kind = round.kind, count = round.kind == 'bool' and 2 or #(round.choices or {}),
        keys = round.kind == 'single' or round.kind == 'bool' }
    shownRun = round.runId
    round.keys, round.key = card.keys, Core.KeyName(cfg.PaperKeys[1])
    Core.Nui.Send('quiz:open', round)
    if round.world then return end -- played at a station, the slip only says where
    listen(card)
end

-- The note for a question asked to someone else: no keys are listened to.
local function note(p)
    shownRun = p.runId
    Core.Nui.Send('quiz:asked', p)
end

RegisterNetEvent('daddy_college:lessonquiz:round', function(p)
    if type(p) ~= 'table' then return end
    if p.state == 'open' then
        if p.paper then show(p) end
    elseif p.state == 'asked' then
        if p.paper then note(p) end
    elseif p.state == 'world' then
        if shownRun == p.runId then Core.Nui.Send('quiz:world', p) end
    elseif p.state == 'extend' then
        Core.Nui.Send('quiz:extend', p)
    elseif p.state == 'result' then
        -- The asked student's slip closes on its result; the others' note turns into it.
        if card and card.roundId == p.roundId then
            focus(false)
            card = nil
        end
        if shownRun == p.runId then Core.Nui.Send('quiz:result', p) end
    elseif p.state == 'cancelled' then
        if card then
            focus(false)
            card = nil
        end
        if shownRun == p.runId then Core.Nui.Send('quiz:cancelled', p) end
    elseif p.state == 'ended' then
        if shownRun == p.runId then Core.Nui.Send('quiz:ended', p) end
    end
end)

-- The slip's own buttons: a typed answer, a picked choice, a finished activity, and putting it aside.
Core.Nui.SafeCallback('lessonquiz:answer', function(data)
    send(data.answer)
    return { ok = true }
end)

Core.Nui.SafeCallback('lessonquiz:activityDone', function(data)
    local result = call('activityDone', data)
    if not result.ok then Core.HandleResult(result, 'lessonquiz') end
    if card then card.sent = true end
    focus(false)
    return result
end)

Core.Nui.SafeCallback('lessonquiz:aside', function()
    focus(false)
    return { ok = true }
end)

-- /quiz brings the open question back on paper (also for a student who has a phone): the slip to the one asked, the
-- note "asked to ..." to the rest.
Core.Command(cfg.Commands.quiz, function()
    local result = call('current')
    local round = result.ok and result.round
    if not round or round.answered then return Core.NotifyL('lessonquiz.quiz_none', 'inform') end
    if round.state == 'asked' then return note(round) end
    if round.state ~= 'open' then return Core.NotifyL('lessonquiz.quiz_none', 'inform') end
    if not (card and card.roundId == round.roundId) then show(round) end
    if not card.keys and not card.sent and not round.world then focus(true) end
end, 'lessonquiz')

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource and focused then SetNuiFocus(false, false) end
end)
