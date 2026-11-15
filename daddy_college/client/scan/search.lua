-- Searching on the client: security's search command on a player, the take and sanction buttons of the scan screen,
-- and claiming kept things back at Student Affairs. The server decides who may be searched and what is taken.
if not Core.ModuleEnabled('scan') or not Core.ModuleEnabled('security') or not Config.Scan then return end

local t = DL.locale.t

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:scan:' .. name, false, data))
end

local function search(target)
    if not target then return end
    if not Core.Progress({ duration = 3000, label = t('scan.progress_search'), canCancel = true, disable = { move = true, combat = true, car = true },
        anim = { dict = 'anim@gangops@facility@servers@bodysearch@', clip = 'player_search', flag = 49 } }) then return end
    local result = call('search', { target = target })
    if not result.ok then return Core.HandleResult(result, 'scan') end
    if Core.Nui.IsOpen() then Core.Nui.Close() end
    Core.Nui.Open('scan.sheet', result.sheet)
end

-- /ustara [id]: the id typed or the nearest player (no option on players).
Core.Command(Config.Security.PlayerCommands.search, function(args)
    if not Core.IsSecurity() then return Core.NotifyL('common.no_permission', 'error') end
    search(Core.CommandTarget(args, Config.Security.CommandReach))
end)

-- The scan screen's buttons: a sheet comes back with what is left.
Core.Nui.SafeCallback('scan:take', function(data)
    local result = call('take', { target = data.target, item = data.item, slot = data.slot })
    if not result.ok then
        Core.HandleResult(result, 'scan')
        return result
    end
    Core.NotifyL('scan.taken', 'success')
    return { ok = true, data = result.sheet }
end)

Core.Nui.SafeCallback('scan:propose', function(data)
    local result = call('propose', { scan = data.scan })
    if not result.ok then
        Core.HandleResult(result, 'scan')
        return result
    end
    Core.NotifyL('scan.proposed', 'success')
    return { ok = true }
end)

-- Student Affairs: kept things whose day has come go back.
Core.Affairs.RegisterAction('scan:claim', { order = 47, icon = 'fa-solid fa-box-archive', label = 'scan.affairs_claim',
    visible = function(context) return Config.Scan.Confiscate.Enabled ~= false and context.isStudent == true end,
    run = function()
        local result = call('claim')
        if not result.ok then return Core.HandleResult(result, 'scan') end
        local r = result.result
        if r.returned > 0 then Core.NotifyL('scan.claim_returned', 'success', r.returned) end
        if r.waiting > 0 then Core.NotifyL('scan.claim_waiting', 'inform', r.waiting, r.days or 1) end
        if r.kept > 0 then Core.NotifyL('scan.claim_kept', 'warning', r.kept) end
        if r.returned + r.waiting + r.kept == 0 then Core.NotifyL('scan.claim_none', 'inform') end
    end,
})

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then DL.target.remove('scan_search') end
end)
