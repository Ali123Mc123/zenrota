local Utils = require 'modules.utils.client'
local Target = require 'modules.target.client'
local lib = lib

-- Constants

local JOB_KEY = 'npc_boxing'
local config = lib.load(('escrow.jobs.%s.config'):format(JOB_KEY))

local job = {}

local state = {
    npc = { entity = nil, blip = nil },
    isSpectatorsSpawned = false,
    spawnedSpectators = {},
    ringZone = nil,
}

local function deleteSpawnedNPC()
    if DoesEntityExist(state.npc.entity) then
        DeleteEntity(state.npc.entity)
    end
    if state.npc.blip then
        RemoveBlip(state.npc.blip)
    end
    state.npc = {}
end

local function createContactNpc()
    local model = config.game.npc_model
    local npcLocation = client.currentJob.game.location.npc_location
    lib.requestModel(model)

    local npcEntity = CreatePed(4, model, npcLocation.x, npcLocation.y, npcLocation.z, npcLocation.w or 0.0,
        false, false)
    while not DoesEntityExist(npcEntity) do Wait(0) end

    FreezeEntityPosition(npcEntity, true)
    SetPedDiesWhenInjured(npcEntity, false)
    SetEntityInvincible(npcEntity, true)
    TaskSetBlockingOfNonTemporaryEvents(npcEntity, true)
    SetBlockingOfNonTemporaryEvents(npcEntity, true)
    SetModelAsNoLongerNeeded(model)

    state.npc.entity = npcEntity

    state.npc.blip = Utils.addBlip(npcEntity, config.blips.contact_npc, true)

    return true
end

local function addTargetToNpc()
    local npc = state.npc.entity

    if not DoesEntityExist(npc) then
        return lib.print.warn('Debug: npc_boxing contact npc not spawned!')
    end

    Target.addLocalEntity(npc, { {
        label = locale('npc_boxing.start_match'),
        icon = 'fa-regular fa-circle',
        distance = 2.0,
        canInteract = function()
            return client.currentJob and not client.currentJob.game.onMatchStart
        end,
        onSelect = function()
            lib.callback.await(_e('server:jobs:npc_boxing:startMatch'), false, client.lobby.id)
        end
    } })
end

local function stopActiveMatch(why)
    if why == 'onexitring' then
        Utils.notify(locale('npc_boxing.left_ring'), 'error')
    end
    lib.callback.await(_e('server:jobs:npc_boxing:stopMatch'),
        false, client.lobby.id, why)
end

