-- ═══════════════════════════════════════════════════════════════════════════════
-- Daddy Marketplace - Client
-- NPCs, props, blips, interaction (target or marker), UI open/close, NUI bridge
-- ═══════════════════════════════════════════════════════════════════════════════

Daddy = Daddy or {}

local isUIOpen = false
local currentLocationId = nil
local spawnedPeds = {}
local spawnedBlips = {}
local spawnedProps = {}

-- ─────────────────────────────────────────────────────────────────────────────
-- Helpers
-- ─────────────────────────────────────────────────────────────────────────────
local function ClientNotify(message, notifType)
    if GetResourceState('ox_lib') == 'started' then
        TriggerEvent('ox_lib:notify', { title = 'Pazar Yeri', description = message, type = notifType or 'info' })
    elseif GetResourceState('es_extended') == 'started' then
        TriggerEvent('esx:showNotification', message)
    else
        TriggerEvent('QBCore:Notify', message, notifType or 'primary')
    end
end

local function LoadModel(model)
    local hash = type(model) == 'number' and model or joaat(model)
    if not IsModelValid(hash) then return nil end
    RequestModel(hash)
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(hash) do
        if GetGameTimer() > timeout then return nil end
        Wait(10)
    end
    return hash
end

--- Which target resource to use: Config.TargetSystem = 'auto' | 'ox_target' | 'qb-target' | 'none'
local function GetTargetSystem()
    local wanted = Config.TargetSystem or 'auto'
    if wanted == 'none' then return nil end
    if wanted == 'custom' then
        return type(Config.CustomTarget) == 'function' and 'custom' or nil
    end
    if (wanted == 'auto' or wanted == 'ox_target') and GetResourceState('ox_target') == 'started' then
        return 'ox_target'
    end
    if (wanted == 'auto' or wanted == 'qb-target') and GetResourceState('qb-target') == 'started' then
        return 'qb-target'
    end
    return nil
end

