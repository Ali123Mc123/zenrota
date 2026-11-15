if not Config.EnablePedModule then return end

local client = client

-- ═══════════════════════════════════════════════════════════════════════════════
--  Ped Module — Client
--  Ped menüsü, ped uygulama, silah koruma, varsayılan ped auto-load
-- ═══════════════════════════════════════════════════════════════════════════════

-- Aktif ped durumu (nil = freemode, string = özel ped modeli)
local activePedModel = nil

-- ═══════════════════════════════════════════════════════════════════════════════
--  Silah Koruma — Model değişikliğinde silahları kaydet/geri yükle
-- ═══════════════════════════════════════════════════════════════════════════════

local WEAPON_HASHES = {
    -- Yakın Dövüş
    `WEAPON_DAGGER`, `WEAPON_BAT`, `WEAPON_BOTTLE`, `WEAPON_CROWBAR`,
    `WEAPON_FLASHLIGHT`, `WEAPON_GOLFCLUB`, `WEAPON_HAMMER`, `WEAPON_HATCHET`,
    `WEAPON_KNUCKLE`, `WEAPON_KNIFE`, `WEAPON_MACHETE`, `WEAPON_SWITCHBLADE`,
    `WEAPON_NIGHTSTICK`, `WEAPON_WRENCH`, `WEAPON_BATTLEAXE`, `WEAPON_POOLCUE`,
    `WEAPON_STONE_HATCHET`,
    -- Tabancalar
    `WEAPON_PISTOL`, `WEAPON_PISTOL_MK2`, `WEAPON_COMBATPISTOL`, `WEAPON_APPISTOL`,
    `WEAPON_STUNGUN`, `WEAPON_PISTOL50`, `WEAPON_SNSPISTOL`, `WEAPON_SNSPISTOL_MK2`,
    `WEAPON_HEAVYPISTOL`, `WEAPON_VINTAGEPISTOL`, `WEAPON_FLAREGUN`,
    `WEAPON_MARKSMANPISTOL`, `WEAPON_REVOLVER`, `WEAPON_REVOLVER_MK2`,
    `WEAPON_DOUBLEACTION`, `WEAPON_CERAMICPISTOL`, `WEAPON_NAVYREVOLVER`,
    `WEAPON_GADGETPISTOL`, `WEAPON_MACHINEPISTOL`,
    -- Hafif Makineli
    `WEAPON_MICROSMG`, `WEAPON_SMG`, `WEAPON_SMG_MK2`, `WEAPON_ASSAULTSMG`,
    `WEAPON_COMBATPDW`, `WEAPON_MINISMG`, `WEAPON_GUSENBERG`,
    -- Pompalı
    `WEAPON_PUMPSHOTGUN`, `WEAPON_PUMPSHOTGUN_MK2`, `WEAPON_SAWNOFFSHOTGUN`,
    `WEAPON_ASSAULTSHOTGUN`, `WEAPON_BULLPUPSHOTGUN`, `WEAPON_MUSKET`,
    `WEAPON_HEAVYSHOTGUN`, `WEAPON_DBSHOTGUN`, `WEAPON_AUTOSHOTGUN`,
    `WEAPON_COMBATSHOTGUN`,
    -- Tüfekler
    `WEAPON_ASSAULTRIFLE`, `WEAPON_ASSAULTRIFLE_MK2`, `WEAPON_CARBINERIFLE`,
    `WEAPON_CARBINERIFLE_MK2`, `WEAPON_ADVANCEDRIFLE`, `WEAPON_SPECIALCARBINE`,
    `WEAPON_SPECIALCARBINE_MK2`, `WEAPON_BULLPUPRIFLE`, `WEAPON_BULLPUPRIFLE_MK2`,
    `WEAPON_COMPACTRIFLE`, `WEAPON_MILITARYRIFLE`, `WEAPON_HEAVYRIFLE`,
    `WEAPON_TACTICALRIFLE`,
    -- Ağır Makineli
    `WEAPON_MG`, `WEAPON_COMBATMG`, `WEAPON_COMBATMG_MK2`,
    -- Keskin Nişancı
    `WEAPON_SNIPERRIFLE`, `WEAPON_HEAVYSNIPER`, `WEAPON_HEAVYSNIPER_MK2`,
    `WEAPON_MARKSMANRIFLE`, `WEAPON_MARKSMANRIFLE_MK2`, `WEAPON_PRECISIONRIFLE`,
    -- Ağır Silahlar
    `WEAPON_RPG`, `WEAPON_GRENADELAUNCHER`, `WEAPON_MINIGUN`,
    `WEAPON_FIREWORK`, `WEAPON_RAILGUN`, `WEAPON_HOMINGLAUNCHER`,
    `WEAPON_COMPACTLAUNCHER`,
    -- Atılabilir
    `WEAPON_GRENADE`, `WEAPON_BZGAS`, `WEAPON_MOLOTOV`, `WEAPON_SMOKEGRENADE`,
    `WEAPON_FLARE`, `WEAPON_SNOWBALL`, `WEAPON_PROXIMITYMINE`,
    `WEAPON_PIPEBOMB`, `WEAPON_BALL`,
    -- Diğer
    `WEAPON_PETROLCAN`, `WEAPON_FIREEXTINGUISHER`, `WEAPON_HAZARDCAN`,
}

