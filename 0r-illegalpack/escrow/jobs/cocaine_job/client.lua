local Utils = require 'modules.utils.client'
local Weather = require 'modules.weather.client'
local lib = lib

-- Constants


local JOB_KEY = 'cocaine_job'
local config = lib.load(('escrow.jobs.%s.config'):format(JOB_KEY))

local configReady = false

Citizen.CreateThread(function()
    while not client.isPlayerLoaded() do
        Wait(500)
    end

    local labLocations = lib.callback.await('cocaine_job:getLabLocations', false)
    if config and config.game and labLocations then
        config.game.shell_interior_lab_locations = labLocations
        configReady = true
    end
end)

local job = {}

local state = {
    labLocationBlips = {},
    outsidePoint = nil,
    playerIsBusy = false,
    sceneObjects = {},
    unpackingPoints = {},
    cutPoints = {},
    packingPoints = {},
    currentLabIndex = 1,
}

local function playUnpackingScene(data)
    local playerPed = cache.ped

    local animDict = 'anim@amb@business@coc@coc_unpack_cut@'
    local bowlModel = 'bkr_prop_coke_fullmetalbowl_02'
    local boxModel = 'bkr_prop_coke_box_01a'

    lib.requestAnimDict(animDict)
    lib.requestModel(bowlModel)
    lib.requestModel(boxModel)

    local bowl = CreateObject(bowlModel,
        data.coords.x, data.coords.y, data.coords.z,
        true, true, false)

    table.insert(state.sceneObjects, bowl)
    SetEntityRotation(bowl, data.rotation)

    local box = CreateObject(boxModel,
        data.coords.x, data.coords.y, data.coords.z,
        true, true, false)
    table.insert(state.sceneObjects, box)

    local scenePos = GetOffsetFromEntityInWorldCoords(bowl, data.offset)
    local sceneRot = GetEntityRotation(bowl)

    local scene01 = NetworkCreateSynchronisedScene(
        scenePos.x, scenePos.y, scenePos.z,
        sceneRot.x, sceneRot.y, sceneRot.z,
        2, true, false, -1, 0, 1.0)

    NetworkAddPedToSynchronisedScene(playerPed, scene01, animDict,
        'fullcut_cycle_v2_cokepacker',
        1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bowl, scene01, animDict,
        'fullcut_cycle_v2_cokebowl',
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(box, scene01, animDict,
        'fullcut_cycle_v2_cokebox',
        1.0, 1.0, 1)

    NetworkStartSynchronisedScene(scene01)

    local wait = (GetAnimDuration(animDict, 'fullcut_cycle_v2_cokepacker') * 800)
    RemoveAnimDict(animDict)
    SetModelAsNoLongerNeeded(bowlModel)
    SetModelAsNoLongerNeeded(boxModel)

    local success = Utils.progressBar({
        duration = wait,
        label = locale('progress'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            combat = true,
            move = true,
            sprint = true
        }
    })

    NetworkStopSynchronisedScene(scene01)

    ClearPedTasks(playerPed)

    for _, v in pairs(state.sceneObjects) do
        SetEntityAsMissionEntity(v, true, true)
        DeleteEntity(v)
    end
    state.sceneObjects = {}

    if not success then
        return false
    end

    return true
end

local function playCutterScene(data)
    local playerPed = cache.ped

    local animDict = 'anim@amb@business@coc@coc_unpack_cut_left@'
    local bakingSodaModel = 'bkr_prop_coke_bakingsoda_o'
    local creditCardModel = 'prop_cs_credit_card'

    lib.requestAnimDict(animDict)
    lib.requestModel(bakingSodaModel)
    lib.requestModel(creditCardModel)

    local bakingSoda = CreateObject(bakingSodaModel,
        data.coords.x, data.coords.y, data.coords.z,
        true, true, false)

    table.insert(state.sceneObjects, bakingSoda)
    SetEntityRotation(bakingSoda, data.rotation)

    local card01 = CreateObject(creditCardModel,
        data.coords.x, data.coords.y, data.coords.z,
        true, true, false)
    table.insert(state.sceneObjects, card01)

    local card02 = CreateObject(creditCardModel,
        data.coords.x, data.coords.y, data.coords.z,
        true, true, false)
    table.insert(state.sceneObjects, card02)

    local scenePos = GetOffsetFromEntityInWorldCoords(bakingSoda, data.offset)
    local sceneRot = GetEntityRotation(bakingSoda)

    local scene01 = NetworkCreateSynchronisedScene(scenePos, sceneRot,
        2, true, false, -1, 0, 1.0)

    NetworkAddPedToSynchronisedScene(playerPed, scene01, animDict,
        'coke_cut_v5_coccutter',
        1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bakingSoda, scene01, animDict,
        'coke_cut_v5_bakingsoda',
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(card01, scene01, animDict,
        'coke_cut_v5_creditcard',
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(card02, scene01, animDict,
        'coke_cut_v5_creditcard^1',
        1.0, 1.0, 1)

    NetworkStartSynchronisedScene(scene01)

    local wait = (GetAnimDuration(animDict, 'coke_cut_v5_coccutter') * 800)
    RemoveAnimDict(animDict)
    SetModelAsNoLongerNeeded(bakingSodaModel)
    SetModelAsNoLongerNeeded(creditCardModel)

    local success = Utils.progressBar({
        duration = wait,
        label = locale('progress'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            combat = true,
            move = true,
            sprint = true
        }
    })

    NetworkStopSynchronisedScene(scene01)

    ClearPedTasks(playerPed)

    for _, v in pairs(state.sceneObjects) do
        SetEntityAsMissionEntity(v, true, true)
        DeleteEntity(v)
    end
    state.sceneObjects = {}

    if not success then
        return false
    end

    return true
end

local function playPackingScene(data)
    local playerPed = cache.ped

    local animDict = 'anim@amb@business@coc@coc_packing_hi@'
    local models = {
        scoop = 'bkr_prop_coke_fullscoop_01a',
        doll = 'bkr_prop_coke_doll',
        boxedDoll = 'bkr_prop_coke_boxedDoll',
        dollCast = 'bkr_prop_coke_dollCast',
        dollMould = 'bkr_prop_coke_dollmould',
        bowl = 'bkr_prop_coke_fullmetalbowl_02',
        cokePress = 'bkr_prop_coke_press_01b',
        foldedBox = 'bkr_prop_coke_dollboxfolded'
    }

    lib.requestAnimDict(animDict)
    for _, model in pairs(models) do
        lib.requestModel(model)
    end

    local function createAndInsert(model, rotation)
        local obj = CreateObject(model, data.coords.x, data.coords.y, data.coords.z, true, true, false)
        if rotation then SetEntityRotation(obj, data.rotation) end
        SetModelAsNoLongerNeeded(model)
        table.insert(state.sceneObjects, obj)
        return obj
    end


    local scoop = createAndInsert(models.scoop, true)
    local doll = createAndInsert(models.doll)
    local boxedDoll = createAndInsert(models.boxedDoll)
    local dollCasts = {
        createAndInsert(models.dollCast),
        createAndInsert(models.dollCast),
        createAndInsert(models.dollCast),
        createAndInsert(models.dollCast)
    }
    local dollMould = createAndInsert(models.dollMould)
    local bowl = createAndInsert(models.bowl)
    local cokePress = createAndInsert(models.cokePress)
    local foldedBox = createAndInsert(models.foldedBox)

    local scenePos = GetOffsetFromEntityInWorldCoords(scoop, data.offset)
    local sceneRot = GetEntityRotation(scoop)

    local scenes = {}
    for i = 1, 4 do
        scenes[i] = NetworkCreateSynchronisedScene(scenePos, sceneRot,
            2, true, false, -1, 0, 1.0)
    end

    NetworkAddPedToSynchronisedScene(playerPed, scenes[1], animDict,
        'full_cycle_v3_pressoperator',
        1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(scoop, scenes[1], animDict,
        'full_cycle_v3_scoop',
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(doll, scenes[1], animDict,
        'full_cycle_v3_cocdoll',
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(boxedDoll, scenes[1], animDict,
        'full_cycle_v3_boxedDoll',
        1.0, 1.0, 1)

    NetworkAddPedToSynchronisedScene(playerPed, scenes[2], animDict,
        'full_cycle_v3_pressoperator',
        1.5, -4.0, 1, 16, 1148846080, 0)
    for i = 1, 3 do
        NetworkAddEntityToSynchronisedScene(dollCasts[i], scenes[2], animDict,
            'full_cycle_v3_dollcast' .. (i == 1 and '' or '^' .. (i - 1)),
            1.0, 1.0, 1)
    end

    NetworkAddPedToSynchronisedScene(playerPed, scenes[3], animDict,
        'full_cycle_v3_pressoperator',
        1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(dollCasts[4], scenes[3], animDict,
        'full_cycle_v3_dollcast^3',
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(dollMould, scenes[3], animDict,
        'full_cycle_v3_dollmould',
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(bowl, scenes[3], animDict,
        'full_cycle_v3_cocbowl',
        1.0, 1.0, 1)

    NetworkAddPedToSynchronisedScene(playerPed, scenes[4], animDict,
        'full_cycle_v3_pressoperator',
        1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(cokePress, scenes[4], animDict,
        'full_cycle_v3_cokePress',
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(foldedBox, scenes[4], animDict,
        'full_cycle_v3_FoldedBox',
        1.0, 1.0, 1)

    for _, scene in pairs(scenes) do
        NetworkStartSynchronisedScene(scene)
    end

    local wait = (GetAnimDuration(animDict, 'full_cycle_v3_pressoperator') * 900)
    RemoveAnimDict(animDict)

    local success = Utils.progressBar({
        duration = wait,
        label = locale('progress'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = { car = true, combat = true, move = true, sprint = true }
    })

    for _, scene in pairs(scenes) do
        NetworkStopSynchronisedScene(scene)
    end

    ClearPedTasks(playerPed)

    for _, v in pairs(state.sceneObjects) do
        SetEntityAsMissionEntity(v, true, true)
        DeleteEntity(v)
    end
    state.sceneObjects = {}

    if not success then
        return false
    end

    return true
end

local function getOutsideLab()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(1) end
    local labIndex = state.currentLabIndex or 1
    local response = lib.callback.await(_e('server:jobs:cocaine_job:getOutsideLab'), false)
    if not response then
        DoScreenFadeIn(1000)
        return
    end

    Weather.enableSync()
    DoScreenFadeIn(1000)
    state.currentLabIndex = nil
end

local function createOutsidePoint()
    local exitPoint = config.game.shell_interior.exitPoint
    state.outsidePoint = lib.points.new({
        coords = exitPoint,
        distance = 1.5,
        onEnter = function(self)
            Utils.showTextUI('[E]' .. locale('get_outside'))
        end,
        onExit = function(self)
            Utils.hideTextUI()
        end,
        nearby = function(self)
            DrawMarker(20, self.coords.x, self.coords.y, self.coords.z - .25, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                .5, .25, 0.5, 255, 255, 0, 255,
                false, true, 2, true, nil, nil, false)

            if IsControlJustPressed(0, 38) then
                getOutsideLab()
            end
        end
    })
end

local function getInsideLab(labIndex)
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(1) end

    local response = lib.callback.await(_e('server:jobs:cocaine_job:getInsideLab'), false, labIndex)
    if not response or (type(response) == 'table' and response.error) then
        if type(response) == 'table' and response.error then
            lib.notify({ title = locale('error'), description = response.error, type = 'error' })
        end
        DoScreenFadeIn(1000)
        return false
    end

    local interiorSets = {}
    local sets = {
        'security_low',
        'set_up',
        'table_equipment',
        'equipment_upgrade',
        'production_upgrade',
        'coke_press_upgrade',
        'table_equipment_upgrade',
    }
    for _, stage in pairs({ '1', '2', '3', '4', '5' }) do
        table.insert(sets, 'coke_cut_0' .. stage)
    end
    local hide = {
        'set_up',
        'security_low',
        'equipment_basic',
        'production_basic',
        'coke_press_basic',
        'table_equipment',
        'security_high',
        'equipment_upgrade',
        'production_upgrade',
        'coke_press_upgrade',
        'table_equipment_upgrade',
    }

    for _, value in pairs(hide) do
        interiorSets[value] = false
    end
    for _, value in pairs(sets) do
        interiorSets[value] = true
    end

    client.loadInteriorEntities(config.game.shell_interior.coords, interiorSets)
    SetArtificialLightsState(false)
    Weather.disableSync()
    state.currentLabIndex = labIndex
    DoScreenFadeIn(1000)

    return true
end

local function createLabLocationPoint(labCoords, labIndex)
    local point = lib.points.new({
        coords = labCoords,
        distance = 1.0,
        onEnter = function(self)
            local isPolice = client.hasPlayerGotGroup(Config.PoliceJobName)
            local text = '[E] ' .. locale('get_inside')
            if isPolice then
                text = text .. ' | [G] Baskın Yap'
            end
            Utils.showTextUI(text)
        end,
        onExit = function(self)
            Utils.hideTextUI()
        end,
        nearby = function(self)
            if IsControlJustPressed(0, 38) then -- E
                if getInsideLab(labIndex) then
                    if client.currentJob and client.currentJob.steps and client.currentJob.steps[1] and not client.currentJob.steps[1].done then
                        lib.callback.await(_e('server:jobs:onStepDone'), false, client.lobby.id, 1)
                    end
                end
                Citizen.Wait(1000)
            end

            if IsControlJustPressed(0, 47) then -- G
                local isPolice = client.hasPlayerGotGroup(Config.PoliceJobName)
                if isPolice then
                    if Utils.progressBar({
                            duration = 10000,
                            label = 'Kapı Kırılıyor...',
                            useWhileDead = false,
                            canCancel = true,
                            disable = { car = true, move = true },
                            anim = { dict = 'missheistfbi3b_ig7', clip = 'lift_fib7_loop' }
                        }) then
                        lib.callback.await(_e('server:jobs:startRaid'), false, JOB_KEY, labIndex)
                        Utils.notify('Başarılı', 'Baskın başlatıldı, kapı 15 dakika açık kalacak.', 5000, 'success')
                    end
                end
            end
        end
    })
end

local function createUnpackingPoints()
    local coords = {}
    if config.game.useShellInterior then
        coords = config.game.unpackingScene.coords.shell_interior
    else
        coords = config.game.unpackingScene.coords.mlo_interior
    end

    for _, data in pairs(coords) do
        local point = lib.points.new({
            coords = data.coords,
            distance = 1.0,
            onEnter = function(self)
                if not client.currentJob then return end
                Utils.showTextUI('[E] ' .. locale('cocaine_job.unpack_coke'))
            end,
            onExit = function(self)
                if not client.currentJob then return end
                Utils.hideTextUI()
            end,
            nearby = function(self)
                if not client.currentJob then return end
                if IsControlJustPressed(0, 38) and not state.playerIsBusy then
                    state.playerIsBusy = true
                    Utils.hideTextUI()
                    local response = lib.callback.await(_e('server:jobs:cocaine_job:canUnpack'),
                        false, client.lobby.id)
                    if not response then
                        state.playerIsBusy = false
                        return
                    end
                    if response.error then
                        state.playerIsBusy = false
                        Utils.notify(response.error, 'error')
                        self:onEnter()
                        return
                    end
                    if not Utils.checkSkill(config.game.skillCheck, 'unpacking') then
                        state.playerIsBusy = false
                        return
                    end

                    if not playUnpackingScene(data) then
                        state.playerIsBusy = false
                        return
                    end
                    state.playerIsBusy = false
                    lib.callback.await(_e('server:jobs:cocaine_job:onUnpackCoke'), false, client.lobby.id)
                    -- if math.random() < config.game.police_alert_chance then
                    --     Utils.triggerPoliceAlert('cocaine_job', locale("cocaine_job"))
                    -- end
                    self:onEnter()
                end
            end
        })
        table.insert(state.unpackingPoints, point)
    end
end

local function createCutPoints()
    local coords = {}
    if config.game.useShellInterior then
        coords = config.game.cutterScene.coords.shell_interior
    else
        coords = config.game.cutterScene.coords.mlo_interior
    end

    for _, data in pairs(coords) do
        local point = lib.points.new({
            coords = data.coords,
            distance = 1.0,
            onEnter = function(self)
                if not client.currentJob then return end
                Utils.showTextUI('[E] ' .. locale('cocaine_job.cut_coke'))
            end,
            onExit = function(self)
                if not client.currentJob then return end
                Utils.hideTextUI()
            end,
            nearby = function(self)
                if not client.currentJob then return end
                if IsControlJustPressed(0, 38) and not state.playerIsBusy then
                    state.playerIsBusy = true
                    Utils.hideTextUI()
                    local response = lib.callback.await(_e('server:jobs:cocaine_job:canCut'),
                        false, client.lobby.id)
                    if not response then
                        state.playerIsBusy = false
                        return
                    end
                    if response.error then
                        state.playerIsBusy = false
                        Utils.notify(response.error, 'error')
                        self:onEnter()
                        return
                    end
                    if not Utils.checkSkill(config.game.skillCheck, 'cutting') then
                        state.playerIsBusy = false
                        return
                    end

                    if not playCutterScene(data) then
                        state.playerIsBusy = false
                        return
                    end

                    state.playerIsBusy = false
                    lib.callback.await(_e('server:jobs:cocaine_job:onCutCoke'), false, client.lobby.id)
                    -- if math.random() < config.game.police_alert_chance then
                    --     Utils.triggerPoliceAlert('cocaine_job', locale("cocaine_job"))
                    -- end
                    self:onEnter()
                end
            end
        })
        table.insert(state.cutPoints, point)
    end
end

local function createPackingPoint()
    local coords = {}
    if config.game.useShellInterior then
        coords = config.game.packingScene.coords.shell_interior
    else
        coords = config.game.packingScene.coords.mlo_interior
    end

    for _, data in pairs(coords) do
        local point = lib.points.new({
            coords = data.coords,
            distance = 1.0,
            onEnter = function(self)
                if not client.currentJob then return end
                Utils.showTextUI('[E] ' .. locale('cocaine_job.package_coke'))
            end,
            onExit = function(self)
                if not client.currentJob then return end
                Utils.hideTextUI()
            end,
            nearby = function(self)
                if not client.currentJob then return end

                if IsControlJustPressed(0, 38) and not state.playerIsBusy then
                    state.playerIsBusy = true
                    Utils.hideTextUI()
                    local response = lib.callback.await(_e('server:jobs:cocaine_job:canPackage'),
                        false, client.lobby.id)
                    if not response then
                        state.playerIsBusy = false
                        return
                    end
                    if response.error then
                        state.playerIsBusy = false
                        Utils.notify(response.error, 'error')
                        self:onEnter()
                        return
                    end

                    if not Utils.checkSkill(config.game.skillCheck, 'packing') then
                        state.playerIsBusy = false
                        return
                    end

                    if not playPackingScene(data) then
                        state.playerIsBusy = false
                        return
                    end

                    lib.callback.await(_e('server:jobs:cocaine_job:onPackageCoke'), false, client.lobby.id)
                    -- if math.random() < config.game.police_alert_chance then
                    --     Utils.triggerPoliceAlert('cocaine_job', locale("cocaine_job"))
                    -- end
                    Citizen.Wait(1000)
                    state.playerIsBusy = false
                    self:onEnter()
                end
            end
        })
        table.insert(state.packingPoints, point)
    end
end

-- job functions

function job.cleanup()
    if state.labLocationBlips then
        for _, blip in pairs(state.labLocationBlips) do
            RemoveBlip(blip)
        end
        state.labLocationBlips = {}
    end
    if state.unpackingPoints then
        for _, p in pairs(state.unpackingPoints) do
            p:remove()
        end
        state.unpackingPoints = {}
    end
    if state.cutPoints then
        for _, p in pairs(state.cutPoints) do
            p:remove()
        end
        state.cutPoints = {}
    end
    if state.sceneObjects then
        for _, v in pairs(state.sceneObjects) do
            SetEntityAsMissionEntity(v, true, true)
            DeleteEntity(v)
        end
        state.sceneObjects = {}
    end
    if state.packingPoints then
        for _, p in pairs(state.packingPoints) do
            p:remove()
        end
        state.packingPoints = {}
    end
    state.playerIsBusy = false
end

function job.restoreLabInterior(labIndex)
    state.currentLabIndex = labIndex
    if config.game.useShellInterior then
        Weather.disableSync()
    end
end

function job.start()
    job.onStepStart(1)
    return true
end

function job.stop()
    job.cleanup()
    ClearPedTasks(cache.ped)
    Utils.hideTextUI()
    return true
end

function job.onStepStart(stepIndex)
    if stepIndex <= 1 then
        Citizen.CreateThread(function()
            while not configReady do
                Wait(100)
            end

            local lab_locations = config.game.useShellInterior and
                config.game.shell_interior_lab_locations
                or
                config.game.mlo_interior_lab_locations

            if not lab_locations or #lab_locations == 0 then
                Utils.notify(locale('cocaine_job.no_lab_locations'), 'error')
                return false
            end

            for _, labCoords in pairs(lab_locations) do
                local blip = Utils.addBlip(labCoords.entrance, config.blips.lab_location)
                table.insert(state.labLocationBlips, blip)
            end
        end)

        if not config.game.useShellInterior then
            Citizen.CreateThread(function()
                while client.currentJob and client.currentJob.name == JOB_KEY do
                    local playerPed = cache.ped
                    local coords = GetEntityCoords(playerPed)
                    local closestPoint = nil
                    local closestDistance = 7.5

                    for _, labCoords in pairs(lab_locations) do
                        local distance = #(coords - labCoords)
                        if distance < closestDistance then
                            closestDistance = distance
                            closestPoint = labCoords
                        end
                    end

                    if closestPoint then
                        if client.currentJob and client.currentJob.steps and client.currentJob.steps[1] and not client.currentJob.steps[1].done then
                            lib.callback.await(_e('server:jobs:onStepDone'), false, client.lobby.id, 1)
                        end
                        return
                    end

                    Citizen.Wait(1000)
                end
            end)
        end

        return true
    elseif stepIndex == 2 then
        createUnpackingPoints()
        createCutPoints()
        createPackingPoint()
        return true
    end

    if client.lobby.owner == cache.serverId then
        lib.callback.await(_e('server:jobs:finishJob'), false, client.lobby.id)
    end

    return false
end

function job.onStepDone(stepIndex)
    return job.onStepStart(stepIndex + 1)
end

exports('cocaine_job_play_scene', function(name, coords, offset, rotation)
    if not name or not coords or not offset or not rotation then
        print('[ERROR] Invalid parameters for cocaine_job_play_scene')
        return
    end

    local data = {
        coords = coords,
        offset = offset,
        rotation = rotation
    }

    state.playerIsBusy = true
    if name == 'unpacking' then
        playUnpackingScene(data)
    elseif name == 'cutting' then
        playCutterScene(data)
    elseif name == 'packing' then
        playPackingScene(data)
    else
        print('[ERROR] Unknown scene name: ' .. tostring(name))
    end
    state.playerIsBusy = false
end)

--[[ events ]]

--[[ onload ]]

if config.game.useShellInterior then
    Citizen.CreateThread(function()
        while not configReady do
            Wait(100)
        end
        for index, labCoords in ipairs(config.game.shell_interior_lab_locations) do
            createLabLocationPoint(labCoords.entrance, index)
        end
        createOutsidePoint()
    end)
end

--[[ Register ]]
Jobs.register(JOB_KEY, job)
