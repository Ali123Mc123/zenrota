can9work = can9work or {}

exports('cryptowallet', function(data, slot)
    if lib.progressBar({
            duration = 4000,
            label = 'Kripto Cüzdanı Açılıyor...',
            useWhileDead = false,
            canCancel = true,
            disable = {
                car = true,
                move = true,
                combat = true,
            },
            anim = {
                dict = 'missheistdockssetup1clipboard@base',
                clip = 'base'
            },
            prop = {
                model = `prop_cs_tablet`,
                pos = vec3(0.03, 0.03, 0.02),
                rot = vec3(0.0, 0.0, -1.5)
            },
        }) then
        TriggerServerEvent('can9work-base:server:openCryptowallet', slot)
    else
        lib.notify({
            title = 'İptal Edildi',
            description = 'Cüzdan açma işlemi iptal edildi.',
            type = 'error'
        })
    end
end)
