-- The menu: opened from a point, a command or an item (Config.Access), every call goes to the server through 'call'.
local isOpen = false

local function close()
    if not isOpen then return end
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function open(screen)
    if isOpen then return close() end
    if IsEntityDead(PlayerPedId()) or IsPedCuffed(PlayerPedId()) then return end
    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', lang = Config.Locale, screen = screen, map = Config.Map })
end

exports('open', open)
-- the points (access.lua) and the item (server) open it
RegisterNetEvent('daddy_gangs:open')
AddEventHandler('daddy_gangs:open', function() open() end)

if Config.Access.Command then
    RegisterCommand(Config.Access.Command, function() open() end, false)
end

if Config.Access.AdminCommand then
    RegisterCommand(Config.Access.AdminCommand, function()
        if isOpen then return close() end
        if not lib.callback.await('daddy_gangs:isAdmin', false) then return lib.notify({ type = 'error', description = L('no_access') }) end
        open('admin')
    end, false)
end

RegisterNuiCallback('close', function(_, cb)
    close()
    cb({})
end)

-- { name, body }: the answer of the server as it is; a write that opened something in the game closes the menu
RegisterNuiCallback('call', function(data, cb)
    if type(data) ~= 'table' or type(data.name) ~= 'string' then return cb({ ok = false, error = 'invalid' }) end
    local result = lib.callback.await('daddy_gangs:call', false, data.name, data.body)
    cb(result)
    if type(result) == 'table' and result.close then close() end
end)

-- something changed for the gang: an open menu loads again
RegisterNetEvent('daddy_gangs:refresh', function()
    if isOpen then SendNUIMessage({ action = 'refresh' }) end
end)

RegisterNetEvent('daddy_gangs:chat', function()
    if isOpen then SendNUIMessage({ action = 'chat' }) end
end)

-- qs-inventory opens its stashes from the client
RegisterNetEvent('daddy_gangs:openQsStash', function(id, slots, weight)
    TriggerServerEvent('inventory:server:OpenInventory', 'stash', id, { maxweight = weight, slots = slots })
    TriggerEvent('inventory:client:SetCurrentStash', id)
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and isOpen then SetNuiFocus(false, false) end
end)
