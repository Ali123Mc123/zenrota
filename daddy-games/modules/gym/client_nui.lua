-- =========================================================================
-- daddy-games :: gym :: client_nui.lua
-- NUI koprusu: odak yonetimi, mesaj yonlendirme ve geri cagrimlar.
--
-- ONEMLI AYRIM
--   HUB  -> odak ALIR   (SetNuiFocus true, true)
--   HUD  -> odak ALMAZ  (bkz. client_workout.lua)
-- Zar overlay'i (web/app.js) ayni sayfada yasar ve pointer-events:none
-- oldugu icin bu ikisinden etkilenmez.
-- =========================================================================

GymNui = {}
if not Config.Gym or Config.Gym.Enabled == false then return end

local hubOpen = false

local function send(action, data)
    SendNUIMessage({ action = action, data = data })
end

---Basarim katalogunu NUI'nin anlayacagi bicimde hazirlar.
local function achievementCatalog()
    local out = {}
    for _, ach in ipairs(Config.Gym.Achievements) do
        out[#out + 1] = {
            id = ach.id,
            label = ach.label,
            badge = ach.badge,
            description = ach.description,
            points = ach.points,
            category = ach.category,
        }
    end
    return out
end

---Rutbe merdivenini (UI'daki ilerleme cizgisi icin) hazirlar.
local function tierLadder()
    local out = {}
    for i, t in ipairs(Config.Gym.Tiers) do
        out[#out + 1] = {
            index = i, id = t.id, label = t.label, badge = t.badge,
            minCondition = t.minCondition, minPoints = t.minPoints,
        }
    end
    return out
end

function GymNui.IsOpen()
    return hubOpen
end

---Koc merkezini acar.
---@param trainer table? Config.Gym.Trainers girdisi
function GymNui.OpenHub(trainer)
    if hubOpen then return end
    if GymWorkout and GymWorkout.IsBusy() then
        lib.notify({ title = 'Salon', description = 'Önce setini bitir.', type = 'warning' })
        return
    end

    local payload = lib.callback.await('daddy-games:gym:getHubData', false)
    if not payload then
        lib.notify({ title = 'Salon', description = 'Profil bilgileri yüklenemedi.', type = 'error' })
        return
    end

    payload.trainer = trainer and {
        id = trainer.id,
        name = trainer.name,
        title = trainer.title,
    } or { name = 'Salon Danışma', title = '' }

    payload.catalog = achievementCatalog()
    payload.ladder = tierLadder()

    hubOpen = true
    SetNuiFocus(true, true)
    send('gym:hub:open', payload)
end

function GymNui.CloseHub()
    if not hubOpen then return end

    hubOpen = false
    SetNuiFocus(false, false)
    send('gym:hub:close')
end

---Sunucu tarafi bir sey degistirdiginde paneli tazeler.
function GymNui.RefreshHub()
    if not hubOpen then return end

    local payload = lib.callback.await('daddy-games:gym:getHubData', false)
    if payload then send('gym:hub:refresh', payload) end
end

-- =========================================================================
-- NUI GERI CAGRIMLARI
-- =========================================================================
RegisterNUICallback('gymHubClose', function(_, cb)
    GymNui.CloseHub()
    cb({ ok = true })
end)

RegisterNUICallback('gymHubLeaderboard', function(data, cb)
    local category = type(data) == 'table' and data.category or 'fitness'
    local result = lib.callback.await('daddy-games:gym:getLeaderboard', false, category)
    cb(result or { rows = {} })
end)

RegisterNUICallback('gymHubBuy', function(data, cb)
    local ok, message = lib.callback.await('daddy-games:gym:buySupplement', false, data and data.id)

    if ok then
        local payload = lib.callback.await('daddy-games:gym:getHubData', false)
        cb({ ok = true, message = message, payload = payload })
    else
        cb({ ok = false, message = message })
    end
end)

RegisterNUICallback('gymHubUse', function(data, cb)
    local ok, message = lib.callback.await('daddy-games:gym:useSupplement', false, data and data.id)

    if ok then
        local payload = lib.callback.await('daddy-games:gym:getHubData', false)
        cb({ ok = true, message = message, payload = payload })
    else
        cb({ ok = false, message = message })
    end
end)

RegisterNUICallback('gymHubAdvice', function(data, cb)
    local advice = lib.callback.await('daddy-games:gym:getCoachAdvice', false, data and data.trainerId)
    cb(advice or { name = 'Koç', line = '...' })
end)

-- =========================================================================
-- ACIL KAPATMA
-- Odak kilitli kalmasin: ESC her zaman calisir, resource durursa da birakilir.
-- =========================================================================
CreateThread(function()
    while true do
        if hubOpen then
            Wait(0)
            if IsControlJustPressed(0, 200) or IsControlJustPressed(0, 202) then
                GymNui.CloseHub()
            end
        else
            Wait(400)
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    SetNuiFocus(false, false)
end)
