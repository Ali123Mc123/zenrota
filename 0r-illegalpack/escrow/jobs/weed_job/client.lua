local Utils = require 'modules.utils.client'
local Target = require 'modules.target.client'
local Weather = require 'modules.weather.client'
local lib = lib

-- Constants


local JOB_KEY = 'weed_job'
local config = lib.load(('escrow.jobs.%s.config'):format(JOB_KEY))

local configReady = false

Citizen.CreateThread(function()
    while not client.isPlayerLoaded() do
        Wait(500)
    end

    local labLocations = lib.callback.await('weed_job:getLabLocations', false)
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
    gatheringPoints = {},
    packingPoints = {},
    currentLabIndex = 1,
}

local function playGatheringScene(data)
    local playerPed = cache.ped
    local animDict = 'anim@amb@business@weed@weed_inspecting_lo_med_hi@'

    local models = {
        weed_spray = 'bkr_prop_weed_spray_01a',
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

    local spray = createAndInsert(models.weed_spray, true)

    local scenePos = GetOffsetFromEntityInWorldCoords(spray, data.offset)
    local sceneRot = GetEntityRotation(spray)

    local scene01 = NetworkCreateSynchronisedScene(scenePos, sceneRot,
        2, true, false, -1, 0, 1.0)

    NetworkAddPedToSynchronisedScene(playerPed, scene01, animDict,
        'weed_spraybottle_stand_kneeling_01_inspector',
        1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(spray, scene01, animDict,
        'weed_spraybottle_stand_kneeling_01_spraybottle',
        1.0, 1.0, 1)

    NetworkStartSynchronisedScene(scene01)
    local wait = (GetAnimDuration(animDict, 'weed_spraybottle_stand_kneeling_01_inspector') * 800)
    RemoveAnimDict(animDict)

    local success = Utils.progressBar({
        duration = wait,
        label = locale('progress'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = { car = true, combat = true, move = true, sprint = true }
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
    local coords = data.coords
    local rot = data.rotation
    local offset = data.offset

    local animDict = 'anim@amb@business@weed@weed_sorting_seated@'
    lib.requestAnimDict(animDict)

    local function createAndTrackObject(model)
        lib.requestModel(model)
        local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, true)
        table.insert(state.sceneObjects, obj)
        SetModelAsNoLongerNeeded(model)
        return obj
    end

    -- Create and track all objects
    local dryWeed1 = createAndTrackObject('bkr_prop_weed_dry_01a')
    SetEntityRotation(dryWeed1, rot)

    local dryWeed2 = createAndTrackObject('bkr_prop_weed_dry_01a')
    local leaf1 = createAndTrackObject('bkr_prop_weed_leaf_01a')
    local leaf2 = createAndTrackObject('bkr_prop_weed_leaf_01a')
    local weedBag = createAndTrackObject('bkr_prop_weed_bag_01a')
    local buds02a = {}
    for i = 1, 3 do
        table.insert(buds02a, createAndTrackObject('bkr_prop_weed_bud_02a'))
    end
    local bagPile = createAndTrackObject('bkr_prop_weed_bag_pile_01a')

    -- Scene position/rotation
    local scenePos = GetOffsetFromEntityInWorldCoords(dryWeed1, offset)
    local sceneRot = GetEntityRotation(dryWeed1)

    local intros = {}

    local function createSceneWithEntities(pedAnim, entities)
        local scene = NetworkCreateSynchronisedScene(scenePos, sceneRot,
            2, true, false, -1, 0, 1.0)
        NetworkAddPedToSynchronisedScene(playerPed, scene,
            animDict, pedAnim,
            1.5, -4.0, 1, 16, 1148846080, 0)
        for _, e in pairs(entities) do
            NetworkAddEntityToSynchronisedScene(e.obj, scene,
                animDict, e.anim,
                1.0, 1.0, 1)
        end
        NetworkStartSynchronisedScene(scene)
        table.insert(intros, scene)
    end

    -- Scenes
    createSceneWithEntities('sorter_right_sort_v3_sorter02', {
        { obj = dryWeed1, anim = 'sorter_right_sort_v3_weeddry01a' },
        { obj = dryWeed2, anim = 'sorter_right_sort_v3_weeddry01a^1' },
        { obj = leaf1,    anim = 'sorter_right_sort_v3_weedleaf01a' },
    })

    createSceneWithEntities('sorter_right_sort_v3_sorter02', {
        { obj = leaf2,   anim = 'sorter_right_sort_v3_weedleaf01a^1' },
        { obj = weedBag, anim = 'sorter_right_sort_v3_weedbag01a' },
    })

    createSceneWithEntities('sorter_right_sort_v3_sorter02', {
        { obj = buds02a[1], anim = 'sorter_right_sort_v3_weedbud02a' },
    })

    createSceneWithEntities('sorter_right_sort_v3_sorter02', {
        { obj = buds02a[2], anim = 'sorter_right_sort_v3_weedbud02a^1' },
        { obj = buds02a[3], anim = 'sorter_right_sort_v3_weedbud02a^2' },
        { obj = bagPile,    anim = 'sorter_right_sort_v3_weedbagpile01a' },
    })

    local wait = (GetAnimDuration(animDict, 'sorter_right_sort_v3_sorter02') * 900)
    RemoveAnimDict(animDict)
    local success = Utils.progressBar({
        duration = wait,
        label = locale('progress'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = { car = true, combat = true, move = true, sprint = true }
    })

    for _, intro in pairs(intros) do NetworkStopSynchronisedScene(intro) end

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

local function playRollingScene()
    if not Utils.checkSkill(config.game.skillCheck, 'rolling') then
        return false
    end

    local success = Utils.progressBar({
        duration = 4000,
        label = locale('progress'),
        position = 'bottom',
        useWhileDead = false,
        canCancel = false,
        disable = {
            car = true,
            combat = true,
            move = true,
            sprint = true
        },
        anim = {
            scenario = 'PROP_HUMAN_PARKING_METER'
        }
    })

    if not success then
        return false
    end

    return true
end

local function getOutsideLab()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(1) end
    local labIndex = state.currentLabIndex or 1
    local response = lib.callback.await(_e('server:jobs:weed_job:getOutsideLab'), false)
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

    local response = lib.callback.await(_e('server:jobs:weed_job:getInsideLab'), false, labIndex)
    if not response or (type(response) == 'table' and response.error) then
        if type(response) == 'table' and response.error then
            lib.notify({ title = locale('error'), description = response.error, type = 'error' })
        end
        DoScreenFadeIn(1000)
        return false
    end

    local interiorSets = {}
    local sets = {
        'weed_low_security',
        'weed_upgrade_equip',
        'weed_set_up',
        'weed_chairs',
        'weed_production',
    }
    for _, stage in pairs({ 'a', 'c', 'd', 'h', }) do
        table.insert(sets, 'weed_hose' .. stage)
        table.insert(sets, 'weed_growth' .. stage .. '_stage3')
        table.insert(sets, 'light_growth' .. stage .. '_stage23_upgrade')
    end

    local hide = {
        'weed_standard_equip',
        'weed_upgrade_equip',
        'weed_low_security',
        'weed_security_upgrade',
        'weed_set_up',
        'weed_chairs',
        'weed_production',
        'weed_drying',
    }
    for _, stage in pairs({ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i' }) do
        table.insert(hide, 'weed_hose' .. stage)
        table.insert(hide, 'weed_growth' .. stage .. '_stage1')
        table.insert(hide, 'weed_growth' .. stage .. '_stage2')
        table.insert(hide, 'weed_growth' .. stage .. '_stage3')
        table.insert(hide, 'light_growth' .. stage .. '_stage23_standard')
        table.insert(hide, 'light_growth' .. stage .. '_stage23_upgrade')
    end

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

            if IsControlJustPressed(0, 47) then
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

local function createGatheringScene()
    local coords = {}
    if config.game.useShellInterior then
        coords = config.game.gatheringScene.coords.shell_interior
    else
        coords = config.game.gatheringScene.coords.mlo_interior
    end

    for _, data in pairs(coords) do
        local textUIShown = false
        local point

        point = lib.points.new({
            coords = data.coords,
            distance = 10.0,
            nearby = function(self)
                if not client.currentJob then return end

                DrawMarker(20, self.coords.x, self.coords.y, self.coords.z - .25, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    .5, .25, 0.5, 255, 255, 0, 255,
                    false, true, 2, true, nil, nil, false)

                if self.currentDistance <= 1.0 then
                    if not textUIShown then
                        textUIShown = true
                        Utils.showTextUI('[E] ' .. locale('weed_job.gather_weed'))
                    end

                    if IsControlJustPressed(0, 38) and not state.playerIsBusy then
                        state.playerIsBusy = true
                        Utils.hideTextUI()
                        textUIShown = false

                        local response = lib.callback.await(_e('server:jobs:weed_job:canGather'),
                            false, client.lobby.id)
                        if not response then
                            state.playerIsBusy = false
                        end
                        if response.error then
                            state.playerIsBusy = false
                            Utils.notify(response.error, 'error')
                            return
                        end

                        if not Utils.checkSkill(config.game.skillCheck, 'gathering') then
                            state.playerIsBusy = false
                            return
                        end

                        if not playGatheringScene(data) then
                            state.playerIsBusy = false
                            return
                        end
                        lib.callback.await(_e('server:jobs:weed_job:onGatherWeed'), false, client.lobby.id)

                        Citizen.Wait(1000)
                        state.playerIsBusy = false
                    end
                elseif textUIShown then
                    textUIShown = false
                    Utils.hideTextUI()
                end
            end
        })

        table.insert(state.gatheringPoints, point)
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
        local point
        local textUIShown = false

        point = lib.points.new({
            coords = data.coords,
            distance = 10.0,
            nearby = function(self)
                if not client.currentJob then return end

                DrawMarker(20, self.coords.x, self.coords.y, self.coords.z - .25, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    .5, .25, 0.5, 255, 255, 0, 255,
                    false, true, 2, true, nil, nil, false)

                if self.currentDistance <= 1.0 then
                    if not textUIShown then
                        textUIShown = true
                        Utils.showTextUI('[E] ' .. locale('weed_job.package_weed'))
                    end

                    if IsControlJustPressed(0, 38) and not state.playerIsBusy then
                        state.playerIsBusy = true
                        Utils.hideTextUI()
                        textUIShown = false

                        local response = lib.callback.await(_e('server:jobs:weed_job:canPackage'), false, client.lobby
                            .id)
                        if not response then
                            state.playerIsBusy = false
                        end
                        if response.error then
                            state.playerIsBusy = false
                            Utils.notify(response.error, 'error')
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

                        lib.callback.await(_e('server:jobs:weed_job:onPackageWeed'), false, client.lobby.id)
                        -- if math.random() < config.game.police_alert_chance then
                        --     Utils.triggerPoliceAlert('weed_job', locale("weed_job"))
                        -- end
                        Citizen.Wait(1000)
                        state.playerIsBusy = false
                    end
                elseif textUIShown then
                    textUIShown = false
                    Utils.hideTextUI()
                end
            end
        })

        table.insert(state.packingPoints, point)
    end
end

local function createRollingPoint()
    local coords = {}
    if config.game.useShellInterior then
        coords = config.game.rollingScene.coords.shell_interior
    else
        coords = config.game.rollingScene.coords.mlo_interior
    end

    for _, data in pairs(coords) do
        local point
        local textUIShown = false

        point = lib.points.new({
            coords = data.coords,
            distance = 10.0,
            nearby = function(self)
                if not client.currentJob then return end

                DrawMarker(20, self.coords.x, self.coords.y, self.coords.z - .25, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    .5, .25, 0.5, 255, 255, 0, 255,
                    false, true, 2, true, nil, nil, false)

                if self.currentDistance <= 1.0 then
                    if not textUIShown then
                        textUIShown = true
                        Utils.showTextUI('[E] ' .. locale('weed_job.roll_weed'))
                    end

                    if IsControlJustPressed(0, 38) and not state.playerIsBusy then
                        state.playerIsBusy = true
                        Utils.hideTextUI()
                        textUIShown = false

                        local response = lib.callback.await(_e('server:jobs:weed_job:canRoll'),
                            false, client.lobby.id)
                        if not response then
                            state.playerIsBusy = false
                            return
                        end
                        if response.error then
                            state.playerIsBusy = false
                            Utils.notify(response.error, 'error')
                            return
                        end

                        if not playRollingScene() then
                            state.playerIsBusy = false
                            return
                        end

                        lib.callback.await(_e('server:jobs:weed_job:onRollWeed'), false, client.lobby.id)
                        Citizen.Wait(1000)

                        state.playerIsBusy = false
                    end
                elseif textUIShown then
                    textUIShown = false
                    Utils.hideTextUI()
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
    if state.sceneObjects then
        for _, v in pairs(state.sceneObjects) do
            SetEntityAsMissionEntity(v, true, true)
            DeleteEntity(v)
        end
        state.sceneObjects = {}
    end
    if state.gatheringPoints then
        for _, p in pairs(state.gatheringPoints) do
            p:remove()
        end
        state.gatheringPoints = {}
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
                Utils.notify(locale('weed_job.no_lab_locations'), 'error')
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
        createGatheringScene()
        createPackingPoint()
        createRollingPoint()
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

exports('weed_job_play_scene', function(name, coords, offset, rotation)
    if not name or not coords or not offset or not rotation then
        print('[ERROR] Invalid parameters for weed_job_play_scene')
        return
    end

    local data = {
        coords = coords,
        offset = offset,
        rotation = rotation
    }

    state.playerIsBusy = true
    if name == 'gathering' then
        playGatheringScene(data)
    elseif name == 'packing' then
        playPackingScene(data)
    elseif name == 'rolling' then
        playRollingScene(data)
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