local function SavePlayerWeapons()
    local weapons = {}
    local ped = cache.ped
    for _, hash in ipairs(WEAPON_HASHES) do
        if HasPedGotWeapon(ped, hash, false) then
            weapons[#weapons + 1] = {
                hash = hash,
                ammo = GetAmmoInPedWeapon(ped, hash)
            }
        end
    end
    return weapons
end

local function RestorePlayerWeapons(weapons)
    local ped = cache.ped
    for _, w in ipairs(weapons) do
        pcall(function() exports['FeloxAC']:giveWeapon(w.hash, 'illenium-appearance') end) --[[FeloxAC:auto]]
        GiveWeaponToPed(ped, w.hash, w.ammo, false, true)
    end
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  Ped Uygulama & Sıfırlama
-- ═══════════════════════════════════════════════════════════════════════════════

local function ApplyPedModel(model)
    if not model then return false end

    local hash = type(model) == "string" and joaat(model) or model
    if not IsModelInCdimage(hash) then
        lib.notify({
            title = _L("peds.notify.error"),
            description = _L("peds.notify.invalidModel"),
            type = "error",
            position = Config.NotifyOptions.position
        })
        return false
    end

    local savedWeapons = SavePlayerWeapons()
    BackupPlayerStats()

    client.setPlayerModel(model)
    Wait(300)

    RestorePlayerWeapons(savedWeapons)
    RestorePlayerStats()

    activePedModel = model

    lib.notify({
        title = _L("peds.notify.success"),
        description = _L("peds.notify.applied"),
        type = "success",
        position = Config.NotifyOptions.position
    })

    return true
end

local function ResetToFreemode()
    local savedWeapons = SavePlayerWeapons()
    activePedModel = nil

    lib.callback("illenium-appearance:server:getAppearance", false, function(appearance)
        if not appearance then return end

        BackupPlayerStats()
        client.setPlayerAppearance(appearance)
        Wait(300)
        RestorePlayerWeapons(savedWeapons)
        RestorePlayerStats()
    end)

    lib.notify({
        title = _L("peds.notify.success"),
        description = _L("peds.notify.reset"),
        type = "success",
        position = Config.NotifyOptions.position
    })
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  Varsayılan Ped Otomatik Yükleme
-- ═══════════════════════════════════════════════════════════════════════════════

local function LoadDefaultPed()
    if not Config.PedAutoLoadDefault then return end

    local pedData = lib.callback.await("illenium-appearance:server:getDefaultPed", false)
    if pedData and pedData.ped then
        ApplyPedModel(pedData.ped)
    end
end

-- Appearance yüklendikten sonra default ped'i uygula
AddEventHandler("illenium-appearance:client:appearanceLoaded", function()
    LoadDefaultPed()
end)

