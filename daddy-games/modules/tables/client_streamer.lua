local currentTables = {}
local spawnedEntities = {}

local function deleteEntitySafe(id)
    if spawnedEntities[id] and DoesEntityExist(spawnedEntities[id]) then
        DeleteEntity(spawnedEntities[id])
    end
    spawnedEntities[id] = nil
end

local function updateStreamedProps()
    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)
    local maxDist = Config.Tables.SpawnDistance or 65.0

    for _, tbl in ipairs(currentTables) do
        local tblCoords = vector3(tbl.pos.x, tbl.pos.y, tbl.pos.z)
        local dist = #(pCoords - tblCoords)

        if dist <= maxDist then
            if not spawnedEntities[tbl.id] or not DoesEntityExist(spawnedEntities[tbl.id]) then
                local modelHash = GetHashKey(tbl.model or 'prop_table_tennis')
                RequestModel(modelHash)
                local timeout = 0
                while not HasModelLoaded(modelHash) and timeout < 60 do
                    Wait(10)
                    timeout = timeout + 1
                end
                if HasModelLoaded(modelHash) then
                    local obj = CreateObject(modelHash, tblCoords.x, tblCoords.y, tblCoords.z, false, false, false)
                    SetEntityHeading(obj, tbl.heading or 0.0)
                    SetEntityCoordsNoOffset(obj, tblCoords.x, tblCoords.y, tblCoords.z, false, false, false)
                    FreezeEntityPosition(obj, true)
                    SetEntityAsMissionEntity(obj, true, true)
                    SetEntityCollision(obj, true, true)
                    spawnedEntities[tbl.id] = obj
                end
            end
        else
            if dist > (maxDist + 15.0) and spawnedEntities[tbl.id] then
                deleteEntitySafe(tbl.id)
            end
        end
    end
end

-- Table Sync
RegisterNetEvent('daddy-games:client:syncTables', function(tables)
    local newMap = {}
    for _, tbl in ipairs(tables) do
        newMap[tbl.id] = true
    end

    for id, _ in pairs(spawnedEntities) do
        if not newMap[id] then
            deleteEntitySafe(id)
        end
    end

    currentTables = tables
    updateStreamedProps()
end)

-- Streaming Thread
CreateThread(function()
    while true do
        Wait(1500)
        if #currentTables > 0 then
            updateStreamedProps()
        end
    end
end)

-- Başlangıçta Sunucudan Masaları İste (Restart / Ensure Sonrası Hemen Yükleme)
CreateThread(function()
    Wait(300)
    TriggerServerEvent('daddy-games:server:requestTables')
end)

-- Temizlik
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    for id, _ in pairs(spawnedEntities) do
        deleteEntitySafe(id)
    end
end)

-- =========================================================================
-- 📋 MASA EKLEME / YÖNETİM MENÜLERİ & KOMUTLAR
-- =========================================================================
local function openAddTableMenu()
    local options = {}
    for key, data in pairs(Config.Tables.Types) do
        table.insert(options, {
            title = data.label,
            description = data.description,
            icon = data.icon or 'gamepad',
            onSelect = function()
                StartTablePlacement(key)
            end
        })
    end

    lib.registerContext({
        id = 'daddy_games_addtable_menu',
        title = '🎮 Yeni Oyun Masası Ekle',
        options = options
    })

    lib.showContext('daddy_games_addtable_menu')
end

