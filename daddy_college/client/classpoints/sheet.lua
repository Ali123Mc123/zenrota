-- Attendance notebook: the teacher puts it on a desk, students sign next to it.
if not Core.ModuleEnabled('classpoints') then return end

local sheet = Config.ClassPoints.AttendanceSheet
local t = DL.locale.t
if not sheet.Enabled then return end

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:classpoints:' .. name, false, data))
end

-- The teacher puts the notebook on a desk; the server checks the spot.
local function place(sessionId)
    local coords, heading = Core.PlaceOnSurface(sheet.PropModel, t('classpoints.sheet_help'))
    if not coords then
        return Core.NotifyL(heading == 'model' and 'classpoints.model_load_failed' or 'classpoints.placement_cancelled', heading == 'model' and 'error' or 'inform')
    end
    local result = call('placeSheet', { sessionId = sessionId, coords = { x = coords.x, y = coords.y, z = coords.z }, heading = heading })
    if not result.ok then Core.HandleResult(result, 'classpoints') end
end

Core.Nui.SafeCallback('classpoints:startPlaceSheet', function(data)
    local sessionId = tonumber(data.sessionId)
    if not sessionId then return { ok = false, error = 'validation' } end
    Core.Nui.Close()
    SetTimeout(200, function() place(sessionId) end)
    return { ok = true }
end)

Core.Nui.SafeCallback('classpoints:removeSheet', function(data)
    return call('removeSheet', { sessionId = tonumber(data.sessionId) })
end)

-- The Student Phone's Class app puts the notebook down the same way, once its phone is away.
exports('PlaceSheet', function(sessionId)
    sessionId = tonumber(sessionId)
    if not sessionId then return false end
    CreateThread(function() place(sessionId) end)
    return true
end)

local function sign(sessionId)
    if not Core.IsStudent() then return Core.NotifyL('common.not_student', 'error') end
    local done = Core.Progress({
        duration = sheet.SignMs, label = t('classpoints.ui.signing'), kind = 'sign', canCancel = true,
        disable = { car = true, move = true, combat = true },
        anim = { dict = 'missheistdockssetup1clipboard@base', clip = 'base', flag = 49 },
        prop = { model = `p_cs_clipboard`, bone = 18905, pos = vec3(0.10, 0.02, 0.08), rot = vec3(-80.0, 0.0, 0.0) },
    })
    if not done then return end
    local result = call('signSheet', { sessionId = sessionId })
    if not result.ok then Core.HandleResult(result, 'classpoints') end
end

-- Notebooks of running lessons stream as props with a sign option.
local function sync(list)
    local defs = {}
    for _, s in ipairs(type(list) == 'table' and list or {}) do
        defs[#defs + 1] = {
            uid = s.uid, label = t('classpoints.sign_option_fmt', s.lesson), presentation = 'prop', model = sheet.PropModel,
            coords = { x = s.coords.x, y = s.coords.y, z = s.coords.z, w = s.heading }, streamDistance = 40.0, distance = 2.0,
            options = { { name = 'sign_attendance', label = t('classpoints.sign_option_fmt', s.lesson), icon = 'fas fa-pen-nib', distance = 2.0,
                onSelect = function() sign(s.sessionId) end } },
        }
    end
    Core.World.anchors.sync('classpoints_sheet', defs)
end

RegisterNetEvent('daddy_college:classpoints:sheets', sync)
Core.OnLogin(function() sync(lib.callback.await('daddy_college:classpoints:getSheets', false)) end)
