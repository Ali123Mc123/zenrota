-- Client: notices and how a garage is opened.

-- Notices: the garage page's own (page), or your notification script.
do
    local KINDS = { info = 'inform', success = 'success', error = 'error' }

    local NOTIFY = {
        page = function(text, tone) SendNUIMessage({ action = 'garage:notice', text = text, tone = tone }) end,
        ox_lib = function(text, tone) lib.notify({ description = text, type = KINDS[tone] or 'inform' }) end,
        qb = function(text, tone) TriggerEvent('QBCore:Notify', text, tone == 'info' and 'primary' or tone) end,
        esx = function(text) TriggerEvent('esx:showNotification', text) end,
    }

    -- notify(text, 'info' | 'success' | 'error')
    function Bridge.notify(text, tone)
        local fn = NOTIFY[(Config.Bridge or {}).Notify] or NOTIFY.page
        fn(text, tone or 'info')
    end
end

-- Interaction: the built-in prompt (the page draws the hint, E opens), a target on a valet, or ox_lib's text UI.
-- add(garage, actions) where actions = { open = fn, park = fn }; returns a handle for remove(handle).
do
    local function valet(garage)
        local model = joaat(Config.Interact.Ped or 's_m_y_valet_01')
        if not lib.requestModel(model, 5000) then return nil end
        local spot = garage.coords
        local face = garage.spawns[1] and garage.spawns[1].w or 0.0
        pcall(function() exports['FeloxAC']:CreatePed(model) end) --[[FeloxAC:auto]]
        local ped = CreatePed(4, model, spot.x, spot.y, spot.z - 1.0, face, false, false)
        SetModelAsNoLongerNeeded(model)
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_CLIPBOARD', 0, true)
        return ped
    end

    local function options(actions)
        return {
            { name = 'daddy_garages:open', label = Core.t('ui.pr_open'), icon = 'fas fa-warehouse', onSelect = actions.open, action = actions.open },
            { name = 'daddy_garages:park', label = Core.t('ui.pr_park'), icon = 'fas fa-square-parking', onSelect = actions.park, action = actions.park,
              canInteract = function() return cache.vehicle ~= false and cache.vehicle ~= nil end },
        }
    end

    local TARGETS = {
        ox_target = {
            add = function(garage, actions)
                local ped = valet(garage)
                if ped then exports.ox_target:addLocalEntity(ped, options(actions)) end
                return { ped = ped }
            end,
            remove = function(handle)
                if handle.ped then exports.ox_target:removeLocalEntity(handle.ped) DeleteEntity(handle.ped) end
            end,
        },
        ['qb-target'] = {
            add = function(garage, actions)
                local ped = valet(garage)
                if ped then exports['qb-target']:AddTargetEntity(ped, { options = options(actions), distance = 2.5 }) end
                return { ped = ped }
            end,
            remove = function(handle)
                if handle.ped then exports['qb-target']:RemoveTargetEntity(handle.ped) DeleteEntity(handle.ped) end
            end,
        },
    }

    function Bridge.targets()
        return TARGETS[(Config.Bridge or {}).Interact]
    end

    -- The hint while standing in a garage: the page's own, or ox_lib's text UI. nil hides it.
    function Bridge.hint(kind, garage)
        if (Config.Bridge or {}).Interact == 'textui' then
            if kind then lib.showTextUI(('[E] %s'):format(Core.t('ui.pr_' .. kind)))
            else lib.hideTextUI() end
            return
        end
        SendNUIMessage({ action = 'garage:prompt', show = kind ~= nil, kind = kind, garage = garage and garage.label or '' })
    end
end
