-- ═══════════════════════════════════════════════════════
--  Daddy Loading Screen — Client Script
--  /loadingedit komutu ve admin panel NUI yönetimi
-- ═══════════════════════════════════════════════════════

local isAdminOpen = false
local CLIENT_DEBUG = false
local pendingSave = nil
local saveSequence = 0

local function DebugPrint(msg)
    if CLIENT_DEBUG then
        print(msg)
    end
end

-- ── /loadingedit komutu ────────────────────────────────
-- Yetki kontrolü sunucu tarafında yapılır (daddy:requestConfig handler'ında)
RegisterCommand('loadingedit', function()
    if isAdminOpen then return end
    TriggerServerEvent('daddy:requestConfig')
end, false) -- false = komut herkese görünür, yetki kontrolü server'da

-- ── Sunucudan config geldiğinde panel aç ──────────────
RegisterNetEvent('daddy:sendConfig')
AddEventHandler('daddy:sendConfig', function(config, serverMaxClients, locales, language)
    isAdminOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        config = config,
        serverMaxClients = serverMaxClients or 128,
        locales = locales or {},
        language = language or 'tr'
    })
end)

-- ── NUI Callback: Panel kapatma ───────────────────────
RegisterNUICallback('closeAdmin', function(data, cb)
    isAdminOpen = false
    SetNuiFocus(false, false)
    cb({ ok = true })
end)

-- ── NUI Callback: Config kaydetme ─────────────────────
RegisterNUICallback('saveConfig', function(data, cb)
    if pendingSave then
        cb({ success = false, error = 'busy' })
        return
    end

    saveSequence = saveSequence + 1
    local requestId = saveSequence
    pendingSave = { id = requestId, callback = cb }
    TriggerServerEvent('daddy:saveConfig', data)

    SetTimeout(5000, function()
        if not pendingSave or pendingSave.id ~= requestId then return end
        pendingSave.callback({ success = false, error = 'timeout' })
        pendingSave = nil
    end)
end)

-- ── Sunucudan kaydetme onayı ──────────────────────────
RegisterNetEvent('daddy:configSaved')
AddEventHandler('daddy:configSaved', function(success, errorCode)
    if pendingSave then
        pendingSave.callback({ success = success == true, error = errorCode })
        pendingSave = nil
    end

    if success then
        DebugPrint('[Daddy] Config basariyla kaydedildi.')
    else
        DebugPrint('[Daddy] HATA: Config kaydedilemedi.')
    end
end)
