local Utils = require 'modules.utils.client'
local Target = require 'modules.target.client'
local lib = lib

-- Constants

local JOB_KEY = 'fraud'
local config = lib.load(('escrow.jobs.%s.config'):format(JOB_KEY))

local job = {}

local state = {
    atmDistance = { zone = nil, blip = nil },
    atmCam = nil,
    lastCustomerPed = {
        entity = nil,
        netId = nil,
        atAtm = false,
        thread = false,
    },
    office = { blip = nil, laptop = nil, cardPlaced = false },
    banker = { blip = nil, zone = nil },
}

local function isPlayerNearAtm()
    local atmCam = state.atmCam
    if atmCam and DoesCamExist(atmCam) then
        local atmCamCoords = GetCamCoord(atmCam)
        local playerCoords = GetEntityCoords(cache.ped)
        local distance = #(atmCamCoords - playerCoords)
        return distance <= 100.0
    end

    return false
end

local function deleteAtmCam()
    if DoesCamExist(state.atmCam) then
        if IsCamActive(state.atmCam) then
            ClearFocus()
            SetCamActive(state.atmCam, false)
            RenderScriptCams(false, false, 0, false, false)
            ClearTimecycleModifier()
            ClearExtraTimecycleModifier()
        end
    end
end

local function handleCamControls(cam)
    if not DoesCamExist(cam) then return false end

    DisableAllControlActions(0)
    HideHudAndRadarThisFrame()

    local rightAxisX = GetDisabledControlNormal(0, 220)
    local rightAxisY = GetDisabledControlNormal(0, 221)

    if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
        local rotation = GetCamRot(cam, 2)
        local sensitivity = 2.5

        local new_z = rotation.z + rightAxisX * -1.0 * sensitivity
        local new_x = math.max(-60.0, math.min(60.0, rotation.x + rightAxisY * -1.0 * sensitivity))
        SetCamRot(cam, new_x, 0.0, new_z, 2)
    end

    if IsDisabledControlPressed(0, 97) and GetCamFov(cam) < 100 then
        SetCamFov(cam, GetCamFov(cam) + 2.0)
    elseif IsDisabledControlPressed(0, 96) and GetCamFov(cam) > 10 then
        SetCamFov(cam, GetCamFov(cam) - 2.0)
    end

    if IsDisabledControlJustPressed(0, 194) then
        deleteAtmCam()
        Utils.toggleHud(true)
        return false
    end
    return true
end

local function addCameraToCoords(data)
    local cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA',
        data.coords.x, data.coords.y, data.coords.z,
        data.rotation.x, data.rotation.y, data.rotation.z,
        70.0, false, 2)

    return cam
end

local function createAtmInsertDeviceZone()
    local location = client.currentJob.game.atm_location
    local atmCoords = location.coords
    state.atmDistance.blip = Utils.addBlip(atmCoords, config.blips.atm, true)

    local zoneKey = 'illegalpack:fraud:atmInsertDevice'
    state.atmDistance.zone = zoneKey
    Target.addBoxZone(zoneKey, {
        name = zoneKey,
        coords = vector3(atmCoords.x, atmCoords.y, atmCoords.z + 1.0),
        debug = false,
        size = vector3(2.0, 2.0, 2.5),
        options = { {
            label = locale('fraud.insert_device'),
            icon = 'fa-solid fa-camera',
            distance = 2.0,
            onSelect = function()
                local response = lib.callback.await(_e('server:jobs:fraud:canInsertDeviceToAtm'),
                    false, client.lobby.id)
                if not response then return end

                lib.playAnim(cache.ped, 'missmechanic', 'work2_base', nil, nil, nil, 1)

                Utils.progressBar({
                    duration = 3000,
                    label = locale('progress'),
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = false,
                    disable = { car = true, combat = true, move = true, sprint = true }
                })
                ClearPedTasks(cache.ped)

                lib.callback.await(_e('server:jobs:onStepDone'), false, client.lobby.id, 1)

                Utils.triggerPoliceAlert('fraud', locale("fraud"))
            end
        } }
    })
