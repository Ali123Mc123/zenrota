-- One College view open at a time, with NUI focus taken through daddy_lib.
Core.Nui = {}

local current, failsafe
local closeHooks = {}

-- NUI callback that always answers: errors and slow handlers become { ok = false }.
function Core.Nui.SafeCallback(name, handler, timeoutMs)
    RegisterNUICallback(name, function(data, cb)
        local done = false
        local function finish(result)
            if done then return end
            done = true
            cb(result or { ok = false, error = 'integration_unavailable' })
        end
        SetTimeout(timeoutMs or 12000, function() finish({ ok = false, error = 'timeout' }) end)
        CreateThread(function()
            local ok, result = pcall(handler, type(data) == 'table' and data or {})
            if not ok then print(('^1[daddy_college] %s: %s^7'):format(name, result)) end
            finish(ok and result or { ok = false, error = 'integration_unavailable' })
        end)
    end)
end

function Core.Nui.OnClose(view, fn) closeHooks[view] = fn end

function Core.Nui.Close()
    if not current then return end
    local closing = current
    current, failsafe = nil, nil
    SendNUIMessage({ action = 'close' })
    DL.focus.release()
    if closeHooks[closing] then
        local ok, err = pcall(closeHooks[closing])
        if not ok then print(('^1[daddy_college] close %s: %s^7'):format(closing, err)) end
    end
end

-- opts: focus, cursor, failsafe (false disables the safety close).
function Core.Nui.Open(view, payload, opts)
    opts = opts or {}
    if current then Core.Nui.Close() end
    current = view
    DL.focus.acquire(Core.Nui.Close)
    SetNuiFocus(opts.focus ~= false, opts.cursor ~= false)
    SendNUIMessage({ action = 'open', view = view, payload = payload, locale = DL.locale.table(), language = DL.locale.language(), theme = Config.Theme })
    if opts.failsafe == false then return end
    local token = {}
    failsafe = token
    SetTimeout(opts.failsafe or Config.Tech.NuiFailsafe, function()
        if failsafe == token and current == view then Core.Nui.Close() end
    end)
end

function Core.Nui.Send(action, data) SendNUIMessage({ action = action, data = data }) end

-- Hands focus back to the game for in-world tools, keeping the view.
function Core.Nui.Suspend()
    if not current then return false end
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'suspend' })
    return true
end

function Core.Nui.Resume()
    if not current then return false end
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'resume' })
    return true
end

function Core.Nui.Current() return current end
function Core.Nui.IsOpen(view) return view and current == view or (not view and current ~= nil) end

-- Views that render before any open (announcements) ask for the texts here.
RegisterNUICallback('init', function(_, cb)
    cb({ locale = DL.locale.table(), language = DL.locale.language(), theme = Config.Theme })
end)

RegisterNUICallback('close', function(_, cb)
    cb({ ok = true })
    Core.Nui.Close()
end)

-- The view reports it rendered: the safety close is no longer needed.
RegisterNUICallback('ready', function(data, cb)
    if current and data.view == current then failsafe = nil end
    cb({ ok = true })
end)

RegisterNUICallback('notify', function(data, cb)
    cb({ ok = true })
    Core.Notify(tostring(data.message or ''), data.type)
end)

-- Announcements: lessons arrive in order; the same one is never shown twice.
local lastSequence, seen, order = -1, {}, {}
RegisterNetEvent('daddy_college:announce', function(data)
    if type(data) ~= 'table' then return end
    local id = data.announcementId and tostring(data.announcementId)
    if id and seen[id] then return end
    local sequence = tonumber(data.sequence)
    if data.kind == 'lesson' and sequence then
        if sequence <= lastSequence then return end
        lastSequence = sequence
    end
    if id then
        seen[id] = true
        order[#order + 1] = id
        if #order > 128 then seen[table.remove(order, 1)] = nil end
    end
    if not data.bellOnly then SendNUIMessage({ action = 'announce', data = data }) end
end)

-- [O] opens the announcement history for school members; Escape or O closes it.
local historyOpen = false

local function showHistory(open)
    historyOpen = open
    SetNuiFocus(open, open)
    SetNuiFocusKeepInput(open)
    SendNUIMessage({ action = 'toggleAnnouncementsOverlay', data = { open = open } })
end

RegisterCommand('college_announcements', function()
    if historyOpen then return showHistory(false) end
    if Core.IsSchoolMember() and not current then showHistory(true) end
end, false)
RegisterKeyMapping('college_announcements', DL.locale.t('common.announcements_key'), 'keyboard', 'O')

RegisterNUICallback('closeAnnouncementsOverlay', function(_, cb)
    cb({ ok = true })
    if historyOpen then showHistory(false) end
end)

AddEventHandler('daddy_college:rolesChanged', function()
    if historyOpen and not Core.IsSchoolMember() then showHistory(false) end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if current then Core.Nui.Close() end
    if historyOpen then SetNuiFocusKeepInput(false) end
end)