local function spawnSpectators()
    if state.isSpectatorsSpawned then return end
    local spectatorPositions = client.currentJob.game.location.spectator_locations
    local spectatorModels = config.game.spectatorModels
    for _, pos in pairs(spectatorPositions) do
        local model = spectatorModels[math.random(#spectatorModels)]
        lib.requestModel(model)

        local ped = CreatePed(4, model, pos.x, pos.y, pos.z, pos.w, false, false)
        SetEntityInvincible(ped, true)
        SetPedDiesWhenInjured(ped, false)
        SetEntityInvincible(ped, true)
        TaskSetBlockingOfNonTemporaryEvents(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        -- Choose a random animation scenario
        local scenarios = {
            'WORLD_HUMAN_CHEERING',
            'WORLD_HUMAN_STAND_IMPATIENT',
            'WORLD_HUMAN_STAND_MOBILE',
        }
        local scenario = scenarios[math.random(#scenarios)]

        TaskStartScenarioInPlace(ped, scenario, 0, true)
        SetModelAsNoLongerNeeded(model)
        table.insert(state.spawnedSpectators, ped)
    end

    state.isSpectatorsSpawned = true
end

local function createFighterNpc(index, coords)
    local data = config.game.fighters[index]
    if not data then
        print('Fighter data not found for index:', index)
        return
    end

    local count = data.count or 1

    for i = 1, count do
        -- Eğer birden fazla NPC spawn edilecekse, her birini hafifçe farklı konumlara koy
        local offset = (i - 1) * 1.5
        local spawnCoords = vector4(coords.x + offset, coords.y, coords.z, coords.w or 0.0)

        lib.requestModel(data.model)

        local ped = CreatePed(4, data.model, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w, false, false)

        SetEntityHealth(ped, data.health)
        SetPedArmour(ped, data.armor)
        SetPedAccuracy(ped, data.accuracy or 30)
        SetPedFleeAttributes(ped, 0, false)
        SetPedCombatAttributes(ped, 46, true)
        SetPedCombatRange(ped, 2)
        SetPedCombatAbility(ped, 2)

        RemoveAllPedWeapons(ped, true)

        if data.weapon then
            GiveWeaponToPed(ped, data.weapon, 999, false, true)
        end

        SetModelAsNoLongerNeeded(data.model)

        data.entities = data.entities or {}
        table.insert(data.entities, ped)
    end
end

local function getAliveNpc(entities)
    for _, npcPed in ipairs(entities) do
        if DoesEntityExist(npcPed) and not IsEntityDead(npcPed) then
            return npcPed
        end
    end
    return nil
end

local function handleMatchEnd(winnerPed, loserPed, result)
    if loserPed and DoesEntityExist(loserPed) then
        ClearPedTasksImmediately(loserPed)
    end
    if winnerPed and DoesEntityExist(winnerPed) then
        ClearPedTasksImmediately(winnerPed)
    end

    if loserPed and DoesEntityExist(loserPed) then
        local dict = 'combat@damage@writhe'
        local anim = 'writhe_loop'
        lib.requestAnimDict(dict)
        TaskPlayAnim(loserPed, dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
        SetPedCanRagdoll(loserPed, false)
        RemoveAnimDict(dict)
    end

    if winnerPed and DoesEntityExist(winnerPed) then
        local winAnims = {
            { dict = 'anim@mp_player_intcelebrationmale@shadow_boxing', anim = 'shadow_boxing' },
            { dict = 'anim@mp_player_intcelebrationmale@thumbs_up',     anim = 'thumbs_up' },
            { dict = 'anim@mp_player_intcelebrationmale@cut_throat',    anim = 'cut_throat' }
        }
        local choice = winAnims[math.random(#winAnims)]
        lib.requestAnimDict(choice.dict)
        TaskPlayAnim(winnerPed, choice.dict, choice.anim, 8.0, -8.0, 3000, 1, 0, false, false, false)
        PlaySoundFrontend(-1, 'Oneshot_Final', 'MP_MISSION_COUNTDOWN_SOUNDSET', 0)
        if winnerPed == cache.ped then
            StartScreenEffect('SuccessFranklin', 2000, false)
        end
        ShakeGameplayCam('SMALL_EXPLOSION_SHAKE', 0.25)
        RemoveAnimDict(choice.dict)
    end

    Wait(3000)

    if loserPed and DoesEntityExist(loserPed) then
        SetPedCanRagdoll(loserPed, true)
    end

    stopActiveMatch(result)
end

local function watchFightResult(fighterIndex)
    local entities = config.game.fighters[fighterIndex] and config.game.fighters[fighterIndex].entities
    if not entities or type(entities) ~= 'table' or #entities == 0 then return end

    Citizen.CreateThread(function()
        while client.currentJob do
            if not client.currentJob.game.onMatchStart then break end

            local currentWeapon = GetSelectedPedWeapon(cache.ped)
            if currentWeapon ~= joaat('WEAPON_UNARMED') then
                RemoveWeaponFromPed(cache.ped, currentWeapon)
                SetCurrentPedWeapon(cache.ped, joaat('WEAPON_UNARMED'), true)
            end

            local playerDead = IsEntityDead(cache.ped)
            local allNpcsDead = true
            local deadNpc = nil

            for _, npcPed in ipairs(entities) do
                if DoesEntityExist(npcPed) then
                    if not IsEntityDead(npcPed) then
                        allNpcsDead = false
                    else
                        deadNpc = npcPed
                    end
                end
            end

            if playerDead or allNpcsDead then
                local winnerPed, loserPed
                local result = 'draw'

                if playerDead and not allNpcsDead then
                    result = 'lose'
                    winnerPed = getAliveNpc(entities)
                    loserPed = cache.ped
                elseif allNpcsDead and not playerDead then
                    result = 'win'
                    winnerPed = cache.ped
                    loserPed = deadNpc
                elseif playerDead and allNpcsDead then
                    result = 'draw'
                    winnerPed = nil
                    loserPed = nil
                end

                handleMatchEnd(winnerPed, loserPed, result)
                break
            end

            Wait(200)
        end
    end)
end

local function createFighters()
    local opponent_1 = client.currentJob.game.location.opponent_1
    local opponent_2 = client.currentJob.game.location.opponent_2

    -- Oyuncuyu ringe yerleştir
    SetEntityCoords(cache.ped, opponent_1.x, opponent_1.y, opponent_1.z)
    SetEntityHeading(cache.ped, opponent_1.w)
    FreezeEntityPosition(cache.ped, true)

    -- Rakip seviyesini al ve NPC oluştur
    local fighterIndex = client.currentJob.steps[2].progress.current + 1
    createFighterNpc(fighterIndex, opponent_2)

    -- NPC oyuncuya saldırmalı
    local entities = config.game.fighters[fighterIndex] and config.game.fighters[fighterIndex].entities
    for _, value in pairs(entities) do
        if value then TaskCombatPed(value, cache.ped, 0, 16) end
        FreezeEntityPosition(value, true)
    end

    Citizen.CreateThread(function()
        for i = 3, 1, -1 do
            Utils.notify(locale('npc_boxing.match_is_about_start', i))
            Wait(1000)
        end

        FreezeEntityPosition(cache.ped, false)
        for _, value in pairs(entities) do
            if value then TaskCombatPed(value, cache.ped, 0, 16) end
            FreezeEntityPosition(value, false)
        end

        watchFightResult(fighterIndex)
    end)
end

local function createRingZone()
    local corners = client.currentJob.game.location.arena_location.corners

    state.ringZone = lib.zones.poly({
        points = corners,
        thickness = 4,
        onExit = function()
            state.ringZone:remove()
            state.ringZone = nil
            stopActiveMatch('onexitring')
        end,
    })

    Citizen.CreateThread(function()
        while client.currentJob and client.currentJob.game.onMatchStart do
            for i = 1, #corners do
                local current = corners[i]
                local next = corners[(i % #corners) + 1]

                DisableControlAction(0, 21, true) -- 21 = INPUT_SPRINT (SHIFT)

                DrawLine(
                    current.x, current.y, current.z - 0.25,
                    next.x, next.y, next.z - 0.25,
                    255, 0, 0, 255 -- red
                )
            end
            Wait(0)
        end
    end)
end

function job.cleanup()
    deleteSpawnedNPC()
    if state.ringZone then
        state.ringZone:remove()
        state.ringZone = nil
    end
    if IsEntityPositionFrozen(cache.ped) then
        FreezeEntityPosition(cache.ped, false)
    end
    for _, value in pairs(config.game.fighters) do
        if value.entities then
            for _, fighter in pairs(value.entities) do
                if DoesEntityExist(fighter) then
                    DeleteEntity(fighter)
                end
            end
        end
        value.entities = {}
    end
    if state.isSpectatorsSpawned then
        for _, value in pairs(state.spawnedSpectators) do
            DeleteEntity(value)
        end
        state.spawnedSpectators = {}
        state.isSpectatorsSpawned = false
    end
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
        createContactNpc()
        addTargetToNpc()
        return true
    elseif stepIndex == 2 then
        return true
    end

    if client.lobby.owner == cache.serverId then
        lib.callback.await(_e('server:jobs:finishJob'), false, client.lobby.id)
    end

    return false
end

function job.onStepDone(stepIndex)
    if stepIndex == 1 then
    elseif stepIndex == 2 then
    end

    return job.onStepStart(stepIndex + 1)
end

-- events

RegisterNetEvent(_e('client:jobs:npc_boxing:onMatchStart'), function(fighter)
    if not client.currentJob then return end
    client.currentJob.game.onMatchStart = true
    if fighter ~= cache.serverId then return end
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(1) end
    spawnSpectators()
    createFighters()
    createRingZone()
    DoScreenFadeIn(500)
    local pos = GetEntityCoords(cache.ped, true)
    NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, GetEntityHeading(cache.ped), true, false)
    SetEntityInvincible(cache.ped, false)
end)

RegisterNetEvent(_e('client:jobs:npc_boxing:onMatchStop'), function(fighter, goNext, newIndex)
    if not client.currentJob then return end
    if not goNext then
        client.currentJob.game.onMatchStart = false
    end
    if fighter ~= cache.serverId then return end
    if state.ringZone then
        state.ringZone:remove()
        state.ringZone = nil
    end

    for _, value in pairs(config.game.fighters) do
        if value.entities then
            for _, fighter in pairs(value.entities) do
                if DoesEntityExist(fighter) then SetEntityAsNoLongerNeeded(fighter) end
            end
        end
        value.entities = {}
    end

    if goNext then
        for i = 5, 1, -1 do
            Utils.notify(locale('npc_boxing.match_is_about_start', i))
            Wait(1000)
        end
        DoScreenFadeOut(250)
        while not IsScreenFadedOut() do Wait(1) end
        createFighters()
        DoScreenFadeIn(500)
        local pos = GetEntityCoords(cache.ped, true)
        NetworkResurrectLocalPlayer(pos.x, pos.y, pos.z, GetEntityHeading(cache.ped), true, false)
        Utils.revivePlayerWithAmbulanceScript()
        SetEntityInvincible(cache.ped, false)
    end
end)

--[[ Register ]]
Jobs.register(JOB_KEY, job)
