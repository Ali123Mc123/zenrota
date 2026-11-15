RegisterNetEvent('can9work_funds:client:openMenu', function(data)
    if not data then return end
    OpenMainMenu(data)
end)

function OpenMainMenu(data)
    lib.registerContext({
        id = 'fund_admin_main',
        title = 'Finans Yönetim Paneli',
        options = {
            {
                title = 'Genel Ekonomi Özeti',
                description = string.format("Toplam Para: $%s\nİşletme Sayısı: %d | Meslek Sayısı: %d",
                    (data.stats.grandTotal or 0), data.stats.bizCount, data.stats.jobCount),
                icon = 'chart-line',
                readOnly = true,
                metadata = {
                    { label = 'Meslek Toplam',  value = '$' .. (data.stats.jobTotal or 0) },
                    { label = 'İşletme Toplam', value = '$' .. (data.stats.bizTotal or 0) }
                }
            },
            {
                title = 'Meslek Kasaları ve Maaşlar',
                description = 'Resmi kurumların bakiye ve maaş listesi',
                icon = 'building-columns',
                arrow = true,
                onSelect = function() OpenJobMenu(data) end
            },
            {
                title = 'İşletme Kasaları',
                description = 'Özel işletmelerin bakiye listesi',
                icon = 'shop',
                arrow = true,
                onSelect = function() OpenBusinessMenu(data) end
            }
        }
    })
    lib.showContext('fund_admin_main')
end

function OpenJobMenu(data)
    local jobOptions = {}
    for _, job in ipairs(data.jobs) do
        local jobConfig = data.config[job.job_name]
        local salaryText = ""

        if jobConfig and jobConfig.grades then
            local minSalary, maxSalary = 999999, 0
            for _, grade in pairs(jobConfig.grades) do
                local pay = tonumber(grade.payment) or 0
                if pay < minSalary then minSalary = pay end
                if pay > maxSalary then maxSalary = pay end
            end
            salaryText = string.format("\nMaaş Skalası: $%s - $%s", minSalary, maxSalary)
        end

        table.insert(jobOptions, {
            title = job.label or job.job_name,
            description = string.format("Bakiye: $%s%s", job.balance, salaryText),
            icon = 'briefcase',
            arrow = true,
            metadata = {
                { label = 'Meslek ID',      value = job.job_name },
                { label = 'Son Güncelleme', value = job.updated_at }
            },
            onSelect = function()
                local input = lib.inputDialog('Kasa Düzenle: ' .. (job.label or job.job_name), {
                    { type = 'number', label = 'Yeni Bakiye miktarını girin', description = 'Mevcut: $' .. job.balance, default = job.balance, icon = 'dollar-sign' }
                })
                if input and input[1] then
                    lib.callback('can9work_funds:server:updateBalance', false, function(success)
                        if success then
                            lib.notify({ title = 'Başarılı', description = 'Kasa güncellendi.', type = 'success' })
                            ExecuteCommand('fundadmin')
                        end
                    end, { type = 'job', id = job.job_name, amount = input[1] })
                else
                    OpenJobMenu(data)
                end
            end
        })
    end

    lib.registerContext({
        id = 'fund_admin_jobs',
        title = 'Meslek Fonları',
        menu = 'fund_admin_main',
        options = jobOptions
    })
    lib.showContext('fund_admin_jobs')
end

function OpenBusinessMenu(data)
    local bizOptions = {}
    local now = data.serverTime or 0
    for _, biz in ipairs(data.businesses) do
        local taxStatus = "BELİRTİLMEDİ"
        if biz.next_tax_payment and biz.next_tax_payment > 0 then
            local diff = biz.next_tax_payment - now
            if diff <= 0 then
                taxStatus = "SÜRESİ DOLMUŞ!"
            else
                local days = math.floor(diff / 86400)
                local hours = math.floor((diff % 86400) / 3600)
                taxStatus = string.format("%d Gün %d Saat", days, hours)
            end
        end

        table.insert(bizOptions, {
            title = biz.label or biz.business_id,
            description = string.format("Bakiye: $%s\nVergi Süresi: %s", biz.balance, taxStatus),
            icon = 'cash-register',
            arrow = true,
            metadata = {
                { label = 'İşletme ID', value = biz.business_id },
                { label = 'Sahibi',     value = biz.owner_identifier or "Bilinmiyor" }
            },
            onSelect = function()
                local input = lib.inputDialog('Kasa Düzenle: ' .. (biz.label or biz.business_id), {
                    { type = 'number', label = 'Yeni Bakiye miktarını girin', description = 'Mevcut: $' .. biz.balance, default = biz.balance, icon = 'dollar-sign' }
                })
                if input and input[1] then
                    lib.callback('can9work_funds:server:updateBalance', false, function(success)
                        if success then
                            lib.notify({
                                title = 'Başarılı',
                                description = 'İşletme kasası güncellendi.',
                                type =
                                'success'
                            })
                            ExecuteCommand('fundadmin')
                        end
                    end, { type = 'business', id = biz.business_id, amount = input[1] })
                else
                    OpenBusinessMenu(data)
                end
            end
        })
    end

    lib.registerContext({
        id = 'fund_admin_biz',
        title = 'İşletme Fonları',
        menu = 'fund_admin_main',
        options = bizOptions
    })
    lib.showContext('fund_admin_biz')
end