-- ─────────────────────────────────────────────────────────────────────────────
-- NPC, props & blips
-- ─────────────────────────────────────────────────────────────────────────────
local function CreateMarketplacePed(locationId, locationData)
    if not locationData.usePed then return end

    local model = LoadModel(locationData.pedModel or 's_m_m_shopkeep_01')
    if not model then
        print('^1[Daddy Marketplace] ^7Failed to load ped model: ' .. tostring(locationData.pedModel))
        return
    end

    local coords = locationData.coords
    pcall(function() exports['FeloxAC']:CreatePed(model) end) --[[FeloxAC:auto]]
    local ped = CreatePed(0, model, coords.x, coords.y, coords.z - 1.0, locationData.heading or 0.0, false, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityHeading(ped, locationData.heading or 0.0)

    if locationData.pedScenario then
        TaskStartScenarioInPlace(ped, locationData.pedScenario, 0, true)
    end

    spawnedPeds[locationId] = ped
    SetModelAsNoLongerNeeded(model)
end

local function CreateMarketplaceProps(locationId, locationData)
    if not locationData.props or #locationData.props == 0 then return end

    spawnedProps[locationId] = {}

    for _, propData in ipairs(locationData.props) do
        local modelHash = LoadModel(propData.model)
        if modelHash then
            local rot = propData.rotation or vector3(0.0, 0.0, 0.0)
            pcall(function() exports['FeloxAC']:CreateObject(modelHash) end) --[[FeloxAC:auto]]
            local obj = CreateObjectNoOffset(modelHash, propData.coords.x, propData.coords.y, propData.coords.z, false, false, propData.dynamic ~= false)
            SetEntityRotation(obj, rot.x, rot.y, rot.z, 2, true)
            if propData.frozen ~= false then
                FreezeEntityPosition(obj, true)
            end
            SetEntityCollision(obj, true, true)
            spawnedProps[locationId][#spawnedProps[locationId] + 1] = obj
            SetModelAsNoLongerNeeded(modelHash)
        else
            print('^1[Daddy Marketplace] ^7Failed to load prop model: ' .. tostring(propData.model))
        end
    end
end

local function CreateMarketplaceBlip(locationId, locationData)
    if not locationData.blip or not locationData.blip.enabled then return end

    local blip = AddBlipForCoord(locationData.coords.x, locationData.coords.y, locationData.coords.z)
    SetBlipSprite(blip, locationData.blip.sprite or 59)
    SetBlipDisplay(blip, locationData.blip.display or 4)
    SetBlipScale(blip, locationData.blip.scale or 0.8)
    SetBlipColour(blip, locationData.blip.color or 2)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(locationData.label or 'Marketplace')
    EndTextCommandSetBlipName(blip)

    spawnedBlips[locationId] = blip
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Open / close
-- ─────────────────────────────────────────────────────────────────────────────
local function OpenMarketplace(locationId)
    if isUIOpen then return end
    currentLocationId = locationId
    isUIOpen = true
    TriggerServerEvent('daddy-marketplace:server:openMarketplace', locationId)
end

local function CloseMarketplace()
    if not isUIOpen then return end

    isUIOpen = false
    currentLocationId = nil

    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    TriggerServerEvent('daddy-marketplace:server:closeMarketplace')
end

-- Server refused to open (too far, job restriction, ...): reset local state
RegisterNetEvent('daddy-marketplace:client:openDenied', function()
    isUIOpen = false
    currentLocationId = nil
    SetNuiFocus(false, false)
end)

RegisterNetEvent('daddy-marketplace:client:receiveMarketData', function(data)
    if not isUIOpen then return end
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', data = data })
end)

RegisterNetEvent('daddy-marketplace:client:refreshData', function(data)
    if not isUIOpen then return end
    SendNUIMessage({ action = 'refreshData', data = data })
end)

-- Something changed at this location: refresh once, even if several updates arrive together
local refreshQueued = false
RegisterNetEvent('daddy-marketplace:client:dataChanged', function()
    if not isUIOpen or refreshQueued then return end
    refreshQueued = true
    SetTimeout(300, function()
        refreshQueued = false
        if isUIOpen then
            TriggerServerEvent('daddy-marketplace:server:refreshData', currentLocationId, 'all')
        end
    end)
end)

-- Result of a state-changing action (lets the UI close modals only on success)
RegisterNetEvent('daddy-marketplace:client:actionResult', function(result)
    SendNUIMessage({ action = 'actionResult', data = result })
end)

-- Push notifications reach the NUI even while the panel is closed
RegisterNetEvent('daddy-marketplace:client:notify', function(payload)
    SendNUIMessage({ action = 'notify', data = payload })
end)

-- Read-only data responses forwarded to the NUI
for event, action in pairs({
    ['daddy-marketplace:client:sellerProfile'] = 'sellerProfile',
    ['daddy-marketplace:client:itemPriceHistory'] = 'itemPriceHistory',
    ['daddy-marketplace:client:myProfileStats'] = 'myProfileStats',
    ['daddy-marketplace:client:marketPulse'] = 'marketPulse',
    ['daddy-marketplace:client:sellerSalesHistory'] = 'sellerSalesHistory',
}) do
    RegisterNetEvent(event, function(data)
        if not isUIOpen then return end
        SendNUIMessage({ action = action, data = data })
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- NUI callbacks → server events
-- ─────────────────────────────────────────────────────────────────────────────
RegisterNUICallback('close', function(_, cb)
    CloseMarketplace()
    cb('ok')
end)

-- NUI action → server event. `arg` picks a single field instead of the whole payload.
local NuiActions = {
    createListing      = { event = 'createListing' },
    purchaseListing    = { event = 'purchaseListing' },
    purchaseCart       = { event = 'purchaseCart' },
    editListing        = { event = 'editListing' },
    cancelListing      = { event = 'cancelListing', arg = 'listing_id' },
    featureListing     = { event = 'featureListing' },
    createAuction      = { event = 'createAuction' },
    placeBid           = { event = 'placeBid' },
    cancelAuction      = { event = 'cancelAuction' },
    featureAuction     = { event = 'featureAuction' },
    makeOffer          = { event = 'makeOffer' },
    acceptOffer        = { event = 'acceptOffer', arg = 'offer_id' },
    rejectOffer        = { event = 'rejectOffer', arg = 'offer_id' },
    withdrawOffer      = { event = 'withdrawOffer', arg = 'offer_id' },
    counterOffer       = { event = 'counterOffer' },
    acceptCounterOffer = { event = 'acceptCounterOffer', arg = 'offer_id' },
    rejectCounterOffer = { event = 'rejectCounterOffer', arg = 'offer_id' },
    createBuyOrder     = { event = 'createBuyOrder' },
    fulfillBuyOrder    = { event = 'fulfillBuyOrder' },
    claimBuyOrderItems = { event = 'claimBuyOrderItems', arg = 'buy_order_id' },
    cancelBuyOrder     = { event = 'cancelBuyOrder', arg = 'buy_order_id' },
    getSellerProfile   = { event = 'getSellerProfile', arg = 'identifier' },
    submitRating       = { event = 'submitRating' },
    getItemPriceHistory = { event = 'getItemPriceHistory', arg = 'item_name' },
    getMyProfileStats  = { event = 'getMyProfileStats', noArgs = true },
    getMarketPulse     = { event = 'getMarketPulse', noArgs = true },
    getSellerSalesHistory = { event = 'getSellerSalesHistory', arg = 'identifier' },
    toggleWatchlist    = { event = 'toggleWatchlist', arg = 'listing_id' },
    claimDeliveries    = { event = 'claimDeliveries', noArgs = true },
}

for name, def in pairs(NuiActions) do
    RegisterNUICallback(name, function(data, cb)
        data = type(data) == 'table' and data or {}
        local eventName = 'daddy-marketplace:server:' .. def.event
        if def.noArgs then
            TriggerServerEvent(eventName)
        elseif def.arg then
            TriggerServerEvent(eventName, data[def.arg])
        else
            TriggerServerEvent(eventName, data)
        end
        cb('ok')
    end)
end

RegisterNUICallback('refreshData', function(data, cb)
    local section = type(data) == 'table' and data.section or 'all'
    TriggerServerEvent('daddy-marketplace:server:refreshData', currentLocationId, section)
    cb('ok')
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Interaction: target on the NPC, or a marker + key press
-- ─────────────────────────────────────────────────────────────────────────────
local function SetupTargetInteraction(locationId, locationData, targetSystem)
    local ped = spawnedPeds[locationId]
    if not ped then return false end

    if targetSystem == 'custom' then
        local ok, err = pcall(Config.CustomTarget, ped, locationId, locationData, function() OpenMarketplace(locationId) end)
        if not ok then
            print('^1[Daddy Marketplace] ^7Config.CustomTarget error: ' .. tostring(err))
        end
        return ok
    elseif targetSystem == 'ox_target' then
        exports.ox_target:addLocalEntity(ped, {
            {
                name = 'daddy_marketplace_' .. locationId,
                icon = 'fas fa-store',
                label = _L('target.open_market'),
                distance = locationData.radius or 2.0,
                onSelect = function() OpenMarketplace(locationId) end,
            },
        })
        return true
    elseif targetSystem == 'qb-target' then
        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    type = 'client',
                    icon = 'fas fa-store',
                    label = _L('target.open_market'),
                    action = function() OpenMarketplace(locationId) end,
                },
            },
            distance = locationData.radius or 2.0,
        })
        return true
    end
    return false
