---@diagnostic disable-next-line: lowercase-global
function sendNuiMessage(action, data)
    SendNUIMessage({
        action = action,
        data = data,
    })
end

local hasCustomNuiFocus = false
RegisterNetEvent('tgiann-core:nui-focus')
AddEventHandler('tgiann-core:nui-focus', function(hasFocus, hasKeyboard, hasMouse, allControl)
    hasCustomNuiFocus = hasFocus
    TriggerEvent("tgiann-main:focus", hasCustomNuiFocus)
    if not hasCustomNuiFocus then return end
    CreateThread(function()
        while hasCustomNuiFocus do
            if hasKeyboard and not allControl then
                DisableAllControlActions(0)
                EnableControlAction(0, 249, true)
            elseif hasKeyboard and allControl then
                DisableControlAction(0, 24, true) -- disable attack
                DisableControlAction(0, 25, true) -- disable aim
                DisableControlAction(0, 1, true)  -- LookLeftRight
                DisableControlAction(0, 2, true)  -- LookUpDown
            end

            if not hasKeyboard and hasMouse then
                DisableControlAction(0, 1, true)
                DisableControlAction(0, 2, true)
            elseif hasKeyboard and not hasMouse then
                EnableControlAction(0, 1, true)
                EnableControlAction(0, 2, true)
            end
            HudWeaponWheelIgnoreSelection()
            DisableFrontendThisFrame()
            Wait(0)
        end
    end)
end)

local function firstLoginData()
    local playerLang = lib.callback.await("tgiann-core:getLang", false)

    sendNuiMessage("updateClientData", {
        config = {
            textUiLocation = configCore.textUiLocation,
            locale = config.locale,
            darkMode = config.darkMode == true,
        },
        defaultColor = config.defaultColor,
    })

    ChangeLanguage(playerLang)
end

AddEventHandler('onClientResourceStart', function(resourceName)
    local isMultichar = resourceName == "tgiann-multichar"
    if cache.resource == resourceName then return end
    if not PlayerData and not isMultichar then return end
    if not resourceName:find("tgiann") then return end
    SetTimeout(2500, function()
        if PlayerData and next(PlayerData) then TriggerEvent("tgiCore:Client:OnPlayerLoaded", PlayerData) end
        TriggerEvent("tgiann:changeLanguage", config.lang)
    end)
end)

local deadReviveControl = configCore.custom.deadReviveControl

if config.framework == "aicore" then
    -- ai-core's medical layer reports down / up from whichever death script runs
    AiLib.medical.onChange(function(dead)
        TriggerEvent("tgiCore:playerdead", dead)
    end)
elseif deadReviveControl.method == "statebag" then
    local stateNames = { "dead", "isDead", "isdead" }

    for i = 1, #stateNames do
        AddStateBagChangeHandler(stateNames[i], ('player:%s'):format(cache.serverId), function(_, _, value)
            TriggerEvent("tgiCore:playerdead", value)
        end)
    end
elseif deadReviveControl.custom.active then
    RegisterNetEvent(deadReviveControl.custom.deadEvent)
    AddEventHandler(deadReviveControl.custom.deadEvent, function(data)
        TriggerEvent("tgiCore:playerdead", data ~= nil and data or true)
    end)
    RegisterNetEvent(deadReviveControl.custom.reviveEvent)
    AddEventHandler(deadReviveControl.custom.reviveEvent, function(data)
        TriggerEvent("tgiCore:playerdead", data ~= nil and data or false)
    end)
elseif config.wasabiAmbulanceV2 then
    AddStateBagChangeHandler("isDead", ('player:%s'):format(cache.serverId), function(bagName, _, value)
        local entity = GetEntityFromStateBagName(bagName)
        if entity == 0 then return end
        TriggerEvent("tgiCore:playerdead", value)
    end)
elseif config.wasabi_ambulance then
    AddStateBagChangeHandler("dead", ('player:%s'):format(cache.serverId), function(bagName, _, value)
        local entity = GetEntityFromStateBagName(bagName)
        if entity == 0 then return end
        TriggerEvent("tgiCore:playerdead", value)
    end)
end

-- Accent color of tgiann UIs: the hud's once a hud sent it, else config.defaultColor. Other resources read it through
-- @tgiann-core/lib/accent.lua (GetAccentColor + the local tgiann-core:client:accentColor event)
---@type TgiAccentColor|nil
local hudAccentColor = nil

---@param color any
---@return boolean
local function isAccentColor(color)
    return type(color) == "table" and type(color.background) == "string" and type(color.color) == "string"
end

RegisterNetEvent("tgiann-lumihud:setLumiHudColor")
AddEventHandler("tgiann-lumihud:setLumiHudColor", function(color)
    if not isAccentColor(color) then return end
    hudAccentColor = color
    sendNuiMessage("setLumiHudColor", color)
    TriggerEvent("tgiann-core:client:accentColor", color)
end)

Export("GetAccentColor", function()
    return hudAccentColor or config.defaultColor
end)

RegisterNuiCallback("uiReady", function(_, cb)
    firstLoginData()
    cb("")
end)
