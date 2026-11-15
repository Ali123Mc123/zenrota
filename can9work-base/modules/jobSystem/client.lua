RegisterCommand('meslekdegistir', function()
    local PlayerData = exports.qbx_core:GetPlayerData()
    local jobs = PlayerData.jobs
    local options = {}

    local count = 0
    for jobName, gradeLevel in pairs(jobs) do
        count = count + 1

        local jobInfo = exports.qbx_core:GetJobs()[jobName]
        if jobInfo then
            local gradeInfo = jobInfo.grades[tostring(gradeLevel)] or jobInfo.grades[gradeLevel]
            local gradeLabel = gradeInfo and gradeInfo.name or 'Grade ' .. gradeLevel

            table.insert(options, {
                title = jobInfo.label,
                description = 'Rütbe: ' .. gradeLabel,
                icon = 'briefcase',
                onSelect = function()
                    TriggerServerEvent('can9work:server:switchJob', jobName)
                end,
                metadata = PlayerData.job.name == jobName and {
                    { label = 'Durum', value = 'Şu anki Mesleğin', color = 'green' }
                } or nil
            })
        end
    end

    local isCurrentJobValid = jobs[PlayerData.job.name] ~= nil

    if count == 0 or (count == 1 and isCurrentJobValid) then
        return exports.qbx_core:Notify('Geçiş yapabileceğiniz ek bir mesleğiniz bulunmuyor.', 'error')
    end

    lib.registerContext({
        id = 'meslek_degis_context',
        title = 'Meslek Değiştir',
        options = options
    })

    lib.showContext('meslek_degis_context')
end, false)

RegisterNetEvent('can9work:client:admin:openJobManagement', function(allJobs)
    local options = {}

    for jobName, jobInfo in pairs(allJobs) do
        table.insert(options, {
            title = jobInfo.label .. ' (' .. jobName .. ')',
            onSelect = function()
                -- Oyuncuları callback ile çek
                lib.callback('can9work:server:admin:getJobPlayers', false, function(players)
                    if not players then
                        return exports.qbx_core:Notify('Oyuncu verileri alınamadı.', 'error')
                    end

                    local subOptions = {
                        {
                            title = 'TÜMÜNÜ BU MESLEKTEN KOV',
                            description = 'Bu mesleğe sahip herkesi (Online/Offline) kovarsınız!',
                            icon = 'trash',
                            onSelect = function()
                                TriggerServerEvent('can9work:server:admin:fireAllFromJob', jobName)
                            end
                        }
                    }

                    if #players == 0 then
                        table.insert(subOptions, { title = 'Bu mesleğe sahip kimse yok.', disabled = true })
                    end

                    for _, p in ipairs(players) do
                        local status = p.isOnline and ' [ONLINE]' or ' [OFFLINE]'
                        table.insert(subOptions, {
                            title = p.name .. status,
                            description = string.format('ID: %s | Rütbe: %s%s', p.source or 'N/A', p.grade,
                                p.isActive and ' (Aktif)' or ''),
                            icon = p.isOnline and 'user' or 'user-slash',
                            iconColor = p.isOnline and 'green' or 'gray',
                            onSelect = function()
                                TriggerServerEvent('can9work:server:admin:fireFromJob', p.citizenid, jobName)
                            end
                        })
                    end

                    lib.registerContext({
                        id = 'admin_job_players_' .. jobName,
                        title = jobInfo.label .. ' - Oyuncular',
                        menu = 'admin_job_management_main',
                        options = subOptions
                    })
                    lib.showContext('admin_job_players_' .. jobName)
                end, jobName)
            end
        })
    end

    lib.registerContext({
        id = 'admin_job_management_main',
        title = 'Yönetici Meslek Yönetimi',
        options = options
    })

    lib.showContext('admin_job_management_main')
end)
