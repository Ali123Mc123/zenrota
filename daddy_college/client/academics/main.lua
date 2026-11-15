-- A lesson level reached: the school's paper slip, or ox_lib's notice when the server uses those.
RegisterNetEvent('daddy_college:academics:level', function(data)
    if type(data) ~= 'table' or not data.lesson then return end
    if Config.Ui and Config.Ui.Notifications == 'ox' then return Core.NotifyL('academics.level_up', 'success', data.lesson, data.level) end
    SendNUIMessage({ action = 'academics:level', data = { lesson = data.lesson, level = data.level } })
end)

-- A certificate someone shows: the paper on screen for everyone around.
RegisterNetEvent('daddy_college:certificate:show', function(payload) Core.Nui.Send('certificate:show', payload) end)
RegisterNetEvent('daddy_college:certificate:hide', function(id) Core.Nui.Send('certificate:hide', { showId = id }) end)

-- The class year letter on paper (the server sends it only to a student without a phone): moved up, graduated or corrected.
RegisterNetEvent('daddy_college:academics:letter', function(data)
    if type(data) == 'table' then SendNUIMessage({ action = 'academics:letter', data = data }) end
end)

-- XP just earned in a lesson: a smaller slip of the same paper (or ox_lib's notice).
RegisterNetEvent('daddy_college:academics:xp', function(data)
    if type(data) ~= 'table' or not data.lesson then return end
    if Config.Ui and Config.Ui.Notifications == 'ox' then
        -- A minus (a teacher's change, a discipline sanction) is no gain; a level it moved is told as well.
        local amount = tonumber(data.amount) or 0
        if amount < 0 then Core.NotifyL('discipline.xp.ui.notice_lost', 'error', data.lesson, -amount) else Core.NotifyL('academics.xp_gained', 'success', data.lesson, amount) end
        if data.from and data.to and data.from ~= data.to then Core.NotifyL('discipline.xp.ui.notice_level', data.to < data.from and 'error' or 'success', data.lesson, data.from, data.to) end
        return
    end
    SendNUIMessage({ action = 'academics:xp', data = data })
end)

-- The lesson card: a command and an option at the Student Affairs desk, no tablet needed.
if Config.Modules.academics ~= false and Config.Academics then
    local function openCard()
        local result = lib.callback.await('daddy_college:academics:card', false, {})
        if not result or result.ok == false then return Core.HandleResult(Core.NormalizeResult(result), 'academics') end
        Core.Nui.Open('academics.card', result)
    end
    local commands = Config.Academics.Commands or {}
    if (commands.card or '') ~= '' then Core.Command(commands.card, openCard, 'academics') end
    Core.Affairs.RegisterAction('academics:card', { order = 41, icon = 'fa-solid fa-graduation-cap', label = 'academics.affairs_card',
        visible = function(context) return context.isStudent == true end, run = openCard })
end

-- Client-side 0.00ms O(1) exports backed by LocalPlayer.state['daddy_college:academics']
-- (zero network callbacks, safe to call inside ox_target canInteract or 0ms threads).
local function clientState()
    return LocalPlayer and LocalPlayer.state and LocalPlayer.state['daddy_college:academics'] or nil
end

exports('HasSkill', function(unlockKey)
    if type(unlockKey) ~= 'string' then return false end
    local st = clientState()
    return st ~= nil and st.skills ~= nil and st.skills[unlockKey] == true
end)

exports('MeetsRequirement', function(unlockKey)
    if type(unlockKey) ~= 'string' then return false end
    local st = clientState()
    return st ~= nil and st.skills ~= nil and st.skills[unlockKey] == true
end)

exports('LessonLevel', function(lessonKey)
    if type(lessonKey) ~= 'string' then return 1 end
    local st = clientState()
    return (st and st.levels and st.levels[lessonKey]) or 1
end)
