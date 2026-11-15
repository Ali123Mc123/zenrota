-- Rangers who sell the camp gear, with a blip each; the counter is the camp NUI page.
local shop = Config.Shop
local peds = {}
local opened = false

local function close()
    if not opened then return end
    opened = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

local function open()
    if opened then return end
    local data = lib.callback.await('daddy_camp:shop', false)
    if not data then return Client.notify('camp.too_far', 'error') end
    opened = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', view = 'shop', locale = DL.locale.table(), language = DL.locale.language(), payload = data })
    local from = GetEntityCoords(PlayerPedId())
    CreateThread(function()
        while opened do
            if #(GetEntityCoords(PlayerPedId()) - from) > 4.0 or IsEntityDead(PlayerPedId()) then close() end
            Wait(500)
        end
    end)
end

RegisterNUICallback('close', function(_, cb)
    close()
    cb({ ok = true })
end)

RegisterNUICallback('checkout', function(data, cb)
    if not opened or type(data) ~= 'table' then return cb({ ok = false, error = 'not_now' }) end
    cb(lib.callback.await('daddy_camp:checkout', false, data.cart, data.account) or { ok = false, error = 'not_now' })
end)

local function spawn(i, point)
    local hash = joaat(shop.Ped)
    if not Client.load(hash) then return end
    pcall(function() exports['FeloxAC']:CreatePed(hash) end) --[[FeloxAC:auto]]
    local ped = CreatePed(4, hash, point.x, point.y, point.z - 1.0, point.w, false, false)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetModelAsNoLongerNeeded(hash)
    peds[i] = ped
    DL.target.addEntity('camp_shop_' .. i, ped, { distance = 2.5, options = { { label = Client.t('camp.opt_shop'), icon = 'fa-solid fa-store', onSelect = open } } })
end

CreateThread(function()
    if not shop.Enabled then return end
    for _, point in ipairs(shop.Points) do
        local blip = AddBlipForCoord(point.x, point.y, point.z)
        SetBlipSprite(blip, shop.Blip.sprite)
        SetBlipColour(blip, shop.Blip.colour)
        SetBlipScale(blip, shop.Blip.scale)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(Client.t('camp.shop_blip'))
        EndTextCommandSetBlipName(blip)
    end
    while true do
        local me = GetEntityCoords(PlayerPedId())
        for i, point in ipairs(shop.Points) do
            local near = #(me - point.xyz) < 80.0
            if near and not peds[i] then spawn(i, point)
            elseif not near and peds[i] then
                DL.target.remove('camp_shop_' .. i)
                DeleteEntity(peds[i])
                peds[i] = nil
            end
        end
        Wait(2000)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= DL.resource then return end
    if opened then SetNuiFocus(false, false) end
    for _, ped in pairs(peds) do if DoesEntityExist(ped) then DeleteEntity(ped) end end
end)