end

local function createCustomerPed()
    if state.lastCustomerPed.thread then
        while state.lastCustomerPed.thread do Wait(0) end
    end
    local pedSpawnLocations = client.currentJob.game.atm_location.ped_spawn
    local coords = pedSpawnLocations[math.random(#pedSpawnLocations)]

    local models = { 'a_f_y_hipster_02', 'a_f_y_vinewood_02', 'a_m_o_soucent_01', 'a_m_o_soucent_02', 'a_m_o_tramp_01', }
    local model = models[math.random(#models)]

    lib.requestModel(model)
    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, coords.w or 0.0, true, true)
    while not DoesEntityExist(ped) do Wait(0) end
    SetEntityInvincible(ped, true)
    SetPedDiesWhenInjured(ped, false)
    SetEntityInvincible(ped, true)
    TaskSetBlockingOfNonTemporaryEvents(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)

    Utils.addBlip(ped, config.blips.customer)

    local pedNetId = lib.waitFor(function()
        if not NetworkGetEntityIsNetworked(ped) then
            NetworkRegisterEntityAsNetworked(ped)
        else
            local netId = PedToNet(ped)
            if NetworkDoesNetworkIdExist(netId) then
                return netId
            end
        end
    end, false, false)

    SetModelAsNoLongerNeeded(model)
    state.lastCustomerPed.entity = ped
    state.lastCustomerPed.netId = pedNetId
    state.lastCustomerPed.atAtm = false

    lib.callback.await(_e('server:jobs:fraud:onCustomerPedSpawned'), false, client.lobby.id, pedNetId)
end

local function setLastCustomerTask()
    local targetCoords = client.currentJob.game.atm_location.coords
    local ped = state.lastCustomerPed.entity

    SetPedKeepTask(ped, true)
    TaskGoToCoordAnyMeans(ped, targetCoords.x, targetCoords.y, targetCoords.z, 1.0, 0, 0, 786603, 0xbf800000)
    state.lastCustomerPed.thread = true

    Citizen.CreateThread(function()
        while state.lastCustomerPed.entity do
            local wait = 500
            local customerPed = state.lastCustomerPed.entity

            if customerPed and DoesEntityExist(customerPed) then
                local customerCoords = GetEntityCoords(customerPed)

                local distance = #(vector3(targetCoords) - customerCoords)

                if distance <= 1.0 and isPlayerNearAtm() then
                    state.lastCustomerPed.atAtm = true
                    ClearPedTasks(customerPed)
                    SetEntityCoords(customerPed, targetCoords.x, targetCoords.y, targetCoords.z - 1.0)
                    SetEntityHeading(customerPed, targetCoords.w or 0.0)
                    TaskStartScenarioInPlace(customerPed, 'PROP_HUMAN_ATM',
                        config.game.time_required_to_capture_data * 1000, true)

                    client.sendReactMessage('ui:setPage', 'fraud_skillbar')
                    client.sendReactMessage('ui:setVisible', true)
                    SetNuiFocus(true, true)
                    break
                end
            end

            Wait(wait)
        end
        state.lastCustomerPed.thread = false
    end)
end

local function createOfficeObjects()
    local office = client.currentJob.game.office_location
    if not office then return end

    state.office.blip = Utils.addBlip(office.laptop_location, config.blips.office, true)

    local laptopCoords = vector3(office.laptop_location.x, office.laptop_location.y, office.laptop_location.z)
    state.office.laptop = Utils.createObject('prop_laptop_lester',
        laptopCoords, vector3(0.0, 0.0, office.laptop_location.w or 0.0),
        true, false, false)

    Target.addLocalEntity(state.office.laptop, {
        {
            label = locale('fraud.open_laptop'),
            icon = 'fa-solid fa-laptop',
            distance = 2.0,
            canInteract = function()
                return client.currentJob and not client.currentJob.steps[4].done
            end,
            onSelect = function()
                job.openLaptop()
            end,
        },
        {
            label = locale('fraud.place_card'),
            icon = 'fa-solid fa-credit-card',
            distance = 2.0,
            canInteract = function()
                return not state.office.cardPlaced and client.currentJob and not client.currentJob.steps[4].done
            end,
            onSelect = function()
                job.placeCard()
            end,
        },
    })
end

local function createBankerPoint()
    local coords = client.currentJob.game.banker_location
    if not coords then return end

    state.banker.blip = Utils.addBlip(coords, config.blips.banker, true)

    local zoneKey = 'illegalpack:fraud:banker'
    state.banker.zone = zoneKey

    local bankerCoords = vector3(coords.x, coords.y, coords.z)

    Target.addBoxZone(zoneKey, {
        name = zoneKey,
        coords = vector3(bankerCoords.x, bankerCoords.y, bankerCoords.z + 1.0),
        debug = false,
        size = vector3(2.0, 2.0, 2.5),
        options = { {
            label = locale('fraud.withdraw_money'),
            icon = 'fa-solid fa-money-check',
            distance = 2.0,
            onSelect = function()
                local response = lib.callback.await(_e('server:fraud:onWithdrawMoney'),
                    false, client.lobby.id)
                if not response then return end
                Utils.notify(locale('fraud.money_successfully_withdrawn'), 'success')
            end
        } }
    })
end

function job.placeCard()
    local response = lib.callback.await(_e('server:jobs:fraud:onPlaceCard'), false, client.lobby.id)
    if not response then return end

    if response.error then
        return Utils.notify(response.error, 'error')
    end

    Utils.notify(locale('fraud.card_placed'), 'success')
    client.sendReactMessage('ui:fraud:onCardPlace', true)
    state.office.cardPlaced = true
end

function job.openLaptop()
    client.sendReactMessage('ui:fraud:onOpenLaptop', { cardInformations = client.currentJob.game.card_informations })
    client.sendReactMessage('ui:setPage', 'hacktop')
    client.sendReactMessage('ui:setVisible', true)
    SetNuiFocus(true, true)
end

function job.cleanup()
    if state.atmDistance.blip then
        RemoveBlip(state.atmDistance.blip)
        state.atmDistance.blip = nil
    end
    if state.atmDistance.zone then
        Target.removeZone(state.atmDistance.zone)
        state.atmDistance.zone = nil
    end
    if state.atmCam then
        deleteAtmCam()
        DestroyCam(state.atmCam)
        state.atmCam = nil
    end
    if state.office.laptop then
        DeleteEntity(state.office.laptop)
        state.office.laptop = nil
    end
    if state.banker.blip then
        RemoveBlip(state.banker.blip)
        state.banker.blip = nil
    end
    if state.banker.zone then
        Target.removeZone(state.banker.zone)
        state.banker.zone = nil
    end
    if state.office.blip then
        RemoveBlip(state.office.blip)
        state.office.blip = nil
    end
    state.lastCustomerPed = {}
    state.office.cardPlaced = false
end

function job.start()
    job.onStepStart(1)
    return true
end

function job.stop()
    job.cleanup()
    return true
end

function job.onStepStart(stepIndex)
    if stepIndex <= 1 then
        createAtmInsertDeviceZone()
        return true
    elseif stepIndex == 2 then
        state.atmCam = addCameraToCoords(client.currentJob.game.atm_location.camera)
        return true
    elseif stepIndex == 3 then
        if client.lobby.owner == cache.serverId then
            createCustomerPed()
            setLastCustomerTask()
        end
        return true
    elseif stepIndex == 4 then
        createOfficeObjects() -- Tüm oyuncular görsün
        return true
    elseif stepIndex == 5 then
        createBankerPoint() -- Tüm oyuncular görsün
        return true
    end

    if client.lobby.owner == cache.serverId then
        lib.callback.await(_e('server:jobs:finishJob'), false, client.lobby.id)
    end

    return false
end

function job.onStepDone(stepIndex)
    if stepIndex == 1 then
        if state.atmDistance.zone then
            Target.removeZone(state.atmDistance.zone)
            state.atmDistance.zone = nil
        end
    elseif stepIndex == 2 then
    elseif stepIndex == 3 then
        if state.atmCam then
            deleteAtmCam()
            DestroyCam(state.atmCam)
            state.atmCam = nil
        end
        if state.atmDistance.blip then
            RemoveBlip(state.atmDistance.blip)
            state.atmDistance.blip = nil
        end
        if state.atmDistance.zone then
            Target.removeZone(state.atmDistance.zone)
            state.atmDistance.zone = nil
        end
        Utils.toggleHud(true)
    elseif stepIndex == 4 then
        if state.office.laptop then
            SetEntityAsNoLongerNeeded(state.office.laptop)
            state.office.laptop = nil
        end
    end

    return job.onStepStart(stepIndex + 1)
end

--[[ events ]]

RegisterNetEvent(_e('client:jobs:fraud:onUsedAtmHackDevice'), function()
    if client.currentJob and client.currentJob.name == JOB_KEY then
        if not isPlayerNearAtm() then
            return Utils.notify(locale('fraud.too_far_from_atm'), 'error')
        end
        local atmCam = state.atmCam
        if atmCam and DoesCamExist(atmCam) then
            if not client.currentJob.steps[2].done then
                lib.callback.await(_e('server:jobs:onStepDone'), false, client.lobby.id, 2)
            end
            local camCoords = GetCamCoord(atmCam)
            SetCamActive(atmCam, true)
            RenderScriptCams(true, false, 1, false, true)
            SetFocusPosAndVel(camCoords.x, camCoords.y, camCoords.z, 0.0, 0.0, 0.0)
            SetTimecycleModifier('scanline_cam_cheap')
            SetTimecycleModifierStrength(2.0)
            Utils.toggleHud(false)

            Citizen.CreateThread(function()
                local atmCam = state.atmCam
                while client.currentJob do
                    if not handleCamControls(atmCam) then
                        break
                    end
                    Citizen.Wait(1)
                end
            end)
        end
    end
end)

RegisterNetEvent(_e('client:jobs:fraud:restart_capture_sequence'), function()
    createCustomerPed()
    setLastCustomerTask()
end)

RegisterNUICallback('nui:fraud:onDuplicateCard', function(data, resultCallback)
    client.hideUI()
    client.sendReactMessage('ui:fraud:clear')

    state.office.cardPlaced = false
    lib.callback.await(_e('server:jobs:fraud:onDuplicateCard'), false, client.lobby.id)

    resultCallback(true)
end)

RegisterNUICallback('nui:fraud:onSkillbarFinished', function(success, resultCallback)
    client.hideUI()
    client.sendReactMessage('ui:setPage', 'home')

    local customerPed = state.lastCustomerPed.entity
    if customerPed and DoesEntityExist(customerPed) then
        ClearPedTasksImmediately(customerPed)
        Wait(1000)
        SetPedKeepTask(customerPed, true)
        TaskWanderStandard(customerPed, 10.0, 10)
    end

    if success then
        Utils.notify(locale('fraud.capture_success'), 'success')
        lib.callback.await(_e('server:jobs:fraud:data_capture_success'),
            false, client.lobby.id)
    else
        Utils.notify(locale('fraud.capture_failed'), 'error')
    end

    Citizen.SetTimeout(10000, function()
        lib.callback.await(_e('server:jobs:fraud:restart_capture_sequence'),
            false, client.lobby.id)
    end)

    resultCallback(true)
end)

--[[ Register ]]
Jobs.register(JOB_KEY, job)
