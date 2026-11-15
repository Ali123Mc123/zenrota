can9work = can9work or {}

local eventZone = lib.zones.sphere({
    coords = Settings.EventBox.Zone.coords,
    radius = Settings.EventBox.Zone.radius,
    debug = Settings.EventBox.Zone.debug,
})

-- Export for ox_inventory to use as an item actionText
exports('eventbox', function(data, slot)
    local cfg = Settings.EventBox
    if not cfg then return end

    -- [ŞU ANLIK KAPALI] Kullanım yeri / alan sorgusu geçici olarak kapatıldı
    -- local playerCoords = GetEntityCoords(cache.ped)
    -- local isInside = eventZone:contains(playerCoords)

    if lib.progressBar({
            duration = cfg.ProgressBar.duration,
            label = cfg.ProgressBar.label,
            useWhileDead = false,
            canCancel = true,
            disable = { car = true, move = true, combat = true },
            anim = { dict = cfg.ProgressBar.anim.dict, clip = cfg.ProgressBar.anim.clip },
            -- prop = { model = cfg.ProgressBar.prop.model, pos = cfg.ProgressBar.prop.pos, rot = cfg.ProgressBar.prop.rot },
        }) then
        TriggerServerEvent('can9work-base:server:useEventBox', slot, true)
    else
        lib.notify({ title = 'İptal Edildi', description = 'İşlem iptal edildi.', type = 'error' })
    end
end)
