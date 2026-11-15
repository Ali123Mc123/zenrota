--[[
    JobCount - Client
    -----------------------------------------------------------
    Sunucudaki cache'i sorgulamak icin ince kopru.
    Admin menusu: /jobmenu komutu ile ox_lib context menu acilir.
]]

local function getJobCount(jobName)
    if not jobName then return 0 end
    return lib.callback.await('can9work:jobCount:get', false, jobName) or 0
end

local function getAllJobCounts()
    return lib.callback.await('can9work:jobCount:getAll', false) or {}
end

exports('GetJobCount', getJobCount)
exports('GetAllJobCounts', getAllJobCounts)

------------------------------------------------------------
-- Admin Paneli - ox_lib context menu
------------------------------------------------------------

local function openJobMenu(data)
    -- Her meslek icin oyuncu listesi alt menusu
    for _, job in ipairs(data.jobs or {}) do
        local subOptions = {
            {
                title = 'Toplam Aktif: ' .. tostring(job.count) .. ' oyuncu',
                disabled = true,
            }
        }

        if job.players and #job.players > 0 then
            for _, p in ipairs(job.players) do
                subOptions[#subOptions + 1] = {
                    title = tostring(p.name),
                    description = 'ID: ' .. tostring(p.src) .. '  |  CID: ' .. tostring(p.citizenid),
                    disabled = true,
                }
            end
        else
            subOptions[#subOptions + 1] = {
                title = 'Oyuncu bulunamadı',
                disabled = true,
            }
        end

        lib.registerContext({
            id = 'can9work_jobcount_' .. tostring(job.name),
            title = tostring(job.name),
            menu = 'can9work_jobcount_main',
            options = subOptions,
        })
    end

    -- Ana menu
    local options = {
        {
            title = 'Yenile',
            description = 'Anlık veriyi sunucudan tekrar çek',
            onSelect = function()
                TriggerServerEvent('can9work:jobCount:refresh')
            end,
        },
        {
            title = 'Toplam Online: ' .. tostring(data.total) .. ' oyuncu',
            disabled = true,
        },
    }

    if not data.jobs or #data.jobs == 0 then
        options[#options + 1] = {
            title = 'Online oyuncu yok',
            disabled = true,
        }
    else
        for _, job in ipairs(data.jobs) do
            options[#options + 1] = {
                title = tostring(job.name),
                description = 'Aktif: ' .. tostring(job.count) .. ' oyuncu',
                arrow = true,
                menu = 'can9work_jobcount_' .. tostring(job.name),
            }
        end
    end

    lib.registerContext({
        id = 'can9work_jobcount_main',
        title = 'Meslek Aktiflik Paneli',
        options = options,
    })

    lib.showContext('can9work_jobcount_main')
end

------------------------------------------------------------
-- Sunucu olayi alindıgında menuyu ac
------------------------------------------------------------

RegisterNetEvent('can9work:jobCount:openMenu', function(data)
    if not data then return end
    openJobMenu(data)
end)

