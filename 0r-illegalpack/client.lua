--[[ Main Client File]]

client = {
    framework = shared.getFrameworkObject(),
    load = false,
    uiLoad = false,
    uiOpen = false,
    exports = {},
    -- global --
    currentJob = nil, --[[@type Job]]
    lobby = {} --[[@type Lobby]]
}

--[[ require ]]

require 'modules.bridge.init'
require 'modules.exports.client'

local Utils = require 'modules.utils.client'

--[[ helper functions ]]

local function hideFrame()
    client.sendReactMessage('ui:setVisible', false)
    SetNuiFocus(false, false)
    client.uiOpen = false
end

local function clearClient()
    if client.uiOpen then hideFrame() end
    client.uiOpen = false
    Market.onUnload()
    Jobs.onUnload()
    client.sendReactMessage('ui:onUnload')
    TriggerServerEvent(_e('server:onPlayerLogout'))
    client.currentJob = nil
end

---Prepare the frontend and send the data
local function setupUI()
    if client.uiLoad then return end
    local defaultLocale = GetConvar('ox:locale', 'en')
    client.sendReactMessage('ui:setupUI', {
        setLocale = lib.loadJson(('locales.%s'):format(defaultLocale)).ui,
        setConfig = {
            InventoryImagesFolder = Config.InventoryImagesFolder,
            JobInfoBoxAlign = Config.JobInfoBoxAlign,
        },
        setMarketItems = Market.getDataItems(),
        illegalMarketEnabled = Config.IllegalMarket and Config.IllegalMarket.enabled,
    }, true)
end

local function openMenu()
    if not client.uiLoad then return end
    if Config.IllegalMenu.allowedJobs and #Config.IllegalMenu.allowedJobs > 0 then
        if not client.hasPlayerGotGroup(Config.IllegalMenu.allowedJobs) then
            Utils.notify(locale('you_do_not_have_permission'), 'error')
            return
        end
    end
    if Config.IllegalMenu.forbiddenJobs and #Config.IllegalMenu.forbiddenJobs > 0 then
        if client.hasPlayerGotGroup(Config.IllegalMenu.forbiddenJobs) then
            Utils.notify(locale('you_do_not_have_permission'), 'error')
            return
        end
    end
    client.sendReactMessage('ui:setPage', 'home')
    client.sendReactMessage('ui:setVisible', true)
    SetNuiFocus(true, true)
    client.uiOpen = true
    if (Profile.get().source == -1) then
        Profile.fetch()
        Profile.updateUI()
    end
end

--[[ functions ]]

---Sends message to the ReactUI.
---@param action string
---@param data any
function client.sendReactMessage(action, data)
    SendNUIMessage({ action = action, data = data })
end

---@param text string
---@param type 'error'|'success'
function client.sendReactAlert(text, type)
    client.sendReactMessage('ui:setAlert', { type = type, text = text })
end

function client.onPlayerLoad(isLoggedIn)
    if isLoggedIn then
        Jobs.onLoad()
    else
        clearClient()
        Utils.hideTextUI()
    end
    client.load = isLoggedIn
end

function client.hideUI()
    hideFrame()
end

---@param ic vector3
---@param entitySets table<entitySetName, boolean>
function client.loadInteriorEntities(ic, entitySets)
    local interiorID = GetInteriorAtCoords(ic.x, ic.y, ic.z)
    if not IsValidInterior(interiorID) then return end

    PinInteriorInMemory(interiorID)

    for key, value in pairs(entitySets) do
        if value then
            ActivateInteriorEntitySet(interiorID, key)
        else
            DeactivateInteriorEntitySet(interiorID, key)
        end
    end

    RefreshInterior(interiorID)
end

function client.setOutfit(outfit)
    local framework = shared.framework

    if outfit then
        if framework == 'esx' then
            client.framework.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                if skin then
                    TriggerEvent('skinchanger:loadClothes', skin, outfit)
                end
            end)
        else
            TriggerEvent('qb-clothing:client:loadOutfit', { outfitData = outfit })
        end
    else
        if framework == 'esx' then
            client.framework.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
                if skin then TriggerEvent('skinchanger:loadSkin', skin) end
            end)
        elseif framework == 'qb' then
            TriggerServerEvent('qb-clothes:loadPlayerSkin')
        else
            TriggerEvent('illenium-appearance:client:reloadSkin', true)
        end
    end
end

--[[ events ]]

RegisterNUICallback('nui:client:loadUI', function(_, resultCallback)
    resultCallback(true)
    setupUI()
end)

RegisterNUICallback('nui:client:onLoadUI', function(_, resultCallback)
    resultCallback(true)
    client.uiLoad = true
end)

RegisterNUICallback('nui:client:hideFrame', function(_, resultCallback)
    hideFrame()
    resultCallback(true)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= shared.resource then return end
    Citizen.Wait(2000)
    if not client.isPlayerLoaded() then return end
    client.onPlayerLoad(true)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= shared.resource then return end
    client.onPlayerLoad(false)
end)

AddEventHandler('playerDropped', function()
    client.onPlayerLoad(false)
end)

if Config.IllegalMenu.openWithCommand and Config.IllegalMenu.openWithCommand.active then
    RegisterCommand(Config.IllegalMenu.openWithCommand.command, openMenu)
end

if Config.IllegalMenu.openWithKey and Config.IllegalMenu.openWithKey.active then
    lib.addKeybind({
        name = 'illegal_pack_open_menu',
        description = 'Open menu',
        defaultKey = Config.IllegalMenu.openWithKey.key,
        onPressed = openMenu
    })
end

RegisterNetEvent('0r-illegalpack:client:openMenu', function()
    if not client.uiLoad then
        setupUI()
    end
    openMenu()
end)

RegisterNetEvent('client:illegalpack:notify', function(title, type, description, duration)
    Utils.notify(title, type, duration, description)
end)

---@param source number player server id
---@param netId? number vehicle netId
lib.callback.register(_e('client:isPlayerNearVehicle'), function(source, netId)
    local coords = GetEntityCoords(cache.ped)
    local maxDistance = 2.5
    local closestVehicles = lib.getNearbyVehicles(coords, maxDistance, false)

    for _, closestVehicle in pairs(closestVehicles) do
        if DoesEntityExist(closestVehicle.vehicle) then
            local vehicleNetId = VehToNet(closestVehicle.vehicle)

            -- Eğer netId belirtilmişse ve bu araçla eşleşiyorsa
            if netId ~= nil then
                if vehicleNetId == netId then
                    return true
                end
            else
                return true
            end
        end
    end

    return false
end)
