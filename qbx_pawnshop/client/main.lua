local config = require 'config.client'
local sharedConfig = require 'config.shared'

---@alias PawnItem {item: string, price: number}

local spawnedNPCs = {} ---@type table<number, number>
local spawnedBlips = {} ---@type table<number, number>
local spawnedZones = {} ---@type table<number, any>
local currentShopId = nil ---@type number? -- Hangi shop'ta olduğumuzu takip etmek için

---@param shopConfig {id: number, name: string, coords: vector3, size: vector3, heading: number, debugPoly: boolean, distance: number, npc: table}
local function spawnPawnNPC(shopConfig)
    if not shopConfig.npc or not shopConfig.npc.enabled then
        return
    end

    lib.requestModel(shopConfig.npc.model, 30000)

    local npc = CreatePed(4, shopConfig.npc.model, shopConfig.npc.coords.x, shopConfig.npc.coords.y,
        shopConfig.npc.coords.z, shopConfig.npc.coords.w, false, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    TaskStartScenarioInPlace(npc, shopConfig.npc.scenario, 0, true)

    spawnedNPCs[shopConfig.id] = npc

    local targetIcon = 'fas fa-ring'
    if shopConfig.type == 'ox_shop' then
        targetIcon = 'fas fa-shopping-basket'
    elseif shopConfig.type == 'money' then
        targetIcon = 'fas fa-money-bill-wave'
    elseif shopConfig.type == 'black' then
        targetIcon = 'fas fa-cannabis'
    end

    -- Target etkileşimi ekle
    exports.ox_target:addLocalEntity(npc, {
        {
            name = 'pawnshop_npc_' .. shopConfig.id,
            event = 'qb-pawnshop:client:openMenu',
            icon = targetIcon,
            label = shopConfig.name,
            distance = 2.0,
            shopId = shopConfig.id -- Shop ID'sini de gönder
        }
    })
end

---@param shopConfig {id: number, name: string, coords: vector3, size: vector3, heading: number, debugPoly: boolean, distance: number, npc: table}
local function addPawnShop(shopConfig)
    if not config.useTarget then
        return lib.zones.box({
            name = 'PawnShop' .. shopConfig.id,
            coords = shopConfig.coords,
            size = shopConfig.size,
            rotation = shopConfig.heading,
            debug = shopConfig.debugPoly,
            onEnter = function()
                currentShopId = shopConfig.id
                lib.registerContext({
                    id = 'open_pawnShopMain',
                    title = shopConfig.name,
                    options = {
                        {
                            title = locale('info.open_pawn'),
                            event = 'qb-pawnshop:client:openMenu',
                            args = { shopId = shopConfig.id }
                        }
                    }
                })
                lib.showContext('open_pawnShopMain')
            end,
            onExit = function()
                currentShopId = nil
                lib.hideContext(false)
            end
        })
    end

    local targetIcon = 'fas fa-ring'
    if shopConfig.type == 'ox_shop' then
        targetIcon = 'fas fa-shopping-basket'
    elseif shopConfig.type == 'money' then
        targetIcon = 'fas fa-money-bill-wave'
    elseif shopConfig.type == 'black' then
        targetIcon = 'fas fa-cannabis'
    end

    return exports.ox_target:addBoxZone({
        coords = shopConfig.coords,
        size = shopConfig.size,
        rotation = shopConfig.heading,
        debug = shopConfig.debugPoly,
        options = {
            {
                name = 'PawnShop' .. shopConfig.id,
                event = 'qb-pawnshop:client:openMenu',
                icon = targetIcon,
                label = shopConfig.name,
                distance = shopConfig.distance,
                shopId = shopConfig.id
            }
        }
    })
end

---@param shopId number
local function removeShop(shopId)
    if spawnedNPCs[shopId] and DoesEntityExist(spawnedNPCs[shopId]) then
        DeleteEntity(spawnedNPCs[shopId])
        spawnedNPCs[shopId] = nil
    end

    if spawnedBlips[shopId] and DoesBlipExist(spawnedBlips[shopId]) then
        RemoveBlip(spawnedBlips[shopId])
        spawnedBlips[shopId] = nil
    end

    if spawnedZones[shopId] then
        if config.useTarget then
            pcall(function() exports.ox_target:removeZone(spawnedZones[shopId]) end)
        else
            if type(spawnedZones[shopId]) == 'table' and spawnedZones[shopId].remove then
                spawnedZones[shopId]:remove()
            end
        end
        spawnedZones[shopId] = nil
    end
end

---@param shopConfig table
local function spawnShop(shopConfig)
    removeShop(shopConfig.id)

    -- Blip oluştur (eğer enabled ise)
    if shopConfig.blip and shopConfig.blip.enabled then
        local blip = AddBlipForCoord(shopConfig.coords.x, shopConfig.coords.y, shopConfig.coords.z)
        SetBlipSprite(blip, shopConfig.blip.sprite or 431)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, shopConfig.blip.scale or 0.7)
        SetBlipAsShortRange(blip, true)
        SetBlipColour(blip, shopConfig.blip.color or 5)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(shopConfig.blipName or shopConfig.name)
        EndTextCommandSetBlipName(blip)
        spawnedBlips[shopConfig.id] = blip
    end

    -- NPC spawn et
    spawnPawnNPC(shopConfig)

    -- Zone ekle
    spawnedZones[shopConfig.id] = addPawnShop(shopConfig)
