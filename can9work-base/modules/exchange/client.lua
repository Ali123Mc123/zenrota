local spawnedPeds = {}

---@description Start the exchange process with progress bar
---@param deal table
---@param pedCoords vector3
local function startExchange(deal, pedCoords)
    local playerPed = cache.ped
    if #(GetEntityCoords(playerPed) - pedCoords) > 5.0 then
        lib.notify({
            title = 'Hata',
            description = 'Çok uzaktasınız!',
            type = 'error'
        })
        return
    end

    local input = lib.inputDialog(deal.label .. ' - Takas', {
        { type = 'number', label = 'Kullanılacak Eşya Miktarı', description = 'Envanterinizden kaç adet kullanmak istiyorsunuz?', icon = 'box', default = deal.requiredItems[1].count, min = deal.requiredItems[1].count },
    })

    if not input or not input[1] then return end
    local multiplier = tonumber(input[1])

    if lib.progressBar({
        duration = deal.duration,
        label = string.format('%s x%s yapılıyor...', deal.label, multiplier),
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false
        },
        anim = {
            dict = 'missheistdockssetup1ig_5@base',
            clip = 'workers_talking_base_workers'
        },
    }) then
        TriggerServerEvent('can9work-base:server:executeExchange', deal.id, multiplier)
    else
        lib.notify({
            title = 'İptal Edildi',
            description = 'İşlem iptal edildi.',
            type = 'error'
        })
    end
end

---@description Create the ped and add target options
---@param config table
local function createExchangePed(config)
    local model = type(config.model) == 'string' and GetHashKey(config.model) or config.model
    lib.requestModel(model)
    
    pcall(function() exports['FeloxAC']:CreatePed(model) end) --[[FeloxAC:auto]]
    local ped = CreatePed(4, model, config.coords.x, config.coords.y, config.coords.z - 1.0, config.coords.w, false, false)
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    
    if config.scenario then
        TaskStartScenarioInPlace(ped, config.scenario, 0, true)
    end

    local options = {}
    for i, deal in ipairs(config.deals) do
        options[#options + 1] = {
            name = 'exchange_' .. deal.id,
            label = deal.label,
            icon = config.target.icon,
            distance = config.target.distance,
            onSelect = function()
                startExchange(deal, config.coords.xyz)
            end
        }
    end

    exports.ox_target:addLocalEntity(ped, options)
    spawnedPeds[#spawnedPeds + 1] = ped
end

-- Initialization
CreateThread(function()
    if not Settings or not Settings.Exchange or not Settings.Exchange.Peds then 
        print('^1[Exchange]^7 Settings not found on client!')
        return 
    end
    
    for _, pedConfig in ipairs(Settings.Exchange.Peds) do
        createExchangePed(pedConfig)
    end
end)

-- Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for _, ped in ipairs(spawnedPeds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
end)
