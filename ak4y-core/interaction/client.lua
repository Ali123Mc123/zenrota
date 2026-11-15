local activeInteractions = {}
local targetInteractionIds = {}
local interactionIdCounter = 0

---@param coords vector3
---@param name string
---@param label string
---@param event string Event adı (tetiklendiğinde TriggerEvent ile çağrılır)
---@param options table|nil { icon, canInteract, meta }
---@return number interactionId
function addInteractionCoords(coords, name, label, event, options)
    interactionIdCounter = interactionIdCounter + 1
    local id = interactionIdCounter
    options = options or {}

    if Config.Interaction.useTarget then
        local zoneId = exports["ak4y-core"]:AddZoneToTargeting(
            coords,
            vec3(0, 0, 0),
            vec3(1, 1, 1),
            label,
            event,
            options.canInteract,
            options.meta,
            1.5,
            options.icon
        )
        targetInteractionIds[id] = zoneId
    else
        activeInteractions[id] = {
            coords = coords,
            name = name,
            label = "[E] " .. label,
            event = event,
            options = options,
            canInteract = options?.canInteract
        }
    end

    return id
end

function removeInteractionCoords(id)
    if targetInteractionIds[id] then
        exports["ak4y-core"]:RemoveTargetZone(targetInteractionIds[id])
        targetInteractionIds[id] = nil
    elseif activeInteractions[id] then
        activeInteractions[id] = nil
    end
end

CreateThread(function()
    if Config.Interaction.useTarget then return end
    local sleep = 1000
    while true do
        Wait(sleep)
        local isClose = false
        for k,v in pairs(activeInteractions) do
            if #(GetEntityCoords(PlayerPedId()) - v.coords) < 5.0 then
                isClose = true
            end
        end
        if isClose then
            sleep = 1
            for k,v in pairs(activeInteractions) do
                if #(GetEntityCoords(PlayerPedId()) - v.coords) < 1.5 then
                    local canInteract = true
                    if type(v.canInteract) == "function" then
                        canInteract = v.canInteract()
                    elseif type(v.canInteract) == "table" then
                        canInteract = v.canInteract()
                    elseif v.canInteract == false then
                        canInteract = false
                    end
                    if canInteract then
                        Draw3DText({
                            text = v.label,
                            coords = v.coords,
                        })
                        if IsControlJustReleased(0, 38) then
                            local data = v.options.meta or {}
                            data.coords = v.coords
                            TriggerEvent(v.event, data)
                        end
                    end
                end
            end
        else
            sleep = 1000
        end
    end
end)

function Draw3DText(data)
    local text = data.text
    local x = data.coords.x
    local y = data.coords.y
    local z = data.coords.z
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

exports('addInteractionCoords', addInteractionCoords)
exports('removeInteractionCoords', removeInteractionCoords)