end

-- Sunucudan güncel override'ları çekip başlat
CreateThread(function()
    local success, overrides = pcall(function()
        return lib.callback.await('qbx_pawnshop:server:getAllShopOverrides', false)
    end)

    if success and overrides then
        for shopId, overrideData in pairs(overrides) do
            local numShopId = tonumber(shopId)
            for _, shopConfig in ipairs(sharedConfig.pawnShops) do
                if shopConfig.id == numShopId then
                    if overrideData.coords then
                        local c = overrideData.coords
                        local x = c.x or c[1]
                        local y = c.y or c[2]
                        local z = c.z or c[3]
                        local w = c.w or c.heading or c[4] or 0.0
                        shopConfig.coords = vector3(x, y, z)
                        shopConfig.heading = w
                        if shopConfig.npc then
                            shopConfig.npc.coords = vector4(x, y, z, w)
                        end
                        shopConfig.isCoordsOverridden = true
                    end
                    if overrideData.prices and shopConfig.pawnItems then
                        for _, pItem in ipairs(shopConfig.pawnItems) do
                            if overrideData.prices[pItem.item] then
                                pItem.price = overrideData.prices[pItem.item]
                            end
                        end
                        shopConfig.isPricesOverridden = true
                    end
                    break
                end
            end
        end
    end

    for i = 1, #sharedConfig.pawnShops do
        spawnShop(sharedConfig.pawnShops[i])
    end
end)

-- Dinamik Konum Senkronizasyonu
RegisterNetEvent('qbx_pawnshop:client:syncLocation', function(shopId, newCoords, isReset)
    local numShopId = tonumber(shopId)
    for i = 1, #sharedConfig.pawnShops do
        local shop = sharedConfig.pawnShops[i]
        if shop.id == numShopId then
            local x = newCoords.x or newCoords[1]
            local y = newCoords.y or newCoords[2]
            local z = newCoords.z or newCoords[3]
            local w = newCoords.w or newCoords.heading or newCoords[4] or 0.0
            shop.coords = vector3(x, y, z)
            shop.heading = w
            if shop.npc then
                shop.npc.coords = vector4(x, y, z, w)
            end
            shop.isCoordsOverridden = not isReset
            spawnShop(shop)
            break
        end
    end
end)

-- Dinamik Fiyat Senkronizasyonu
RegisterNetEvent('qbx_pawnshop:client:syncPrices', function(shopId, newPrices, isReset)
    for i = 1, #sharedConfig.pawnShops do
        local shop = sharedConfig.pawnShops[i]
        if shop.id == shopId then
            if shop.pawnItems and newPrices then
                for _, pItem in ipairs(shop.pawnItems) do
                    if newPrices[pItem.item] then
                        pItem.price = newPrices[pItem.item]
                    end
                end
            end
            break
        end
    end
end)

