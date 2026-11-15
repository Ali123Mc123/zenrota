-- Parts counter, stash and kits.

local function isStaff(shop)
    local job = Bridge.job()
    return job and job.name == shop.job and job.duty
end

local function partsMenu(shopId, shop)
    local options = {}
    for i, part in ipairs(shop.parts.items) do
        options[#options + 1] = {
            title = Core.t('items.' .. part.name), description = ('$%d'):format(part.price), icon = 'box',
            onSelect = function()
                local input = lib.inputDialog(Core.t('items.' .. part.name), {
                    { type = 'number', label = Core.t('ui.count'), required = true, default = 1, min = 1, max = 50 },
                })
                if not input then return end
                local ok, result = lib.callback.await('daddy_mechanic:buyPart', false, shopId, i, input[1])
                Bridge.notify(nil, ok and Core.t('msg.paid', result) or result or Core.t('msg.failed'), ok and 'success' or 'error')
            end,
        }
    end
    lib.registerContext({ id = 'daddy_mechanic:parts', title = Core.t('ui.parts'), options = options })
    lib.showContext('daddy_mechanic:parts')
end

CreateThread(function()
    for shopId, shop in pairs(Config.Shops) do
        local staff = function() return isStaff(shop) end
        if shop.parts then
            Bridge.spot('daddy_mechanic:parts:' .. shopId, shop.parts.coords, {
                { label = Core.t('ui.parts'), icon = 'fas fa-box', canInteract = staff, onSelect = function() partsMenu(shopId, shop) end },
            })
        end
        for i, stash in ipairs(Core.stashes(shopId, shop)) do
            Bridge.spot(('daddy_mechanic:stash:%s:%d'):format(shopId, i), stash.coords, {
                { label = stash.label or Core.t('ui.stash'), icon = 'fas fa-warehouse', canInteract = staff, onSelect = function()
                    local id = lib.callback.await('daddy_mechanic:openStash', false, shopId, i)
                    if id then Bridge.openStash(id) end
                end },
            })
        end
    end
end)

local function skillKit()
    lib.requestAnimDict('mini@repair')
    TaskPlayAnim(cache.ped, 'mini@repair', 'fixing_a_ped', 3.0, 3.0, -1, 1, 0, false, false, false)
    local result = Install.check()
    ClearPedTasks(cache.ped)
    return result
end

RegisterNetEvent('daddy_mechanic:useKit', function(item)
    if cache.vehicle then return Bridge.notify(nil, Core.t('msg.get_out'), 'error') end
    local vehicle = lib.getClosestVehicle(GetEntityCoords(cache.ped), 4.0, false)
    if not vehicle then return Bridge.notify(nil, Core.t('msg.no_car_near'), 'error') end
    local ok, seconds = lib.callback.await('daddy_mechanic:kitStart', false, item, VehToNet(vehicle))
    if not ok then return end
    TaskTurnPedToFaceEntity(cache.ped, vehicle, 1000)
    if Config.Kits[item].skill and Config.Install.SkillCheck then
        Wait(1000)
        local result = skillKit()
        if result == false and lib.callback.await('daddy_mechanic:kitBreak', false) then
            return Bridge.notify(nil, Core.t('msg.part_broke'), 'error')
        end
        if not result then return end
        local finished, why = lib.callback.await('daddy_mechanic:kitFinish', false)
        if not finished then Bridge.notify(nil, why or Core.t('msg.failed'), 'error') end
        return
    end
    local done = lib.progressBar({
        duration = seconds * 1000,
        label = Core.t('items.' .. item),
        canCancel = true,
        disable = { move = true, car = true, combat = true },
        anim = { scenario = item == 'cleaning_kit' and 'WORLD_HUMAN_MAID_CLEAN' or 'PROP_HUMAN_BUM_BIN' },
    })
    if not done then return end
    local finished, why = lib.callback.await('daddy_mechanic:kitFinish', false)
    if not finished then Bridge.notify(nil, why or Core.t('msg.failed'), 'error') end
end)
