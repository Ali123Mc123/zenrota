-- Board controls for the teacher: call a student up, open the board to the class, take the chalk back, clear.
-- The menu only offers; the server checks every choice again.
BoardClassroom = {}

local RESOURCE = GetCurrentResourceName()
local MENU = RESOURCE .. ':classroom'
local t = DL.locale.t

local function call(action, uid, data, notify)
    data = data or {}
    data.uid = uid
    local result = lib.callback.await(RESOURCE .. ':classroom', false, action, data)
    if type(result) ~= 'table' or not result.ok then
        notify(type(result) == 'table' and result.error or 'generic')
        return nil
    end
    return result.data
end

local function say(key, kind, ...)
    lib.notify({ description = t(key, ...), type = kind or 'success' })
end

local function confirm(text)
    return lib.alertDialog({ header = t('admin.confirm'), content = text, centered = true, cancel = true }) == 'confirm'
end

local function pick(item, notify)
    local list = call('candidates', item.uid, nil, notify)
    if not list then return end
    if #list == 0 then return say('classroom.nobody', 'inform') end
    local options = {}
    for _, entry in ipairs(list) do
        options[#options + 1] = {
            title = entry.name, icon = 'user',
            onSelect = function()
                local done = call('callup', item.uid, { target = entry.id }, notify)
                if done then say('classroom.called', 'success', done.name, done.minutes) end
            end,
        }
    end
    lib.registerContext({ id = MENU .. ':pick', title = t('classroom.pick_title'), menu = MENU, options = options })
    lib.showContext(MENU .. ':pick')
end

local function names(list)
    local out = {}
    for _, entry in ipairs(list) do out[#out + 1] = t('classroom.at_board', entry.name, entry.minutes) end
    return table.concat(out, ', ')
end

function BoardClassroom.open(item, notify)
    local state = call('state', item.uid, nil, notify)
    if not state then return end
    local options = {}
    if state.lesson then
        options[#options + 1] = { title = t('classroom.lesson', state.lesson), description = state.teacher and t('classroom.teacher', state.teacher), icon = 'book-open', disabled = true }
    end
    if state.painter then
        options[#options + 1] = { title = t('classroom.painter', state.painter), icon = 'pen', disabled = true }
    end
    options[#options + 1] = {
        title = t('classroom.call_up'), description = t('classroom.call_up_help', state.minutes), icon = 'hand', arrow = true,
        onSelect = function() pick(item, notify) end,
    }
    if state.canOpen then
        options[#options + 1] = {
            title = state.open and t('classroom.close_class') or t('classroom.open_class'),
            description = not state.open and t('classroom.open_help') or nil, icon = state.open and 'lock' or 'users',
            onSelect = function()
                local done = call('open', item.uid, { on = not state.open }, notify)
                if done then say(done.open and 'classroom.opened' or 'classroom.closed', 'inform') end
            end,
        }
    end
    if #state.callups > 0 or state.open or state.student then
        options[#options + 1] = {
            title = t('classroom.take_back'), description = #state.callups > 0 and names(state.callups) or t('classroom.take_back_help'),
            icon = 'hand-back-fist',
            onSelect = function()
                if call('takeback', item.uid, nil, notify) then say('classroom.taken_back') end
            end,
        }
    end
    options[#options + 1] = {
        title = t('classroom.clear'), icon = 'eraser', disabled = state.strokes == 0,
        onSelect = function()
            if confirm(t('classroom.clear_confirm', state.label)) and call('clear', item.uid, nil, notify) then say('classroom.cleared') end
        end,
    }
    if state.snapshot then
        options[#options + 1] = {
            title = t('classroom.restore'), description = t('classroom.restore_help', state.snapshot.strokes, state.snapshot.minutes),
            icon = 'clock-rotate-left',
            onSelect = function()
                if call('restore', item.uid, nil, notify) then say('classroom.restored') end
            end,
        }
    end
    lib.registerContext({ id = MENU, title = state.room and t('classroom.title', state.label, state.room) or state.label, options = options })
    lib.showContext(MENU)
end