RegisterNetEvent('qb-pawnshop:client:openMenu', function(data)
    local shopId = data and data.shopId or currentShopId or 1
    currentShopId = shopId
    local currentShop = nil

    for i = 1, #sharedConfig.pawnShops do
        if sharedConfig.pawnShops[i].id == shopId then
            currentShop = sharedConfig.pawnShops[i]
            break
        end
    end

    if not currentShop then
        exports.qbx_core:Notify(locale('error.shop_not_found'), 'error')
        return
    end

    if currentShop.jobRestriction.enabled then
        local PlayerData = exports.qbx_core:GetPlayerData()
        local playerJob = PlayerData.job.name
        local hasAccess = false
        local playerGang = PlayerData.gang and PlayerData.gang.name or nil

        if currentShop.jobRestriction.type == "gang" then
            for i = 1, #currentShop.jobRestriction.allowedGangs do
                if playerGang == currentShop.jobRestriction.allowedGangs[i] then
                    hasAccess = true
                    break
                end
            end
        else
            for i = 1, #currentShop.jobRestriction.allowedJobs do
                if playerJob == currentShop.jobRestriction.allowedJobs[i] then
                    hasAccess = true
                    break
                end
            end
        end

        if not hasAccess then
            exports.qbx_core:Notify(locale('error.wrong_job'), 'error')
            return
        end
    end

    if currentShop.type == "ox_shop" then
        local targetOxShop = currentShop.oxShop or currentShop.key
        exports.ox_inventory:openInventory('shop', { type = targetOxShop })
        return
    end

    -- On-Demand Fiyat Senkronizasyonu: Menü açılırken sunucudan bu dükkana ait en güncel fiyatları anlık çek (pcall ile korumalı)
    local success, livePrices = pcall(function()
        return lib.callback.await('qbx_pawnshop:server:getShopPrices', false, currentShop.id)
    end)
    if success and livePrices and currentShop.pawnItems then
        for _, pItem in ipairs(currentShop.pawnItems) do
            if livePrices[pItem.item] then
                pItem.price = livePrices[pItem.item]
            end
        end
    end

    if not config.useTimes then
        local pawnShop = {
            {
                title = locale('info.sell'),
                description = locale('info.sell_pawn'),
                event = 'qb-pawnshop:client:openPawn',
                args = {
                    pawnItems = currentShop.pawnItems,
                    shopId = currentShop.id
                }
            },
            {
                title = locale('info.bulk_sell'),
                description = locale('info.bulk_sell_pawn'),
                serverEvent = 'qb-pawnshop:server:bulkSell',
                args = {
                    shopId = currentShop.id
                }
            }
        }
        lib.registerContext({
            id = 'open_pawnShop',
            title = currentShop.name,
            options = pawnShop
        })
        lib.showContext('open_pawnShop')
        return
    end

    local gameHour = GetClockHours()
    if gameHour < config.timeOpen or gameHour > config.timeClosed then
        exports.qbx_core:Notify(locale('info.pawn_closed', config.timeOpen, config.timeClosed))
        return
    end

    local pawnShop = {
        {
            title = locale('info.sell'),
            description = locale('info.sell_pawn'),
            event = 'qb-pawnshop:client:openPawn',
            args = {
                pawnItems = currentShop.pawnItems,
                shopId = currentShop.id
            }
        },
        {
            title = locale('info.bulk_sell'),
            description = locale('info.bulk_sell_pawn'),
            serverEvent = 'qb-pawnshop:server:bulkSell',
            args = {
                shopId = currentShop.id
            }
        }
    }
    lib.registerContext({
        id = 'open_pawnShop',
        title = currentShop.name,
        options = pawnShop
    })
    lib.showContext('open_pawnShop')
end)


---@param item {name: string, amount: number, shopId: number}
RegisterNetEvent('qb-pawnshop:client:pawnitems', function(item)
    if item.type == "item" or item.requiredCount then
        local requiredCount = item.requiredCount or 3
        local givenCount = item.givenCount or 1
        local sellAmount = math.floor(item.amount / requiredCount)
        if sellAmount <= 0 then
            exports.qbx_core:Notify(locale('error.negative'), 'error')
            return
        end
        TriggerServerEvent('qb-pawnshop:server:sellPawnItems', item.name, requiredCount * sellAmount, item.shopId,
            item.givenItem, givenCount * sellAmount)
        return
    end
    local input = lib.inputDialog(locale('info.title'), {
        {
            type = 'number',
            label = 'amount',
            placeholder = locale('info.max', item.amount)
        }
    })
    if not input then
        exports.qbx_core:Notify(locale('error.negative'), 'error')
        return
    end
    if not input[1] or input[1] <= 0 then return end
    TriggerServerEvent('qb-pawnshop:server:sellPawnItems', item.name, input[1], item.shopId)
end)


---@param data {pawnItems: PawnItem[], shopId: number}
RegisterNetEvent('qb-pawnshop:client:openPawn', function(data)
    local inventory = exports.ox_inventory:GetPlayerItems()
    local pawnMenu = {}

    for _, invItem in pairs(inventory) do
        for i = 1, #data.pawnItems do
            if invItem.name == data.pawnItems[i].item then
                pawnMenu[#pawnMenu + 1] = {
                    title = invItem.label,
                    description = locale('info.sell_items', data.pawnItems[i].price),
                    event = 'qb-pawnshop:client:pawnitems',
                    args = {
                        name = invItem.name,
                        amount = invItem.amount,
                        shopId = data.shopId
                    }
                }
            end
        end
    end
    lib.registerContext({
        id = 'open_pawnMenu',
        menu = 'open_pawnShop',
        title = locale('info.title'),
        options = pawnMenu
    })
    lib.showContext('open_pawnMenu')
end)

-- NPC, blip ve zone'ları temizle (resource stop olduğunda)
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end

    for _, shop in ipairs(sharedConfig.pawnShops) do
        removeShop(shop.id)
    end
end)