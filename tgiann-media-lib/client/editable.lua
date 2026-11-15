Editable = {}

-- Runs when the photo manager takes the mouse
function Editable.uiOpened()
    TriggerEvent("tgiann-lumihud:ui", false)
end

-- Runs when the photo manager lets the mouse go
function Editable.uiClosed()
    TriggerEvent("tgiann-lumihud:ui", true)
end

-- Runs before a free camera starts (shell model shoot); tell your anticheat the camera is allowed here
function Editable.onFreecamStart()
    if GetResourceState("tgiann-anticheat") == "started" then
        exports["tgiann-anticheat"]:CamActive()
    end
end
