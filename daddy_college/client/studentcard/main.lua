-- ID cards on the client: the card in hand while it is shown, the photo of whoever shows it, and putting it away.
if not Core.ModuleEnabled('studentcard') then return end

local cfg = Config.StudentCard
local current

local function close()
    if not current then return end
    Core.Nui.Send('studentcard:hide', { showId = current })
    current = nil
end

-- Esc or Backspace puts it away without taking the cursor.
local function watchKeys(id)
    CreateThread(function()
        while current == id do
            if IsControlJustReleased(0, 322) or IsControlJustReleased(0, 177) or IsDisabledControlJustReleased(0, 322) or IsDisabledControlJustReleased(0, 177) then
                return close()
            end
            Wait(0)
        end
    end)
end

RegisterNetEvent('daddy_college:studentcard:show', function(card)
    if type(card) ~= 'table' or type(card.showId) ~= 'string' then return end
    current = card.showId
    Core.Nui.Send('studentcard:show', card)
    watchKeys(card.showId)
    CreateThread(function()
        local player = GetPlayerFromServerId(card.presenter)
        local ped = player ~= -1 and GetPlayerPed(player) or 0
        local photo = ped ~= 0 and DL.mugshot.capture(ped, cfg.PhotoMaxBytes)
        if photo and current == card.showId then Core.Nui.Send('studentcard:photo', { showId = card.showId, photo = photo }) end
    end)
    if card.presenter == GetPlayerServerId(PlayerId()) then
        local hold = Core.Hold(cfg.Presentation)
        SetTimeout(card.duration, function() Core.Unhold(hold) end)
    end
end)

RegisterNetEvent('daddy_college:studentcard:hide', function(id)
    if id == current then close() end
end)

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:studentcard:' .. name, false, data))
end

-- At Student Affairs: the card for the current role.
Core.Affairs.RegisterAction('studentcard:request', { order = 60, icon = 'fa-solid fa-address-card', label = 'studentcard.target_collect',
    visible = function() return Core.IsStudent() or Core.IsTeacher() or Core.IsSecurity() end,
    run = function()
        local result = call('collect')
        if not result.ok then Core.HandleResult(result, 'studentcard') end
    end })

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then close() end
end)
