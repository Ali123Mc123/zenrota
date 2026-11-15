local Utils = require 'modules.utils.client'
local Weather = require 'modules.weather.client'
local lib = lib

-- Constants


local JOB_KEY = 'meth_job'
local config = lib.load(('escrow.jobs.%s.config'):format(JOB_KEY))

local configReady = false

Citizen.CreateThread(function()
    while not client.isPlayerLoaded() do
        Wait(500)
    end

    local labLocations = lib.callback.await('meth_job:getLabLocations', false)
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
    cookPoints = {},
    hammerPoints = {},
    packingPoints = {},
    currentLabIndex = 1,
}

local function playCookScene(data)
    local playerPed = cache.ped

    local animDict = 'anim@amb@business@meth@meth_monitoring_cooking@cooking@'
    local ammoniaModel = 'bkr_prop_meth_ammonia'
    local sacidModel = 'bkr_prop_meth_sacid'
    local pencilModel = 'bkr_prop_fakeid_penclipboard'
    local clipboardModel = 'bkr_prop_fakeid_clipboard_01a'

    lib.requestAnimDict(animDict)
    lib.requestModel(ammoniaModel)
    lib.requestModel(sacidModel)
    lib.requestModel(pencilModel)
    lib.requestModel(clipboardModel)

    -- Create objects
    local ammonia = CreateObject(ammoniaModel, data.coords.x, data.coords.y, data.coords.z, true, true, false)
    SetEntityRotation(ammonia, data.rotation)
    table.insert(state.sceneObjects, ammonia)

    local sacid = CreateObject(sacidModel, data.coords.x, data.coords.y, data.coords.z, true, true, false)
    table.insert(state.sceneObjects, sacid)

    local pencil = CreateObject(pencilModel, data.coords.x, data.coords.y, data.coords.z, true, true, false)
    table.insert(state.sceneObjects, pencil)

    local clipboard = CreateObject(clipboardModel, data.coords.x, data.coords.y, data.coords.z, true, true, false)
    table.insert(state.sceneObjects, clipboard)

    -- Setup scene
    local scenePos = GetOffsetFromEntityInWorldCoords(ammonia, data.offset)
    local sceneRot = GetEntityRotation(ammonia)

    local scene01 = NetworkCreateSynchronisedScene(scenePos, sceneRot,
        2, true, false, -1, 0, 1.0)
    local scene02 = NetworkCreateSynchronisedScene(scenePos, sceneRot,
        2, true, false, -1, 0, 1.0)

    NetworkAddPedToSynchronisedScene(playerPed, scene01, animDict,
        'chemical_pour_short_cooker',
        1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(ammonia, scene01, animDict,
        'chemical_pour_short_ammonia',
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(sacid, scene01, animDict,
        'chemical_pour_short_sacid',
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(pencil, scene01, animDict,
        'chemical_pour_short_pencil',
        1.0, 1.0, 1)

    NetworkAddPedToSynchronisedScene(playerPed, scene02, animDict,
        'chemical_pour_short_cooker',
        1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(clipboard, scene02, animDict,
        'chemical_pour_short_clipboard',
        1.0, 1.0, 1)

    NetworkStartSynchronisedScene(scene01)
    NetworkStartSynchronisedScene(scene02)

    local wait = GetAnimDuration(animDict, 'chemical_pour_short_cooker') * 750

    RemoveAnimDict(animDict)
    SetModelAsNoLongerNeeded(ammoniaModel)
    SetModelAsNoLongerNeeded(sacidModel)
    SetModelAsNoLongerNeeded(pencilModel)
    SetModelAsNoLongerNeeded(clipboardModel)

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
    NetworkStopSynchronisedScene(scene02)

    ClearPedTasks(playerPed)

    for _, obj in pairs(state.sceneObjects) do
        if DoesEntityExist(obj) then
            SetEntityAsMissionEntity(obj, true, true)
            DeleteEntity(obj)
        end
    end

    state.sceneObjects = {}

    if not success then
        return false
    end
    return true
end

local function playHammerScene(data)
    local playerPed = cache.ped
    local animDict = 'anim@amb@business@meth@meth_smash_weight_check@'

    local tray2aModel = 'bkr_prop_meth_tray_02a'
    local hammerModel = 'w_me_hammer'
    local tray1aModel = 'bkr_prop_meth_tray_01a'
    local smashedTrayModel = 'bkr_prop_meth_smashedtray_01_frag_'
    local bigbagModel = 'bkr_prop_meth_bigbag_02a'

    lib.requestAnimDict(animDict)
    lib.requestModel(tray2aModel)
    lib.requestModel(hammerModel)
    lib.requestModel(tray1aModel)
    lib.requestModel(smashedTrayModel)
    lib.requestModel(bigbagModel)

    -- Object oluşturma
    local tray2a = CreateObject(tray2aModel, data.coords.x, data.coords.y, data.coords.z, true, true, false)
    SetEntityRotation(tray2a, data.rotation)
    table.insert(state.sceneObjects, tray2a)

    local hammer = CreateObject(hammerModel, data.coords.x, data.coords.y, data.coords.z, true, true, false)
    table.insert(state.sceneObjects, hammer)

    local tray1a = CreateObject(tray1aModel, data.coords.x, data.coords.y, data.coords.z, true, true, false)
    table.insert(state.sceneObjects, tray1a)

    local smashedTray = CreateObject(smashedTrayModel, data.coords.x, data.coords.y, data.coords.z, true, true, false)
    table.insert(state.sceneObjects, smashedTray)

    local bigbag = CreateObject(bigbagModel, data.coords.x, data.coords.y, data.coords.z, true, true, false)
    table.insert(state.sceneObjects, bigbag)

    -- Sahne pozisyonu
    local scenePos = GetOffsetFromEntityInWorldCoords(tray2a, data.offset)
    local sceneRot = GetEntityRotation(tray2a)

    local scene01 = NetworkCreateSynchronisedScene(scenePos, sceneRot,
        2, true, false, -1, 0, 1.0)
    local scene02 = NetworkCreateSynchronisedScene(scenePos, sceneRot,
        2, true, false, -1, 0, 1.0)

    -- Sahne 1
    NetworkAddPedToSynchronisedScene(playerPed, scene01, animDict,
        'break_weigh_char02',
        1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(tray2a, scene01, animDict,
        'break_weigh_tray01^2',
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(hammer, scene01, animDict,
        'break_weigh_hammer',
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(tray1a, scene01, animDict,
        'break_weigh_tray01^1',
        1.0, 1.0, 1)

    -- Sahne 2
    NetworkAddPedToSynchronisedScene(playerPed, scene02, animDict,
        'break_weigh_char02',
        1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(smashedTray, scene02, animDict,
        'break_weigh_tray01',
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(bigbag, scene02, animDict,
        'break_weigh_box01^1',
        1.0, 1.0, 1)

    -- Animasyonları başlat
    NetworkStartSynchronisedScene(scene01)
    NetworkStartSynchronisedScene(scene02)

    local wait = GetAnimDuration(animDict, 'break_weigh_char02') * 750

    -- Temizlik için hazırlık
    RemoveAnimDict(animDict)
    SetModelAsNoLongerNeeded(tray2aModel)
    SetModelAsNoLongerNeeded(hammerModel)
    SetModelAsNoLongerNeeded(tray1aModel)
    SetModelAsNoLongerNeeded(smashedTrayModel)
    SetModelAsNoLongerNeeded(bigbagModel)

    -- İlerleme çubuğu
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
    NetworkStopSynchronisedScene(scene02)

    -- Temizlik
    ClearPedTasks(playerPed)

    for _, obj in pairs(state.sceneObjects) do
        if DoesEntityExist(obj) then
            SetEntityAsMissionEntity(obj, true, true)
            DeleteEntity(obj)
        end
    end

    state.sceneObjects = {}

    if not success then
        return false
    end

    return true
end

local function playPackingScene(data)
    local playerPed = cache.ped
    local animDict = 'anim@amb@business@meth@meth_smash_weight_check@'

    -- Model tanımları
    local models = {
        box1 = 'bkr_prop_meth_bigbag_04a',
        box2 = 'bkr_prop_meth_bigbag_03a',
        clipboard = 'bkr_prop_fakeid_clipboard_01a',
        pencil = 'bkr_prop_fakeid_penclipboard',
        scale = 'bkr_prop_coke_scale_01',
        scoop = 'bkr_prop_meth_scoop_01a',
        methBag = 'bkr_prop_meth_openbag_02',
    }

    -- Gerekli animasyon ve modellerin yüklenmesi
    lib.requestAnimDict(animDict)
    for _, model in pairs(models) do lib.requestModel(model) end

    -- Object oluşturma
    local coords, rotation = data.coords, data.rotation
    local function spawn(model)
        local obj = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
        table.insert(state.sceneObjects, obj)
        return obj
    end

    local box1 = spawn(models.box1)
    SetEntityRotation(box1, rotation)

    local box2 = spawn(models.box2)
    local clipboard = spawn(models.clipboard)
    local pencil = spawn(models.pencil)
    local scale = spawn(models.scale)
    local scoop = spawn(models.scoop)

    local methBags = {}
    for i = 1, 7 do
        methBags[i] = spawn(models.methBag)
    end

    -- Sahne pozisyonu
    local scenePos = GetOffsetFromEntityInWorldCoords(box1, data.offset)
    local sceneRot = GetEntityRotation(box1)

    -- Senkronize sahneler oluşturuluyor
    local scenes = {}
    for i = 1, 5 do
        scenes[i] = NetworkCreateSynchronisedScene(scenePos, sceneRot,
            2, true, false, -1, 0, 1.0)
    end

    -- Sahne 1
    NetworkAddPedToSynchronisedScene(playerPed, scenes[1], animDict,
        'break_weigh_v3_char01',
        1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(box1, scenes[1], animDict,
        'break_weigh_v3_box01',
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(box2, scenes[1], animDict,
        'break_weigh_v3_box01^1',
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(clipboard, scenes[1], animDict,
        'break_weigh_v3_clipboard',
        1.0, 1.0, 1)

    -- Sahne 2
    NetworkAddPedToSynchronisedScene(playerPed, scenes[2], animDict,
        'break_weigh_v3_char01',
        1.5, -4.0, 1, 16, 1148846080, 0)

    for i = 1, 3 do
        NetworkAddEntityToSynchronisedScene(methBags[i], scenes[2], animDict,
            'break_weigh_v3_methbag01' .. (i == 1 and '' or '^' .. (i - 1)),
            1.0, 1.0, 1)
    end

    -- Sahne 3
    NetworkAddPedToSynchronisedScene(playerPed, scenes[3], animDict,
        'break_weigh_v3_char01',
        1.5, -4.0, 1, 16, 1148846080, 0)
    for i = 4, 6 do
        NetworkAddEntityToSynchronisedScene(methBags[i], scenes[3], animDict,
            'break_weigh_v3_methbag01^' .. (i - 1),
            1.0, 1.0, 1)
    end

    -- Sahne 4
    NetworkAddPedToSynchronisedScene(playerPed, scenes[4], animDict,
        'break_weigh_v3_char01',
        1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(methBags[7], scenes[4], animDict,
        'break_weigh_v3_methbag01^6',
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(pencil, scenes[4], animDict,
        'break_weigh_v3_pen', 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(scale, scenes[4], animDict,
        'break_weigh_v3_scale',
        1.0, 1.0, 1)

    -- Sahne 5
    NetworkAddPedToSynchronisedScene(playerPed, scenes[5], animDict,
        'break_weigh_v3_char01',
        1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(scale, scenes[5], animDict,
        'break_weigh_v3_scale',
        1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(scoop, scenes[5], animDict,
        'break_weigh_v3_scoop',
        1.0, 1.0, 1)

    -- Animasyonları başlat
    for _, scene in pairs(scenes) do
        NetworkStartSynchronisedScene(scene)
    end

    -- Süre alma ve progress bar
    local wait = GetAnimDuration(animDict, 'break_weigh_v3_char01') * 850
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

    -- Animasyonları başlat
    for _, scene in pairs(scenes) do
        NetworkStopSynchronisedScene(scene)
    end

    -- Temizlik
    ClearPedTasks(playerPed)
    RemoveAnimDict(animDict)
    for _, model in pairs(models) do SetModelAsNoLongerNeeded(model) end
    for _, obj in pairs(state.sceneObjects) do
        if DoesEntityExist(obj) then
            SetEntityAsMissionEntity(obj, true, true)
            DeleteEntity(obj)
        end
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
    local response = lib.callback.await(_e('server:jobs:meth_job:getOutsideLab'), false)
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

    local response = lib.callback.await(_e('server:jobs:meth_job:getInsideLab'), false, labIndex)
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
        'meth_lab_setup',
        'meth_lab_production',
        'meth_lab_upgrade',
    }
    local hide = {
        'meth_lab_basic',
        'meth_lab_upgrade',
        'meth_lab_production',
        'meth_lab_security_high',
        'meth_lab_setup',
        'meth_lab_empty',
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

local function createCookPoints()
    local coords = {}
    if config.game.useShellInterior then
        coords = config.game.cookScene.coords.shell_interior
    else
        coords = config.game.cookScene.coords.mlo_interior
    end

    for _, data in pairs(coords) do
        local point = lib.points.new({
            coords = data.coords,
            distance = 1.0,
            onEnter = function(self)
                if not client.currentJob then return end
                Utils.showTextUI('[E] ' .. locale('meth_job.cook'))
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
                    local response = lib.callback.await(_e('server:jobs:meth_job:canCook'),
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
                    if not Utils.checkSkill(config.game.skillCheck, 'cooking') then
                        state.playerIsBusy = false
                        return
                    end

                    if not playCookScene(data) then
                        state.playerIsBusy = false
                        return
                    end

                    lib.callback.await(_e('server:jobs:meth_job:onCookMeth'), false, client.lobby.id)
                    Citizen.Wait(1000)
                    state.playerIsBusy = false
                    self:onEnter()
                end
            end
        })
        table.insert(state.cookPoints, point)
    end
end

local function createHammerPoints()
    local coords = {}
    if config.game.useShellInterior then
        coords = config.game.hammerScene.coords.shell_interior
    else
        coords = config.game.hammerScene.coords.mlo_interior
    end

    for _, data in pairs(coords) do
        local point = lib.points.new({
            coords = data.coords,
            distance = 1.0,
            onEnter = function(self)
                if not client.currentJob then return end
                Utils.showTextUI('[E] ' .. locale('meth_job.hammer'))
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
                    local response = lib.callback.await(_e('server:jobs:meth_job:canHammer'),
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
                    if not Utils.checkSkill(config.game.skillCheck, 'hammering') then
                        state.playerIsBusy = false
                        return
                    end

                    if not playHammerScene(data) then
                        state.playerIsBusy = false
                        return
                    end

                    lib.callback.await(_e('server:jobs:meth_job:onHammerMeth'), false, client.lobby.id)
                    Citizen.Wait(1000)
                    state.playerIsBusy = false
                    self:onEnter()
                end
            end
        })
        table.insert(state.hammerPoints, point)
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
                Utils.showTextUI('[E] ' .. locale('meth_job.package_meth'))
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
                    local response = lib.callback.await(_e('server:jobs:meth_job:canPackage'),
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

                    lib.callback.await(_e('server:jobs:meth_job:onPackageMeth'), false, client.lobby.id)
                    -- if math.random() < config.game.police_alert_chance then
                    --     Utils.triggerPoliceAlert('meth_job', locale("meth_job"))
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
    if state.cookPoints then
        for _, p in pairs(state.cookPoints) do
            p:remove()
        end
        state.cookPoints = {}
    end
    if state.hammerPoints then
        for _, p in pairs(state.hammerPoints) do
            p:remove()
        end
        state.hammerPoints = {}
    end
    if state.packingPoints then
        for _, p in pairs(state.packingPoints) do
            p:remove()
        end
        state.packingPoints = {}
    end
    if state.sceneObjects then
        for _, v in pairs(state.sceneObjects) do
            SetEntityAsMissionEntity(v, true, true)
            DeleteEntity(v)
        end
        state.sceneObjects = {}
    end
    state.playerIsBusy = false
end

function job.restoreLabInterior(labIndex)
    state.currentLabIndex = labIndex
    if config.game.useShellInterior then
        if Weather and Weather.disableSync then
            Weather.disableSync()
        end
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
                Utils.notify(locale('meth_job.no_lab_locations'), 'error')
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
        createCookPoints()
        createHammerPoints()
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

exports('meth_job_play_scene', function(name, coords, offset, rotation)
    if not name or not coords or not offset or not rotation then
        print('[ERROR] Invalid parameters for meth_job_play_scene')
        return
    end

    local data = {
        coords = coords,
        offset = offset,
        rotation = rotation
    }

    state.playerIsBusy = true
    if name == 'cook' then
        playCookScene(data)
    elseif name == 'hammer' then
        playHammerScene(data)
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