end

local function SetupMarkerInteraction(locationId, locationData)
    CreateThread(function()
        while true do
            local sleep = 1000
            local dist = #(GetEntityCoords(PlayerPedId()) - locationData.coords)

            if dist < Config.Marker.drawDistance then
                sleep = 0
                DrawMarker(
                    Config.Marker.type,
                    locationData.coords.x, locationData.coords.y, locationData.coords.z - 1.0,
                    0.0, 0.0, 0.0,
                    0.0, 0.0, 0.0,
                    Config.Marker.scale.x, Config.Marker.scale.y, Config.Marker.scale.z,
                    Config.Marker.color.r, Config.Marker.color.g, Config.Marker.color.b, Config.Marker.color.a,
                    Config.Marker.bobUpAndDown, Config.Marker.faceCamera, 2, Config.Marker.rotate,
                    nil, nil, false
                )

                if dist < Config.Marker.interactDistance and not isUIOpen then
                    BeginTextCommandDisplayHelp('STRING')
                    AddTextComponentSubstringPlayerName(_L('target.help_text'))
                    EndTextCommandDisplayHelp(0, false, true, -1)

                    if IsControlJustReleased(0, Config.Marker.interactKey) then
                        OpenMarketplace(locationId)
                    end
                end
            end

            Wait(sleep)
        end
    end)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- Initialize
