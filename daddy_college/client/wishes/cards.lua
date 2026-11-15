-- Hanging and reading wish cards: the tree's two options, the card written on screen and hung with a reach, and the
-- tree's gallery where every card is read, "me too"d, reported or marked come true. The server checks every step.
if not WishClient then return end

local cfg = Config.Wishes
local t = DL.locale.t
local call = WishClient.call

local function fail(result) Core.HandleResult(result, 'wishes') end

local function play(anim)
    if not anim or not pcall(lib.requestAnimDict, anim.Dict, 2500) then return end
    TaskPlayAnim(cache.ped, anim.Dict, anim.Name, 3.0, 3.0, anim.Ms or 1800, 48, 0.0, false, false, false)
    Wait(anim.Ms or 1800)
    StopAnimTask(cache.ped, anim.Dict, anim.Name, 2.0)
    RemoveAnimDict(anim.Dict)
end

-- Hanging -------------------------------------------------------------------------------------------------

local function write(spot)
    local result = call('canHang', { uid = spot.uid })
    if not result.ok then return fail(result) end
    Core.Nui.Open('wishes.card', {
        mode = 'write', tree = spot.uid, colors = cfg.Colors, allowDrawing = cfg.AllowDrawing,
        limits = { maxChars = cfg.MaxChars }, tools = { colors = Config.Notes.InkColors, widths = Config.Notes.PenWidths },
    })
end

Core.Nui.SafeCallback('wishes:hang', function(data)
    local result = call('hang', { uid = data.tree, content = data.content, color = data.color })
    if not result.ok then
        fail(result)
        return result
    end
    CreateThread(function()
        Wait(150)
        if result.pending then return Core.NotifyL('wishes.pending', 'inform') end
        local feet = GetEntityCoords(cache.ped).z - 1.0
        play(result.z and result.z - feet > (cfg.Hang.HighAbove or 1.5) and cfg.Hang.High or cfg.Hang.Low)
        Core.NotifyL('wishes.hung', 'success')
    end)
    return result
end)

-- The gallery ---------------------------------------------------------------------------------------------

local function browse(spot)
    local result = call('browse', { uid = spot.uid })
    if not result.ok then return fail(result) end
    result.label = (result.label or '') ~= '' and result.label or nil
    Core.Nui.Open('wishes.tree', result)
end

-- "Hang a wish" from the gallery: the gallery closes and the card opens.
Core.Nui.SafeCallback('wishes:write', function(data)
    local spot = WishClient.trees[data.tree]
    if spot then CreateThread(function() Wait(120) write(spot) end) end
    return { ok = spot ~= nil }
end)

for _, name in ipairs({ 'metoo', 'fulfil', 'report', 'remove' }) do
    Core.Nui.SafeCallback('wishes:' .. name, function(data)
        local result = call(name, { id = tonumber(data.id) })
        if not result.ok then fail(result) end
        return result
    end)
end

-- The tree's options ------------------------------------------------------------------------------------

function WishClient.options(spot)
    local reach = cfg.TargetDistance or 2.5
    return {
        { name = 'wish_hang', label = t('wishes.target_hang'), icon = 'fa-solid fa-feather', distance = reach,
            onSelect = function() CreateThread(function() write(spot) end) end },
        { name = 'wish_browse', label = t('wishes.target_browse'), icon = 'fa-solid fa-eye', distance = reach,
            onSelect = function() CreateThread(function() browse(spot) end) end },
    }
end

WishClient.sync()