local function openTableListMenu()
    local ped = PlayerPedId()
    local pCoords = GetEntityCoords(ped)

    local sorted = {}
    for _, tbl in ipairs(currentTables) do
        local tblCoords = vector3(tbl.pos.x, tbl.pos.y, tbl.pos.z)
        local dist = #(pCoords - tblCoords)
        local typeInfo = Config.Tables.Types[tbl.type] or { label = tbl.model or 'Masa', icon = 'circle-dot' }
        table.insert(sorted, {
            id = tbl.id,
            type = tbl.type,
            model = tbl.model,
            pos = tblCoords,
            heading = tbl.heading,
            dist = dist,
            label = typeInfo.label,
            icon = typeInfo.icon
        })
    end

    table.sort(sorted, function(a, b) return a.dist < b.dist end)

    local options = {}
    for _, tbl in ipairs(sorted) do
        table.insert(options, {
            title = tbl.label,
            description = ('Mesafe: %.1fm | X: %.1f, Y: %.1f, Z: %.1f | Açı: %.0f°'):format(
                tbl.dist, tbl.pos.x, tbl.pos.y, tbl.pos.z, tbl.heading
            ),
            icon = tbl.icon,
            onSelect = function()
                lib.registerContext({
                    id = 'daddy_games_action_' .. tbl.id,
                    title = tbl.label .. ' Yönetimi',
                    menu = 'daddy_games_list_menu',
                    options = {
                        {
                            title = 'Masaya Işınlan (TP)',
                            icon = 'location-dot',
                            onSelect = function()
                                pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
                                SetEntityCoords(PlayerPedId(), tbl.pos.x, tbl.pos.y, tbl.pos.z + 1.0, false, false, false, false)
                                SetEntityHeading(PlayerPedId(), (tbl.heading + 180.0) % 360.0)
                            end
                        },
                        {
                            title = 'Koordinatı Kopyala (Lua Formatı)',
                            icon = 'copy',
                            onSelect = function()
                                local snippet = ('{ pos = vector3(%.2f, %.2f, %.2f), heading = %.2f, model = "%s" },'):format(
                                    tbl.pos.x, tbl.pos.y, tbl.pos.z, tbl.heading, tbl.model
                                )
                                lib.setClipboard(snippet)
                                lib.notify({ title = 'Kopyalandı', description = 'Masa koordinatları panoya kopyalandı.', type = 'success' })
                            end
                        },
                        {
                            title = 'Masayı Sil',
                            icon = 'trash-can',
                            iconColor = '#ef4444',
                            onSelect = function()
                                local alert = lib.alertDialog({
                                    header = 'Masa Silinsin mi?',
                                    content = 'Bu masa kalıcı olarak sunucudan silinecektir. Onaylıyor musunuz?',
                                    centered = true,
                                    cancel = true
                                })
                                if alert == 'confirm' then
                                    TriggerServerEvent('daddy-games:server:deleteTable', tbl.id)
                                end
                            end
                        }
                    }
                })
                lib.showContext('daddy_games_action_' .. tbl.id)
            end
        })
    end

    if #options == 0 then
        options[1] = {
            title = 'Hiç masa bulunamadı',
            description = 'Henüz hiç oyun masası eklenmemiş.',
            disabled = true
        }
    end

    lib.registerContext({
        id = 'daddy_games_list_menu',
        title = ('Oyun Masaları (%d Adet)'):format(#sorted),
        options = options
    })

    lib.showContext('daddy_games_list_menu')
end

-- Commands
RegisterCommand('addtable', function(_, args)
    lib.callback('daddy-games:server:isAdmin', false, function(isAdmin)
        if not isAdmin then
            lib.notify({ type = 'error', title = 'Yetkisiz', description = 'Bu komutu kullanma yetkiniz yok.' })
            return
        end

        local argType = args[1] and tostring(args[1]):lower()
        if argType == 'airhockey' or argType == 'hockey' or argType == 'hokey' then
            StartTablePlacement('airhockey')
        elseif argType == 'pingpong' or argType == 'pinpon' or argType == 'tenis' then
            StartTablePlacement('pingpong')
        elseif argType == 'pool' or argType == 'bilardo' then
            StartTablePlacement('pool')
        elseif argType == 'pool3b' or argType == 'klasik' then
            StartTablePlacement('pool3b')
        elseif argType == 'poolcue' or argType == 'istaka' or argType == 'istakastand' then
            StartTablePlacement('poolcue')
        else
            openAddTableMenu()
        end
    end)
end, false)

RegisterCommand('listtables', function()
    lib.callback('daddy-games:server:isAdmin', false, function(isAdmin)
        if not isAdmin then
            lib.notify({ type = 'error', title = 'Yetkisiz', description = 'Bu komutu kullanma yetkiniz yok.' })
            return
        end
        openTableListMenu()
    end)
end, false)

RegisterCommand('gameprops', function()
    lib.callback('daddy-games:server:isAdmin', false, function(isAdmin)
        if not isAdmin then
            lib.notify({ type = 'error', title = 'Yetkisiz', description = 'Bu komutu kullanma yetkiniz yok.' })
            return
        end
        openTableListMenu()
    end, false)
end, false)

RegisterCommand('removetable', function()
    lib.callback('daddy-games:server:isAdmin', false, function(isAdmin)
        if not isAdmin then
            lib.notify({ type = 'error', title = 'Yetkisiz', description = 'Bu komutu kullanma yetkiniz yok.' })
            return
        end

        local ped = PlayerPedId()
        local pCoords = GetEntityCoords(ped)
        local closestTable, closestDist = nil, 999.0

        for _, tbl in ipairs(currentTables) do
            local tblCoords = vector3(tbl.pos.x, tbl.pos.y, tbl.pos.z)
            local dist = #(pCoords - tblCoords)
            if dist < closestDist then
                closestDist = dist
                closestTable = tbl
            end
        end

        if closestTable and closestDist <= 5.0 then
            local typeInfo = Config.Tables.Types[closestTable.type] or { label = closestTable.model }
            local alert = lib.alertDialog({
                header = 'En Yakın Masayı Sil',
                content = ('Yakınınızdaki **%s** (Mesafe: %.1fm) silinsin mi?'):format(typeInfo.label, closestDist),
                centered = true,
                cancel = true
            })
            if alert == 'confirm' then
                TriggerServerEvent('daddy-games:server:deleteTable', closestTable.id)
            end
        else
            lib.notify({ type = 'error', title = 'Bulunamadı', description = '5 metre yakınınızda silinecek masa yok.' })
        end
    end)
end, false)

-- Exports
exports('GetTablesByType', function(typeKey)
    local result = {}
    for _, tbl in ipairs(currentTables) do
        if tbl.type == typeKey then
            table.insert(result, tbl)
        end
    end
    return result
end)

exports('GetAllTables', function()
    return currentTables
end)