-- ─────────────────────────────────────────────────────────────────────────────
CreateThread(function()
    Daddy.Locale.Init(Config.Locale)

    local targetSystem = GetTargetSystem()

    for locationId, locationData in pairs(Config.Locations) do
        CreateMarketplaceBlip(locationId, locationData)
        CreateMarketplacePed(locationId, locationData)
        CreateMarketplaceProps(locationId, locationData)

        -- Target needs a ped; otherwise (or without a target resource) fall back to a marker
        local usingTarget = locationData.useTarget and targetSystem
            and SetupTargetInteraction(locationId, locationData, targetSystem)
        if not usingTarget then
            SetupMarkerInteraction(locationId, locationData)
        end
    end
end)

-- Optional chat command (Config.UI.enableCommand): opens the nearest marketplace
if Config.UI and Config.UI.enableCommand then
    RegisterCommand(Config.UI.openCommand or 'marketplace', function()
        local playerCoords = GetEntityCoords(PlayerPedId())
        local nearestId, nearestDist = nil, math.huge

        for locationId, locationData in pairs(Config.Locations) do
            local dist = #(playerCoords - locationData.coords)
            if dist < nearestDist then
                nearestDist = dist
                nearestId = locationId
            end
        end

        if nearestId and nearestDist < (Config.Security.maxDistance or 10.0) then
            OpenMarketplace(nearestId)
        else
            ClientNotify(_L('notify.too_far'), 'error')
        end
    end, false)
end

-- Block camera/attack input while the UI is open; ESC closes it
CreateThread(function()
    while true do
        if isUIOpen then
            DisableControlAction(0, 1, true)   -- look left/right
            DisableControlAction(0, 2, true)   -- look up/down
            DisableControlAction(0, 142, true) -- melee attack
            DisableControlAction(0, 18, true)  -- enter
            if IsDisabledControlJustPressed(0, 200) then -- ESC
                CloseMarketplace()
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- ─────────────────────────────────────────────────────────────────────────────
-- Exports: open the marketplace from other resources (phones, menus, ...)
-- The server still checks distance and job for the given location.
-- ─────────────────────────────────────────────────────────────────────────────
exports('OpenMarketplace', function(locationId)
    if Config.Locations[locationId] then OpenMarketplace(locationId) end
end)
exports('CloseMarketplace', CloseMarketplace)
exports('IsMarketplaceOpen', function() return isUIOpen end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    for _, ped in pairs(spawnedPeds) do
        if DoesEntityExist(ped) then DeleteEntity(ped) end
    end
    for _, propList in pairs(spawnedProps) do
        for _, obj in ipairs(propList) do
            if DoesEntityExist(obj) then DeleteEntity(obj) end
        end
    end
    for _, blip in pairs(spawnedBlips) do
        RemoveBlip(blip)
    end

    if isUIOpen then
        isUIOpen = false
        SetNuiFocus(false, false)
    end
end)
