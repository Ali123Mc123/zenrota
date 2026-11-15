-- Workbenches placed with /collegeadmin: a prop with [E], the recipe list (a locked one says the lesson and level that
-- opens it) and a progress bar while making.
local cfg = Config.Workbenches
if not cfg or cfg.Enabled == false then return end

local t = DL.locale.t
local busy = false

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:workbench:' .. name, false, data or {}))
end

local function make(uid, recipe)
    if busy then return end
    busy = true
    local begun = call('start', { uid = uid, recipe = recipe.id })
    if not begun.ok then
        busy = false
        if begun.error == 'locked' and begun.text then return Core.Notify(begun.text, 'error') end
        return Core.HandleResult(begun, 'workbench')
    end
    local anim = begun.anim or cfg.Anim
    local done = Core.Progress({
        duration = begun.time or recipe.time, label = t('workbench.progress', recipe.label), canCancel = true,
        disable = { move = true, car = true, combat = true }, anim = { dict = anim.dict, clip = anim.clip, flag = 1 },
    })
    ClearPedTasks(cache.ped)
    if not done then
        call('cancel')
        busy = false
        return
    end
    local result = call('finish')
    busy = false
    if not result.ok then return Core.HandleResult(result, 'workbench') end
    Core.NotifyL('workbench.made', 'success', result.count or 1, result.label or recipe.label)
end

local function open(uid)
    local result = call('list', { uid = uid })
    if not result.ok then return Core.HandleResult(result, 'workbench') end
    local options = {}
    for _, recipe in ipairs(result.recipes or {}) do
        local parts = {}
        for _, need in ipairs(recipe.materials) do
            parts[#parts + 1] = t('workbench.material', need.label, need.have, need.count)
        end
        local description = table.concat(parts, '\n')
        if recipe.locked then description = recipe.lockText .. '\n' .. description end
        options[#options + 1] = {
            title = t('workbench.recipe', recipe.count, recipe.label),
            description = description,
            icon = recipe.locked and 'lock' or 'hammer',
            disabled = recipe.locked or not recipe.ready,
            onSelect = function() CreateThread(function() make(uid, recipe) end) end,
        }
    end
    if #options == 0 then options[1] = { title = t('workbench.empty'), disabled = true } end
    lib.registerContext({ id = 'daddy_college_workbench', title = t('workbench.title'), options = options })
    lib.showContext('daddy_college_workbench')
end

local function benches()
    local defs = {}
    for kind, settings in pairs(cfg.Kinds) do
        for _, spot in ipairs(Core.World.entities({ kind = kind })) do
            local reach = spot.interactDistance or cfg.Reach
            defs[#defs + 1] = {
                uid = 'workbench:' .. spot.uid, label = spot.label, coords = spot.coords, revision = spot.revision, presentation = 'prop',
                model = (spot.model or '') ~= '' and spot.model or settings.Model, streamDistance = spot.streamDistance, distance = reach,
                options = { {
                    name = 'workbench_open', label = t('workbench.target'), icon = 'fa-solid fa-screwdriver-wrench', distance = reach,
                    canInteract = function() return not busy and not Core.Nui.IsOpen() end,
                    onSelect = function() CreateThread(function() open(spot.uid) end) end,
                } },
            }
        end
    end
    Core.World.anchors.sync('workbench', defs)
end

Core.World.subscribe(benches)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    Core.World.anchors.clear('workbench')
end)
