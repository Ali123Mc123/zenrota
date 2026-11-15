-- The newspaper on the client: the newsroom desk view, the paper reader and the calls both make.
if Config.Modules.press == false or not Config.Press then return end

local cfg = Config.Press
local t = DL.locale.t
local Press = {}
Core.Press = Press

function Press.call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:press:' .. name, false, data or {}))
end

-- Size errors and the like carry their numbers in args.
function Press.fail(result) Core.HandleResult(result, 'press') end

-- Views ----------------------------------------------------------------------------------------------

function Press.openDesk()
    if Core.Nui.IsOpen() then return end
    local result = Press.call('desk')
    if not result.ok then return Press.fail(result) end
    Core.Nui.Open('press.desk', result.data)
    Core.Hold(cfg.Writing)
end

-- From the copy in hand (slot) or a stack close by (stackId).
function Press.openReader(issueId, slot, stackId)
    if Core.Nui.IsOpen() then return end
    local result = Press.call('read', { issueId = issueId, stackId = stackId })
    if not result.ok then return Press.fail(result) end
    result.data.issue.slot = slot
    Core.Nui.Open('press.reader', result.data.issue)
    Core.Hold(cfg.Reading)
end

Core.Nui.OnClose('press.desk', function() Core.Unhold() end)

-- Writers open the newsroom anywhere the server allows writing (the campus by default).
if (cfg.Command or '') ~= '' then
    RegisterCommand(cfg.Command, function() CreateThread(Press.openDesk) end, false)
end
Core.Nui.OnClose('press.reader', function() Core.Unhold() end)

RegisterNetEvent('daddy_college:press:useCopy', function(slot, issueId)
    if issueId then CreateThread(function() Press.openReader(issueId, slot) end) end
end)

-- Desk and reader calls: each goes to the server as it is; errors show the module's text.
for _, name in ipairs({ 'desk', 'article', 'save', 'submit', 'unsubmit', 'delete', 'review', 'compose', 'preview', 'print', 'attachImage', 'removeImage', 'report', 'sendReview', 'recallReview', 'advisors', 'setAdvisor', 'log', 'pressure',
    'correct', 'photos', 'templates', 'saveTemplate', 'deleteTemplate', 'staff', 'setJob', 'setMasthead', 'stats', 'takeCopies', 'handOut' }) do
    Core.Nui.SafeCallback('press:' .. name, function(data)
        local result = Press.call(name, data)
        if not result.ok then Press.fail(result) end
        return result
    end)
end

Core.Nui.SafeCallback('press:take', function(data)
    local result = Press.call('take', { stackId = data.stackId })
    if not result.ok then Press.fail(result) end
    if result.ok then Core.Nui.Close() end
    return result
end)

-- Putting copies down: the view closes, then the copy follows the aim.
local function place(prepare, data)
    local result = Press.call(prepare, data)
    if not result.ok then return Press.fail(result) end
    local info = result.data
    local model = info.model
    if info.fallback and not IsModelInCdimage(joaat(model)) then model = info.fallback end
    local coords, heading = Core.PlaceOnSurface(model, t(prepare == 'prepareDrop' and 'press.place_drop' or 'press.place_stack'), cfg.PlaceDistance)
    if not coords then
        Press.call('cancelPlace', { token = info.token })
        if heading == 'model' then return Core.NotifyL('press.placement_model', 'error') end
        return Core.NotifyL('press.placement_cancelled', 'inform')
    end
    local done = Press.call('confirmPlace', { token = info.token, coords = { x = coords.x, y = coords.y, z = coords.z }, heading = heading })
    if not done.ok then
        Press.call('cancelPlace', { token = info.token })
        Press.fail(done)
    end
end

local function later(prepare, data)
    Core.Nui.Close()
    SetTimeout(200, function() CreateThread(function() place(prepare, data) end) end)
end

Core.Nui.SafeCallback('press:drop', function(data)
    if not tonumber(data.slot) then return { ok = false, error = 'copy_gone' } end
    later('prepareDrop', { slot = data.slot })
    return { ok = true }
end)

Core.Nui.SafeCallback('press:placeStack', function()
    later('prepareStack', {})
    return { ok = true }
end)
