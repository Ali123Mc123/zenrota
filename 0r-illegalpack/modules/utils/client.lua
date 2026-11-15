--[[ Contains client-side helper functions. ]]

local Utils = {}

-- Global variable for tracking progress bar end time (anti-exploit)
Utils._progressBarEndTime = 0

---@param title string
---@param type 'inform'|'error'|'success'|'warning'
---@param duration number
---@param description string
function Utils.notify(title, type, duration, description)
    lib.notify({
        title = title,
        type = type or 'inform',
        duration = duration,
        description = description,
        position = 'top-center',
    })
end

---@param text string
---@param options? TextUIOptions
function Utils.showTextUI(text, options)
    options = options or {}
    options.position = options.position or 'left-center'
    lib.showTextUI(text, options)
end

function Utils.hideTextUI()
    lib.hideTextUI()
end

---Change HUD visibility
---@param state boolean
function Utils.toggleHud(state)
    -- exports["wais-hudv6"]:showHud(state)
end

---@param key string
---@param message string
---@param coords? vector3|vector4
function Utils.triggerPoliceAlert(key, message, coords)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    local localeKey = "police_alerts." .. key
    local translated = locale(localeKey)

    if translated and translated ~= localeKey then
        message = translated
    end

    TriggerServerEvent('can9work-base/ilegalEylem', coords, message)
end

---@param plate string
---@param entity number
function Utils.giveVehicleKey(plate, entity)
    TriggerEvent("vehiclekeys:client:SetOwner", plate)
end

function Utils.removeVehicleKey(plate, entity)
    TriggerEvent("vehiclekeys:client:RemoveKeys", plate)
end

---@param entity number
---@param level number
function Utils.setFuel(entity, level)
    if not level then level = 100.0 end
    exports['savana-fuel']:SetFuel(entity, level)
end

--[[!!! It is not recommended to change the functions from here on if you are not familiar with them !!!]]

---@param model string
---@param coords vector3
---@param rotation vector3
---@param freeze boolean
---@param isNetwork boolean
---@param doorFlag boolean
---@return integer
function Utils.createObject(model, coords, rotation, freeze, isNetwork, doorFlag)
    if freeze == nil then freeze = true end
    if isNetwork == nil then isNetwork = false end
    if doorFlag == nil then doorFlag = false end
    lib.requestModel(model)
    local object = CreateObject(model, coords.x, coords.y, coords.z, isNetwork, isNetwork, doorFlag)
    SetEntityCoords(object, coords.x, coords.y, coords.z, false, false, false, true)
    if rotation then
        if type(rotation) == 'number' then
            rotation = vector3(0.0, 0.0, rotation)
        end
        SetEntityRotation(object, rotation.x, rotation.y, rotation.z, 2, false)
    end
    FreezeEntityPosition(object, freeze)
    SetModelAsNoLongerNeeded(model)
    return object
end

---@param coords vector3
function Utils.getGroundZ(coords)
    local x, y, z = table.unpack(coords)
    local groundCheckHeights = { z, z + 1.0, z + 2.0, z + 3.0, z + 4.0, z + 5.0 }

    for i, height in pairs(groundCheckHeights) do
        local foundGround, z = GetGroundZFor_3dCoord(x, y, height)

        if foundGround then
            return z, true
        end
    end

    return z, false
end

---@param target number|vector3
---@param options object
---@param route boolean
function Utils.addBlip(target, options, route, longRange)
    local blip = type(target) == 'number' and
        AddBlipForEntity(target) or
        AddBlipForCoord(vector3(target))

    SetBlipDisplay(blip, 4)
    SetBlipSprite(blip, options.sprite or 469)
    SetBlipColour(blip, options.color or 0)
    SetBlipScale(blip, options.scale or 0.85)
    SetBlipAsShortRange(blip, not longRange)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(options.text or 'Undefined')
    EndTextCommandSetBlipName(blip)

    if route then
        local coords = type(target) == 'number' and GetEntityCoords(target) or vector3(target)
        SetNewWaypoint(coords.x, coords.y)
    end

    return blip
end

---@param coords vector
---@param text string
function Utils.drawText3D(coords, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    EndTextCommandDisplayText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 70, 134, 123, 75)
    ClearDrawOrigin()
end

local isProgressActive = false

---@param data any
---@return boolean success
function Utils.progressBar(data)
    if isProgressActive or lib.progressActive() then
        return false
    end

    isProgressActive = true
    local duration = tonumber(data.duration) or 1000
    local minRequiredTime = GetGameTimer() + math.max(0, duration - 1500)

    local success = lib.progressBar(data)
    local elapsedOk = GetGameTimer() >= minRequiredTime
    isProgressActive = false

    if not success or not elapsedOk then
        if not elapsedOk and success then
            lib.print.info("Progress bar was interrupted (possible exploit attempt).")
        end
        return false
    end

    return true
end

---@param difficulty any
---@param inputs any
---@return boolean
function Utils.skillCheck(difficulty, inputs)
    return lib.skillCheck(difficulty, inputs)
end

---Detailed skill check handler
---@param settings table
---@param context string|number
---@return boolean
function Utils.checkSkill(settings, context)
    if not settings then return true end
    if settings.enabled == false then return true end

    if context then
        if settings.activeSteps and type(context) == 'number' then
            local found = false
            for k, v in pairs(settings.activeSteps) do
                if v == context or (k == context and v == true) then
                    found = true
                    break
                end
            end
            if not found then return true end
        end

        if settings.activeActions and type(context) == 'string' then
            if settings.activeActions[context] == false then
                return true
            end
        end
    end

    return Utils.skillCheck(settings.difficulty, settings.keys)
end

function Utils.revivePlayerWithAmbulanceScript()
    -- ? Use your ambulance script export
end

return Utils
