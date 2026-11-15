-- The scholarship press on the client: machines at their spots, the desk option and the press view.
-- The view only plays the result; the server wrote it before the lever came down.
if not Core.ModuleEnabled('scholarship') then return end

local cfg = Config.Scholarship
local t = DL.locale.t
local VIEW = 'scholarship.wheel'
local mode = cfg.TriggerMode
local finished = false

local function call(name) return Core.NormalizeResult(lib.callback.await('daddy_college:scholarship:' .. name, false)) end

-- The press times, in the names the view reads.
local function timings(look)
    look = type(look) == 'table' and look or cfg.Presentation
    return { cardInsertMs = look.CardInsertMs, leverMs = look.LeverMs, drumMs = look.DrumMs, printerMs = look.PrinterMs,
        stampMs = look.StampMs, soundVolume = look.SoundVolume }
end

local function show(card, viewMode)
    Core.Nui.Open(VIEW, {
        mode = viewMode, slices = card.slices, percent = card.percent, studentName = card.studentName,
        studentRef = card.studentRef, allocationRef = card.allocationRef, presentation = timings(card.presentation),
    })
end

local function open()
    if Core.Nui.IsOpen() then return end
    local result = call('session')
    if result.error == 'already_spun' then return Core.NotifyL('scholarship.already_spun', 'error', result.percent, result.remainingDays) end
    if result.error == 'scholarship_by_levels' then return Core.NotifyL('scholarship.by_levels', 'inform', result.percent) end
    if not result.ok then return Core.HandleResult(result, 'scholarship') end
    finished = false
    show(result, result.mode)
end

Core.Nui.OnClose(VIEW, function() finished = false end)

RegisterNetEvent('daddy_college:scholarship:open', function() CreateThread(open) end)

RegisterNetEvent('daddy_college:scholarship:certificate', function(card)
    if type(card) ~= 'table' or Core.Nui.IsOpen() then return end
    finished = true
    show(card, 'view')
end)

Core.Nui.SafeCallback('scholarship:spin', function() return call('spin') end)

Core.Nui.SafeCallback('scholarship:animDone', function()
    finished = true
    return { ok = true }
end)

-- The press cannot be closed while it works.
Core.Nui.SafeCallback('scholarship:close', function()
    if finished then Core.Nui.Close() end
    return { ok = true }
end)

-- A refused spin never starts the animation, so it may close at once.
Core.Nui.SafeCallback('scholarship:spinFailed', function()
    finished = true
    Core.NotifyL('scholarship.wheel_error', 'error')
    return { ok = true }
end)

-- At Student Affairs, when students spin at the desk.
Core.Affairs.RegisterAction('scholarship:apply', { order = 50, icon = 'fa-solid fa-graduation-cap', label = 'scholarship.target_apply',
    visible = function(context) return mode == 'desk' and context.isStudent end,
    run = open })

-- Machines ---------------------------------------------------------------------------------------------

local function syncMachines()
    local defs = {}
    if mode == 'machine' then
        for _, machine in ipairs(Core.World.entities({ kind = 'scholarship_machine' })) do
            defs[#defs + 1] = {
                uid = 'scholarship:' .. machine.uid, label = machine.label, coords = machine.coords, revision = machine.revision,
                presentation = 'prop', model = (machine.model or '') ~= '' and machine.model or cfg.MachineModel,
                streamDistance = machine.streamDistance, distance = machine.interactDistance or cfg.MachineDistance,
                options = { {
                    name = 'scholarship_apply', label = t('scholarship.target_apply'), icon = 'fa-solid fa-graduation-cap', distance = machine.interactDistance or cfg.MachineDistance,
                    canInteract = function() return not Core.Nui.IsOpen() end,
                    onSelect = function() CreateThread(open) end,
                } },
            }
        end
    end
    Core.World.anchors.sync('scholarship', defs)
end

-- The admin panel may change how students spin.
local function refreshMode()
    local result = call('mode')
    if result.ok and result.mode then mode = result.mode end
    syncMachines()
end

Core.World.subscribe(function(_, message)
    if message.topic == 'bootstrap' or message.topic == 'settings:scholarship' then return CreateThread(refreshMode) end
    syncMachines()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then Core.World.anchors.clear('scholarship') end
end)
