-- Supplier crates: one waits at the delivery point of a place, a worker picks it up (E), carries it and puts it into the storage (E there).
local crates, carried = {}, nil

local function forget(id)
    local crate = crates[id]
    if not crate then return end
    if crate.point then crate.point:remove() end
    if crate.touch then crate.touch.remove() end
    if crate.entity and DoesEntityExist(crate.entity) then DeleteEntity(crate.entity) end
    crates[id] = nil
end

local function set(list)
    local keep = {}
    for _, data in ipairs(list or {}) do keep[data.id] = data end
    for id in pairs(crates) do
        if not keep[id] then forget(id) end
    end
    for id, data in pairs(keep) do
        if not crates[id] then
            local crate = { data = data }
            crates[id] = crate
            local at = vec3(data.x, data.y, data.z)
            crate.point = lib.points.new({
                coords = at, distance = 40.0,
                onEnter = function()
                    crate.inside = true
                    local hash = joaat('prop_cs_cardbox_01')
                    if crate.entity or crate.loading or not IsModelInCdimage(hash) then return end
                    -- loaded in its own thread, the points loop of ox_lib must not wait for a model
                    crate.loading = true
                    CreateThread(function()
                        local ok = pcall(lib.requestModel, hash, 5000)
                        crate.loading = false
                        if not ok or not crate.inside or crate.entity or crates[id] ~= crate then return end
                        pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
                        crate.entity = CreateObject(hash, at.x, at.y, at.z, false, false, false)
                        PlaceObjectOnGroundProperly(crate.entity)
                        FreezeEntityPosition(crate.entity, true)
                        SetModelAsNoLongerNeeded(hash)
                    end)
                end,
                onExit = function()
                    crate.inside = false
                    if crate.entity and DoesEntityExist(crate.entity) then DeleteEntity(crate.entity) end
                    crate.entity = nil
                end,
            })
            crate.touch = Venue.Interact.add({
                coords = at, label = L('crate_label'), icon = 'fa-box', distance = 2.0,
                canInteract = function() return not carried end,
                onSelect = function() if not carried then TriggerServerEvent('daddy_venue:crateTake', id) end end,
            })
        end
    end
end

local function drop()
    if carried and DoesEntityExist(carried) then DeleteEntity(carried) end
    carried = nil
    ClearPedTasks(cache.ped)
end

RegisterNetEvent('daddy_venue:crates', set)

RegisterNetEvent('daddy_venue:crateCarry', function(state)
    if not state then return drop() end
    if carried then return end
    local hash = joaat('prop_cs_cardbox_01')
    if not IsModelInCdimage(hash) then return end
    lib.requestModel(hash, 5000)
    lib.requestAnimDict('anim@heists@box_carry@')
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    carried = CreateObject(hash, 0.0, 0.0, 0.0, false, false, false)
    SetModelAsNoLongerNeeded(hash)
    AttachEntityToEntity(carried, cache.ped, GetPedBoneIndex(cache.ped, 60309), 0.025, 0.08, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)
    TaskPlayAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 8.0, -8.0, -1, 49, 0, false, false, false)
    lib.notify({ type = 'inform', description = L('crate_carry') })
    CreateThread(function()
        while carried do
            -- dead or knocked over: the box falls (the server still holds the crate, it goes into the stock by itself later)
            if IsEntityDead(cache.ped) or IsPedRagdoll(cache.ped) then
                drop()
                break
            end
            DisableControlAction(0, 21, true)
            DisableControlAction(0, 22, true)
            if not IsEntityPlayingAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 3) then
                TaskPlayAnim(cache.ped, 'anim@heists@box_carry@', 'idle', 8.0, -8.0, -1, 49, 0, false, false, false)
            end
            Wait(0)
        end
    end)
end)

CreateThread(function()
    set(lib.callback.await('daddy_venue:crates', false))
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for id in pairs(crates) do forget(id) end
    drop()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', drop)
RegisterNetEvent('esx:onPlayerLogout', drop)