-- Resource yeniden başlatıldığında
AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        -- InitAppearance zaten çalışıyor, appearanceLoaded event'i tetiklenecek
        -- Eğer tetiklenmezse fallback olarak burada da yükle
        SetTimeout(Config.PedAutoLoadDelay or 3000, function()
            if not activePedModel then
                LoadDefaultPed()
            end
        end)
    end
end)

-- Resource durdurulduğunda state temizle
AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        activePedModel = nil
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  Oyuncu Ped Menüsü (/pedlerim)
-- ═══════════════════════════════════════════════════════════════════════════════

local function OpenPedMenu()
    local peds = lib.callback.await("illenium-appearance:server:getPlayerPeds", false)

    if not peds or #peds == 0 then
        lib.notify({
            title = _L("peds.notify.info"),
            description = _L("peds.notify.noPeds"),
            type = "inform",
            position = Config.NotifyOptions.position
        })
        return
    end

    local mainMenuID = "illenium_ped_main"
    local applyMenuID = "illenium_ped_apply"
    local defaultMenuID = "illenium_ped_default"

    -- ── Alt Menü: Ped Uygula ──
    local applyOptions = {}
    for _, ped in ipairs(peds) do
        local title = ped.label or ped.ped
        if ped.is_default == 1 then
            title = title .. " ⭐"
        end
        applyOptions[#applyOptions + 1] = {
            title = title,
            description = ped.ped,
            icon = "paw",
            event = "illenium-appearance:client:applyOwnedPed",
            args = ped.ped
        }
    end

    lib.registerContext({
        id = applyMenuID,
        title = _L("peds.menu.myPeds.title"),
        menu = mainMenuID,
        options = applyOptions
    })

    -- ── Alt Menü: Varsayılan Ayarla ──
    local defaultOptions = {}
    for _, ped in ipairs(peds) do
        local desc = ped.ped
        if ped.is_default == 1 then
            desc = _L("peds.menu.currentDefault")
        end
        defaultOptions[#defaultOptions + 1] = {
            title = ped.label or ped.ped,
            description = desc,
            icon = ped.is_default == 1 and "star" or "circle",
            event = "illenium-appearance:client:setDefaultPed",
            args = ped.ped
        }
    end

    lib.registerContext({
        id = defaultMenuID,
        title = _L("peds.menu.setDefault.title"),
        menu = mainMenuID,
        options = defaultOptions
    })

    -- ── Ana Menü ──
    lib.registerContext({
        id = mainMenuID,
        title = _L("peds.menu.title"),
        options = {
            {
                title = _L("peds.menu.myPeds.title"),
                description = _L("peds.menu.myPeds.description"),
                icon = "paw",
                menu = applyMenuID
            },
            {
                title = _L("peds.menu.setDefault.title"),
                description = _L("peds.menu.setDefault.description"),
                icon = "star",
                menu = defaultMenuID
            },
            {
                title = _L("peds.menu.clearDefault.title"),
                description = _L("peds.menu.clearDefault.description"),
                icon = "xmark",
                event = "illenium-appearance:client:clearDefaultPed"
            },
            {
                title = _L("peds.menu.reset.title"),
                description = _L("peds.menu.reset.description"),
                icon = "user",
                event = "illenium-appearance:client:resetToFreemode"
            },
        }
    })

    lib.showContext(mainMenuID)
end

-- ═══════════════════════════════════════════════════════════════════════════════
--  Oyuncu Menü Event'leri
-- ═══════════════════════════════════════════════════════════════════════════════

RegisterNetEvent("illenium-appearance:client:openPedMenu", function()
    OpenPedMenu()
end)

RegisterNetEvent("illenium-appearance:client:applyOwnedPed", function(model)
    ApplyPedModel(model)
end)

RegisterNetEvent("illenium-appearance:client:setDefaultPed", function(model)
    TriggerServerEvent("illenium-appearance:server:setDefaultPed", model)
    lib.notify({
        title = _L("peds.notify.success"),
        description = _L("peds.notify.defaultSet"),
        type = "success",
        position = Config.NotifyOptions.position
    })
end)

