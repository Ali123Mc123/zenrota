Editable = {}

-- DaddyRP: tırnak yapılırken konuşabilmek için. Panel açıkken NUI klavyeyi tamamen alıyor, bas-konuş (N) ve telsiz
-- tuşları oyuna ulaşmıyordu. Panel açıkken girdi oyuna da geçiyor, bas-konuş dışındaki oyun kontrolleri kapalı tutuluyor.
local talkWhileUiOpen = false
local PUSH_TO_TALK = 249

---Hide the HUD while the studio or a panel is open
function Editable.uiOpened()
    TriggerEvent("tgiann-lumihud:ui", false)
    if talkWhileUiOpen then return end
    talkWhileUiOpen = true
    CreateThread(function()
        while talkWhileUiOpen do
            if IsNuiFocused() then
                SetNuiFocusKeepInput(true)
                DisableAllControlActions(0)
                EnableControlAction(0, PUSH_TO_TALK, true)
            end
            Wait(0)
        end
        SetNuiFocusKeepInput(false)
    end)
end

function Editable.uiClosed()
    TriggerEvent("tgiann-lumihud:ui", true)
    talkWhileUiOpen = false
end

---Extra check before the studio opens (return false to block)
function Editable.canOpenStudio()
    return not IsPedInAnyVehicle(cache.ped, false) and not ClientState.dead
end

---Clothes of an NPC customer (a freemode ped with a random face and hair). Put your own outfit presets here,
---e.g. from your clothing script; seed is the same on every screen so everyone sees the same outfit
---@param ped integer
---@param gender "f"|"m"
---@param seed integer
---@diagnostic disable-next-line: unused-argument
function Editable.orderPedLook(ped, gender, seed)
    -- Your code here
end
