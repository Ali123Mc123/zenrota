-- Owner jobs, shop blips and shop prompts.

function HideHud(hidden)
    if GetResourceState('wais-primehud') == 'started' then
        pcall(function() if hidden then exports['wais-primehud']:showHud() else exports['wais-primehud']:hideHud() end end)
    end
    if GetResourceState('daddy-hud') == 'started' then pcall(function() exports['daddy-hud']:SetVisible(not hidden) end) end
end

-- The menu, the stance panel and the tablet take the cursor but leave the game its keys (SetNuiFocusKeepInput), so
-- push to talk (pma-voice's key mapping) still works; every other game control stays off while one is open. While a text
-- field is being typed in, the keys go to the page only, so letters do not set off the game's key mappings.
local uiFocus = { on = false, typing = false, loop = 0 }
function UiFocus(on)
    on = on == true
    uiFocus.on = on
    if not on then uiFocus.typing = false end
    SetNuiFocus(on, on)
    SetNuiFocusKeepInput(on and not uiFocus.typing)
    if not on then return end
    uiFocus.loop = uiFocus.loop + 1
    local mine = uiFocus.loop
    CreateThread(function()
        while uiFocus.on and uiFocus.loop == mine do
            DisableAllControlActions(0)
            EnableControlAction(0, 249, true) -- push to talk (control)
            Wait(0)
        end
    end)
end

RegisterNUICallback('uiTyping', function(data, cb)
    uiFocus.typing = type(data) == 'table' and data.on == true
    if uiFocus.on then SetNuiFocusKeepInput(not uiFocus.typing) end
    cb({})
end)

RegisterNetEvent('daddy_mechanic:notify', function(text, kind)
    Bridge.notify(nil, text, kind)
end)

local function health(v)
    local n = Core.num(v)
    return n and math.max(0.0, math.min(n, 1000.0)) or nil
end

AddStateBagChangeHandler('daddy_mechanic:apply', nil, function(bagName, _, job)
    if type(job) ~= 'table' then return end
    local vehicle = GetEntityFromStateBagName(bagName)
    if vehicle == 0 or NetworkGetEntityOwner(vehicle) ~= PlayerId() then return end
    if type(job.props) == 'table' then Props.set(vehicle, job.props) end
    local engine, body = health(job.engine), health(job.body)
    if engine then SetVehicleEngineHealth(vehicle, engine) end
    if body then SetVehicleBodyHealth(vehicle, body) end
    if job.clean then SetVehicleDirtLevel(vehicle, 0.0) WashDecalsFromVehicle(vehicle, 1.0) end
    if job.repair or job.fix then
        SetVehicleFixed(vehicle)
        SetVehicleDeformationFixed(vehicle)
        SetVehicleEngineHealth(vehicle, 1000.0)
        SetVehicleBodyHealth(vehicle, 1000.0)
        SetVehiclePetrolTankHealth(vehicle, 1000.0)
    end
    TriggerServerEvent('daddy_mechanic:applied', job.id)
end)

CreateThread(function()
    for _, shop in pairs(Config.Shops) do
        if shop.blip then
            local blip = AddBlipForCoord(shop.points[1].x, shop.points[1].y, shop.points[1].z)
            SetBlipSprite(blip, shop.blip.sprite)
            SetBlipColour(blip, shop.blip.colour or 0)
            SetBlipScale(blip, shop.blip.scale or 0.7)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(shop.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

local prompt = false

local function showPrompt(label)
    if (label ~= nil) == prompt then return end
    prompt = label ~= nil
    Bridge.hint(label and { label = label, keys = { { 'E', 'ui.hint_open' } } } or nil)
end

for shopId, shop in pairs(Config.Shops) do
    for _, coords in ipairs(shop.points) do
        lib.points.new({
            coords = coords,
            distance = shop.radius,
            nearby = function()
                local driving = cache.vehicle and cache.seat == -1
                showPrompt(driving and not Menu.isOpen() and shop.label or nil)
                if prompt and IsControlJustReleased(0, Config.Key) then
                    showPrompt(nil)
                    Menu.open(shopId)
                end
            end,
            onExit = function() showPrompt(nil) end,
        })
    end
end