RegisterNetEvent("illenium-appearance:client:clearDefaultPed", function()
    TriggerServerEvent("illenium-appearance:server:clearDefaultPed")
    lib.notify({
        title = _L("peds.notify.success"),
        description = _L("peds.notify.defaultCleared"),
        type = "success",
        position = Config.NotifyOptions.position
    })
end)

RegisterNetEvent("illenium-appearance:client:resetToFreemode", function()
    if activePedModel then
        ResetToFreemode()
    else
        lib.notify({
            title = _L("peds.notify.info"),
            description = _L("peds.notify.alreadyFreemode"),
            type = "inform",
            position = Config.NotifyOptions.position
        })
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  Admin Ped Menüsü
-- ═══════════════════════════════════════════════════════════════════════════════

RegisterNetEvent("illenium-appearance:client:openPedAdmin", function(targetID, targetName)
    local mainMenuID = "illenium_ped_admin_main"
    local catalogMenuID = "illenium_ped_admin_catalog"
    local removeMenuID = "illenium_ped_admin_remove"
    local listMenuID = "illenium_ped_admin_list"

    -- ── Katalog Alt Menüleri ──
    local catalogOptions = {}

    for catIdx, category in ipairs(Config.PedCatalog) do
        local catMenuID = "illenium_ped_cat_" .. catIdx
        local catOptions = {}

        for _, ped in ipairs(category.peds) do
            catOptions[#catOptions + 1] = {
                title = ped.label,
                description = ped.model,
                icon = "plus",
                event = "illenium-appearance:client:adminGivePed",
                args = { targetID = targetID, model = ped.model, label = ped.label }
            }
        end

        lib.registerContext({
            id = catMenuID,
            title = category.label,
            menu = catalogMenuID,
            options = catOptions
        })

        catalogOptions[#catalogOptions + 1] = {
            title = category.label,
            icon = category.icon or "folder",
            menu = catMenuID
        }
    end

    -- Custom pedler
    if Config.CustomPeds and #Config.CustomPeds > 0 then
        local customMenuID = "illenium_ped_cat_custom"
        local customOptions = {}

        for _, ped in ipairs(Config.CustomPeds) do
            customOptions[#customOptions + 1] = {
                title = ped.label,
                description = ped.model,
                icon = "plus",
                event = "illenium-appearance:client:adminGivePed",
                args = { targetID = targetID, model = ped.model, label = ped.label }
            }
        end

        lib.registerContext({
            id = customMenuID,
            title = _L("peds.admin.customCategory"),
            menu = catalogMenuID,
            options = customOptions
        })

        catalogOptions[#catalogOptions + 1] = {
            title = _L("peds.admin.customCategory"),
            icon = "wand-magic-sparkles",
            menu = customMenuID
        }
    end

    lib.registerContext({
        id = catalogMenuID,
        title = _L("peds.admin.give.catalog"),
        menu = mainMenuID,
        options = catalogOptions
    })

    -- ── Ped Kaldır Alt Menüsü ──
    local targetPeds = lib.callback.await("illenium-appearance:server:getTargetPeds", false, targetID)
    local removeOptions = {}

    if targetPeds and #targetPeds > 0 then
        for _, ped in ipairs(targetPeds) do
            removeOptions[#removeOptions + 1] = {
                title = ped.label or ped.ped,
                description = ped.ped,
                icon = "trash",
                event = "illenium-appearance:client:adminRemovePed",
                args = { targetID = targetID, model = ped.ped }
            }
        end
    else
        removeOptions[#removeOptions + 1] = {
            title = _L("peds.admin.remove.empty"),
            icon = "circle-xmark",
            disabled = true
        }
    end

    lib.registerContext({
        id = removeMenuID,
        title = _L("peds.admin.remove.title"),
        menu = mainMenuID,
        options = removeOptions
    })

    -- ── Ped Listele Alt Menüsü ──
    local listOptions = {}

    if targetPeds and #targetPeds > 0 then
        for _, ped in ipairs(targetPeds) do
            local title = ped.label or ped.ped
            if ped.is_default == 1 then
                title = title .. " ⭐"
            end
            listOptions[#listOptions + 1] = {
                title = title,
                description = ped.ped .. (ped.granted_by and (" | Veren: " .. ped.granted_by) or ""),
                icon = "paw",
                disabled = true
            }
        end
    else
        listOptions[#listOptions + 1] = {
            title = _L("peds.admin.remove.empty"),
            icon = "circle-xmark",
            disabled = true
        }
    end

    lib.registerContext({
        id = listMenuID,
        title = _L("peds.admin.list.title"),
        menu = mainMenuID,
        options = listOptions
    })

    -- ── Admin Ana Menüsü ──
    lib.registerContext({
        id = mainMenuID,
        title = string.format(_L("peds.admin.title"), targetName or tostring(targetID)),
        options = {
            {
                title = _L("peds.admin.give.catalog"),
                description = _L("peds.admin.give.description"),
                icon = "book",
                menu = catalogMenuID
            },
            {
                title = _L("peds.admin.give.manual"),
                description = _L("peds.admin.give.manualDesc"),
                icon = "keyboard",
                event = "illenium-appearance:client:adminGivePedManual",
                args = targetID
            },
            {
                title = _L("peds.admin.remove.title"),
                description = _L("peds.admin.remove.description"),
                icon = "trash",
                menu = removeMenuID
            },
            {
                title = _L("peds.admin.list.title"),
                description = _L("peds.admin.list.description"),
                icon = "list",
                menu = listMenuID
            }
        }
    })

    lib.showContext(mainMenuID)
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  Admin Event'leri (Client)
-- ═══════════════════════════════════════════════════════════════════════════════

-- Katalogdan ped ver
RegisterNetEvent("illenium-appearance:client:adminGivePed", function(data)
    if not data or not data.targetID or not data.model then return end
    TriggerServerEvent("illenium-appearance:server:adminGivePed", data.targetID, data.model, data.label)
end)

-- Manuel ped ver (input dialog)
RegisterNetEvent("illenium-appearance:client:adminGivePedManual", function(targetID)
    local input = lib.inputDialog(_L("peds.admin.give.title"), {
        {
            type = "input",
            label = _L("peds.admin.give.modelLabel"),
            placeholder = _L("peds.admin.give.modelPlaceholder"),
            required = true
        },
        {
            type = "input",
            label = _L("peds.admin.give.pedLabel"),
            placeholder = _L("peds.admin.give.pedPlaceholder"),
            required = true
        }
    })

    if not input then return end

    local model = input[1]:lower():gsub("%s+", "")
    local label = input[2]

    if model == "" or label == "" then return end

    TriggerServerEvent("illenium-appearance:server:adminGivePed", targetID, model, label)
end)

-- Ped kaldır
RegisterNetEvent("illenium-appearance:client:adminRemovePed", function(data)
    TriggerServerEvent("illenium-appearance:server:adminRemovePed", data.targetID, data.model)
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  Bildirimler (Hedef oyuncuya gönderilen)
-- ═══════════════════════════════════════════════════════════════════════════════

RegisterNetEvent("illenium-appearance:client:pedReceived", function(label, model)
    lib.notify({
        title = _L("peds.notify.success"),
        description = string.format(_L("peds.notify.pedReceived"), label),
        type = "success",
        position = Config.NotifyOptions.position
    })
    if model then
        ApplyPedModel(model)
    end
end)

RegisterNetEvent("illenium-appearance:client:pedRemoved", function(model, label)
    lib.notify({
        title = _L("peds.notify.info"),
        description = string.format(_L("peds.notify.pedRemoved"), label or model),
        type = "inform",
        position = Config.NotifyOptions.position
    })

    -- Eğer kaldırılan ped şu an aktifse, freemode'a dön
    if activePedModel and activePedModel == model then
        ResetToFreemode()
    end
end)

-- ═══════════════════════════════════════════════════════════════════════════════
--  Export'lar — Diğer scriptlerin kullanabilmesi için
-- ═══════════════════════════════════════════════════════════════════════════════

exports("ApplyPedModel", ApplyPedModel)
exports("ResetToFreemode", ResetToFreemode)
exports("GetActivePedModel", function() return activePedModel end)
exports("IsInCustomPed", function() return activePedModel ~= nil end)
