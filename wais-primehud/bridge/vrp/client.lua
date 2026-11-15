local extensionStarted = false

local function startExtension()
    if extensionStarted then return end
    extensionStarted = true

    CreateThread(function()
        local resource = GetCurrentResourceName()

        for _ = 1, 30 do
            if vrpProxyCall('vRP', 'loadScript', resource, 'bridge/vrp/client_ext') then
                return
            end
            Wait(1000)
        end

        extensionStarted = false
    end)
end

local function applySync(patch)
    local data = wFramework.VrpData
    local loaded = wFramework.PlayerLoaded

    if patch.version == 2 then
        startExtension()
    end

    if patch.hunger ~= nil then wFramework.Status.hunger = patch.hunger end
    if patch.thirst ~= nil then wFramework.Status.thirst = patch.thirst end

    if patch.cash ~= nil then
        data.cash = patch.cash
        if loaded then wFramework.SetPlayerMoney(patch.cash) end
    end

    if patch.bank ~= nil then
        data.bank = patch.bank
        if loaded then wFramework.SetPlayerBank(patch.bank) end
    end

    if patch.black ~= nil then
        data.black = patch.black
        if loaded then
            wFramework.Money.blackMoney = patch.black
            wFramework.sendBlackMoneyToUI()
        end
    end

    if patch.name ~= nil then
        data.name = patch.name
    end

    if patch.job ~= nil then
        local job = { name = patch.job, label = patch.job, grade = { name = '' } }
        data.job = job
        if loaded then wFramework.SetPlayerJob(job) end
    end

    if patch.gang ~= nil then
        local label = patch.gang ~= '' and patch.gang or Lang('unknown')
        local gang = { label = label, grade = { name = '' } }
        data.gang = gang
        if loaded then wFramework.SetPlayerGang(gang) end
    end
end

RegisterNetEvent('wais:primehud:vrp:sync', function(patch)
    if type(patch) == 'table' then
        applySync(patch)
    end
end)
