-- Server messages, the bite key for staff rats, the infirmary bed and examining a player.
local t = DL.locale.t
local ratModels = {}
for _, name in ipairs(Config.Bite.Models) do ratModels[joaat(name)] = true end

local function notify(text, kind)
    if text then lib.notify({ description = text, type = kind or 'inform' }) end
end

RegisterNetEvent('daddy_veba:stage', function(stage) Effects.set(stage) end)
RegisterNetEvent('daddy_veba:cough', function() Effects.cough() end)
RegisterNetEvent('daddy_veba:heard', function(serverId) Effects.heard(serverId) end)
RegisterNetEvent('daddy_veba:bitten', function() Effects.bitten() end)

CreateThread(function()
    while not DL.fw.isLoggedIn() do Wait(2000) end
    Effects.set(lib.callback.await('daddy_veba:state', false) or 0)
end)
-- The mask is worn while it protects; the player's own piece comes back after, unless they changed it meanwhile.
local cloth = Config.Items.MaskCloth
local wornBefore, maskEnds = nil, 0

local function maskOff()
    maskEnds = 0
    if not wornBefore then return end
    local ped = PlayerPedId()
    local mine = IsPedMale(ped) and cloth.m or cloth.f
    if GetPedDrawableVariation(ped, cloth.component) == mine[1] then
        SetPedComponentVariation(ped, cloth.component, wornBefore[1], wornBefore[2], 0)
    end
    wornBefore = nil
end

RegisterNetEvent('daddy_veba:mask', function(seconds)
    if not cloth then return end
    if (tonumber(seconds) or 0) <= 0 then return maskOff() end
    local ped = PlayerPedId()
    local mine = IsPedMale(ped) and cloth.m or cloth.f
    if not wornBefore then
        wornBefore = { GetPedDrawableVariation(ped, cloth.component), GetPedTextureVariation(ped, cloth.component) }
    end
    SetPedComponentVariation(ped, cloth.component, mine[1], mine[2], 0)
    maskEnds = GetGameTimer() + seconds * 1000
    local ends = maskEnds
    SetTimeout(seconds * 1000, function()
        if maskEnds == ends then maskOff() end
    end)
end)

DL.fw.onUnloaded(function()
    Effects.set(0)
    maskOff()
end)

AddEventHandler('onResourceStop', function(name)
    if name == GetCurrentResourceName() then maskOff() end
end)

-- Bite: the key does nothing unless the event is on and the player is a rat (the server checks all of it again).
local lastPress = 0
RegisterCommand('+vebaisir', function()
    if not GlobalState.vebaActive or GetGameTimer() - lastPress < 1000 then return end
    local ped = PlayerPedId()
    if next(ratModels) and not ratModels[GetEntityModel(ped)] then return end
    lastPress = GetGameTimer()
    local player = lib.getClosestPlayer(GetEntityCoords(ped), Config.Bite.Reach, false)
    if not player then return notify(t('notify.bite_far'), 'error') end
    TriggerServerEvent('daddy_veba:bite', GetPlayerServerId(player))
end, false)
RegisterCommand('-vebaisir', function() end, false)
RegisterKeyMapping('+vebaisir', t('key.bite'), 'keyboard', Config.Bite.Key)

-- /veba fare: staff turn into the rat and back into their saved look (the server sends it).
local wasInvincible = false
RegisterNetEvent('daddy_veba:rat', function(on, look)
    local ped = PlayerPedId()
    if on then
        if IsPedInAnyVehicle(ped, false) then return notify(t('notify.rat_car'), 'error') end
        local hash = joaat(Config.Bite.Models[1] or 'a_c_rat')
        if not lib.requestModel(hash, 5000) then return end
        pcall(function() exports['FeloxAC']:hasChangedPedModel(hash) end) --[[FeloxAC:auto]]
        SetPlayerModel(PlayerId(), hash)
        SetModelAsNoLongerNeeded(hash)
        ped = PlayerPedId()
        SetPedDefaultComponentVariation(ped)
        if Config.Bite.Invincible then
            wasInvincible = true
            pcall(function() exports['FeloxAC']:isInvincible(true) end) --[[FeloxAC:auto]]
            SetEntityInvincible(ped, true)
        end
        return notify(t('notify.rat_on'), 'success')
    end
    if not (look and DL.appearance.applyPlayer(look)) then
        local fallback = DL.appearance.defaultPed('m')
        pcall(function() exports['FeloxAC']:hasChangedPedModel(fallback.model) end) --[[FeloxAC:auto]]
        DL.appearance.applyPlayer(fallback)
    end
    if wasInvincible then
        wasInvincible = false
        pcall(function() exports['FeloxAC']:isInvincible(false) end) --[[FeloxAC:auto]]
        SetEntityInvincible(PlayerPedId(), false)
    end
    notify(t('notify.rat_off'), 'success')
end)

-- Infirmary: lie down for the treatment; moving away or cancelling stops it.
local function treat()
    local ok, value = lib.callback.await('daddy_veba:treatStart', false)
    if not ok then return notify(value, 'error') end
    local ped = PlayerPedId()
    local anim = Config.Infirmary.Anim
    if lib.requestAnimDict(anim.dict, 3000) then TaskPlayAnim(ped, anim.dict, anim.clip, 4.0, -4.0, -1, 1, 0, false, false, false) end
    local done = lib.progressBar({
        duration = value * 1000, label = t('progress.treat'), canCancel = true,
        disable = { move = true, car = true, combat = true },
    })
    ClearPedTasks(ped)
    RemoveAnimDict(anim.dict)
    if not done then return end
    local cured, text = lib.callback.await('daddy_veba:treatEnd', false)
    notify(text, cured and 'success' or 'error')
end

exports.ox_target:addSphereZone({
    coords = Config.Infirmary.coords,
    radius = Config.Infirmary.radius,
    options = { {
        name = 'daddy_veba_treat', icon = 'fa-solid fa-bed-pulse', label = t('target.treat'),
        canInteract = function() return GlobalState.vebaActive and Effects.stage() >= 2 end,
        onSelect = treat,
    } },
})

-- Examine: only for those the server allows; the answer is asked once when the event turns on.
local canExamine = false
local function refreshAccess()
    canExamine = GlobalState.vebaActive and lib.callback.await('daddy_veba:canExamine', false) == true
end
AddStateBagChangeHandler('vebaActive', 'global', function() SetTimeout(500, refreshAccess) end)
CreateThread(function()
    while not DL.fw.isLoggedIn() do Wait(2000) end
    while true do
        refreshAccess()
        Wait(300000)
    end
end)

exports.ox_target:addGlobalPlayer({ {
    name = 'daddy_veba_examine', icon = 'fa-solid fa-stethoscope', label = t('target.examine'),
    distance = Config.Examine.Reach,
    canInteract = function() return canExamine and GlobalState.vebaActive end,
    onSelect = function(data)
        local target = GetPlayerServerId(NetworkGetPlayerIndexFromPed(data.entity))
        local ok, text = lib.callback.await('daddy_veba:examine', false, target)
        if ok then notify(text) end
    end,
} })

AddEventHandler('onResourceStop', function(name)
    if name ~= GetCurrentResourceName() then return end
    exports.ox_target:removeGlobalPlayer('daddy_veba_examine')
end)
