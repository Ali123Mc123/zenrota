CreateThread(function()
    for i, npcConfig in ipairs(Config.NPC) do
        local model = GetHashKey(npcConfig.model)
        RequestModel(model)
        local timeout = GetGameTimer() + 5000
        while not HasModelLoaded(model) do
            if GetGameTimer() > timeout then
                DebugPrint('ERROR: Failed to load NPC model:', npcConfig.model, '(index', i, ')')
                goto continue
            end
            Wait(10)
        end

        local npcPed = CreatePed(4, model, npcConfig.coords.x, npcConfig.coords.y, npcConfig.coords.z - 1.0, npcConfig.coords.w, false, true)
        FreezeEntityPosition(npcPed, true)
        SetEntityInvincible(npcPed, true)
        SetBlockingOfNonTemporaryEvents(npcPed, true)
        TaskStartScenarioInPlace(npcPed, npcConfig.scenario, 0, true)

        ClientState.npcPeds = ClientState.npcPeds or {}
        ClientState.npcPeds[i] = npcPed

        -- Varsayılan olarak ilk NPC ped'i geriye dönük uyumluluk için sakla
        if i == 1 then ClientState.npcPed = npcPed end

        if npcConfig.blip and npcConfig.blip.enabled then
            local blip = AddBlipForCoord(npcConfig.coords.x, npcConfig.coords.y, npcConfig.coords.z)
            SetBlipSprite(blip, npcConfig.blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, npcConfig.blip.scale)
            SetBlipColour(blip, npcConfig.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(npcConfig.blip.label)
            EndTextCommandSetBlipName(blip)
        end

        local npcIndex = i
        local targetOptions = {
            {
                name     = 'krypton_farming_npc_' .. i,
                icon     = 'fas fa-tractor',
                label    = T('npc_target_label'),
                distance = Config.DistanceToInteract or 2.5,
                onSelect = function()
                    ClientState.activeNpcIndex = npcIndex
                    ClientState.npcPed = npcPed
                    TriggerEvent('krypton-farming:client:requestOpen')
                end
            }
        }
        if Target and Target.AddLocalEntity then
            Target.AddLocalEntity(npcPed, targetOptions)
        end

        DebugPrint('NPC', i, 'spawned at', npcConfig.coords)
        ::continue::
    end
end)

DebugPrint('NPC module loaded')
