-- The gang points (Config.Points): a ped at each one, opened with ox_target or qb-target, or E with the ox_lib text box
-- when no target system runs. Only when Config.Access.Npc is on.
if not Config.Access.Npc then return end

local peds = {}

local function started(name) return GetResourceState(name) == 'started' end

local function spawn(point)
    local model = joaat(point.model or 'a_m_m_business_01')
    lib.requestModel(model, 10000)
    local c = point.coords
    pcall(function() exports['FeloxAC']:CreatePed(model) end) --[[FeloxAC:auto]]
    local ped = CreatePed(4, model, c.x, c.y, c.z - 1.0, c.w or 0.0, false, true)
    SetModelAsNoLongerNeeded(model)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_IMPATIENT', 0, true)
    return ped
end

local function blip(point)
    if not point.blip then return end
    local c = point.coords
    local b = AddBlipForCoord(c.x, c.y, c.z)
    SetBlipSprite(b, point.blip.sprite or 437)
    SetBlipColour(b, point.blip.color or 1)
    SetBlipScale(b, point.blip.scale or 0.7)
    SetBlipAsShortRange(b, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(point.blip.label or L('menu'))
    EndTextCommandSetBlipName(b)
end

CreateThread(function()
    for _, point in ipairs(Config.Points) do
        local ped = spawn(point)
        peds[#peds + 1] = ped
        blip(point)
        if started('ox_target') then
            exports.ox_target:addLocalEntity(ped, { {
                name = 'daddy_gangs_menu', icon = 'fa-solid fa-people-group', label = L('open_menu'), distance = Config.Interaction.Distance,
                onSelect = function() TriggerEvent('daddy_gangs:open') end,
            } })
        elseif started('qb-target') then
            exports['qb-target']:AddTargetEntity(ped, {
                options = { { icon = 'fas fa-people-group', label = L('open_menu'), action = function() TriggerEvent('daddy_gangs:open') end } },
                distance = Config.Interaction.Distance,
            })
        else
            local c = point.coords
            lib.points.new({
                coords = vec3(c.x, c.y, c.z), distance = Config.Interaction.Distance,
                onEnter = function() lib.showTextUI(('[%s] %s'):format(Config.Interaction.Key, L('open_menu'))) end,
                onExit = function() lib.hideTextUI() end,
                nearby = function()
                    if IsControlJustReleased(0, 38) then TriggerEvent('daddy_gangs:open') end
                end,
            })
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for _, ped in ipairs(peds) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
end)
