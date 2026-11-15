-- The management desk: E there (for the dealership's job) opens the page's desk; its buttons call the server, which
-- answers with the desk's fresh state. And placing a display car: chosen in the showroom (V), it follows the player
-- until E puts it down (left / right turn it, Backspace gives up).
Manage = {}

function Manage.open(id)
    local res = lib.callback.await('daddy_dealerships:manage', false, id)
    if not res or not res.ok then return Page.notice('msg.' .. (res and res.error or 'failed'), 'error') end
    Panel.open('dealer:manage', res.state)
end

local function call(name, ...)
    local res = lib.callback.await('daddy_dealerships:manage' .. name, false, ...)
    return res or { ok = false, error = 'failed' }
end

Page.on('dealer:manage:money', function(d) return call(':money', d.dealer, d.kind, tonumber(d.amount)) end)
Page.on('dealer:manage:order', function(d) return call(':order', d.dealer, d.model, tonumber(d.count)) end)
Page.on('dealer:manage:price', function(d) return call(':price', d.dealer, d.model, tonumber(d.price)) end)
Page.on('dealer:manage:display', function(d) return call(':display:remove', d.dealer, tonumber(d.id)) end)
Page.on('dealer:manage:coupon', function(d) return call(':coupon', d.dealer, d.action, d.data) end)
Page.on('dealer:manage:campaign', function(d) return call(':campaign', d.dealer, d.action, d.data) end)
Page.on('dealer:manage:staff', function(d) return call(':staff', d.dealer, d.action, d.target, tonumber(d.grade)) end)
Page.on('dealer:manage:settings', function(d) return call(':settings', d.dealer, d.field, d.value) end)

-- A job offered at a dealership's desk: the page's offer card; E held accepts, X declines.
RegisterNetEvent('daddy_dealerships:job:offer', function(card)
    Ask.hold(card, function(yes) TriggerServerEvent('daddy_dealerships:job:answer', yes) end)
end)

-- Placing a display car -------------------------------------------------------------------------------------------------

local placing, ghostVeh

local function place(dealerId, model, colour, rgb)
    local hash = joaat(model)
    if not pcall(lib.requestModel, hash, 5000) then return end
    local ped = PlayerPedId()
    local from = GetEntityCoords(ped)
    pcall(function() exports['FeloxAC']:CreateVehicle(hash) end) --[[FeloxAC:auto]]
    local ghost = CreateVehicle(hash, from.x, from.y, from.z, GetEntityHeading(ped), false, false)
    ghostVeh = ghost
    SetModelAsNoLongerNeeded(hash)
    SetEntityCollision(ghost, false, false)
    SetEntityAlpha(ghost, 200, false)
    FreezeEntityPosition(ghost, true)
    local paint = Config.Colours[colour or 0]
    if type(rgb) == 'table' and #rgb == 3 then
        SetVehicleCustomPrimaryColour(ghost, rgb[1], rgb[2], rgb[3])
        SetVehicleCustomSecondaryColour(ghost, rgb[1], rgb[2], rgb[3])
    elseif paint then
        SetVehicleColours(ghost, paint.index, paint.index)
    end
    local r, g, b = GetVehicleColor(ghost)
    local name = GetLabelText(GetDisplayNameFromVehicleModel(hash))
    Bridge.hint({ label = name ~= 'NULL' and name or model, sub = Core.t('ui.place_keys'), verb = 'ui.place' })
    local turn = GetEntityHeading(ped) + 90.0
    placing = true
    while placing do
        local at = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 4.0, 0.0)
        local found, ground = GetGroundZFor_3dCoord(at.x, at.y, at.z + 2.0, false)
        local min = GetModelDimensions(hash)
        SetEntityCoordsNoOffset(ghost, at.x, at.y, (found and ground or at.z) - min.z, false, false, false)
        if IsControlPressed(0, 174) then turn = turn + 1.5 end
        if IsControlPressed(0, 175) then turn = turn - 1.5 end
        SetEntityHeading(ghost, turn)
        DisableControlAction(0, 38, true)
        if IsDisabledControlJustPressed(0, 38) then
            local p = GetEntityCoords(ghost)
            local res = lib.callback.await('daddy_dealerships:display:add', false, dealerId, model, { r, g, b },
                { x = p.x, y = p.y, z = p.z, w = turn % 360.0 })
            Page.notice(res and res.ok and 'msg.display_added' or 'msg.' .. (res and res.error or 'failed'), res and res.ok and 'success' or 'error')
            placing = false
        elseif IsControlJustPressed(0, 177) then
            placing = false
        end
        Wait(0)
    end
    if DoesEntityExist(ghost) then DeleteEntity(ghost) end
    ghostVeh = nil
    Bridge.hint(nil)
end

Page.on('dealer:display:place', function(data)
    local dealer = Hall.dealer()
    if not dealer or placing then return { ok = false } end
    CreateThread(function()
        Hall.close()
        place(dealer, tostring(data.model or ''), tonumber(data.colour), type(data.rgb) == 'table' and data.rgb or nil)
    end)
end)

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    placing = false
    if ghostVeh and DoesEntityExist(ghostVeh) then DeleteEntity(ghostVeh) end
    ghostVeh = nil
end)
