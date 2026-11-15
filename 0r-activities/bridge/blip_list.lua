-- DaddyRP: aktivitelerin harita isaretlerini 0r-activities cizmez (config'lerde blip.enabled = false);
-- F3 > Blip Ac/Kapat > Aktiviteler isaretleri qb-radialmenu'de bu listeden cizer.
-- Yerler ve gorunumler config'lerden okunur: bir aktivitenin yeri degisirse F3 de kendiliginden guncel kalir.

local function point(c)
    return c and vector3(c.x, c.y, c.z) or nil
end

-- Kapali aktivite (enabled = false) listede yer almaz.
local function on(cfg)
    return type(cfg) == 'table' and cfg.enabled ~= false
end

exports('GetActivityBlips', function()
    local list = {}
    local function add(coords, blip, label)
        coords = point(coords)
        if not coords or type(blip) ~= 'table' then return end
        list[#list + 1] = {
            coords = coords,
            sprite = blip.sprite,
            colour = blip.colour,
            scale = blip.scale,
            label = blip.name or blip.label or label,
        }
    end

    if on(BalloonConfig) then add(BalloonConfig.npc and BalloonConfig.npc.coords, BalloonConfig.blip, 'Sıcak Hava Balonu') end
    if on(BungeeConfig) then
        for _, location in ipairs(BungeeConfig.locations or {}) do add(location.npc, BungeeConfig.npc and BungeeConfig.npc.blip, 'Bungee') end
    end
    if on(CableCarConfig) then
        for _, track in ipairs(CableCarConfig.tracks or {}) do add(track.points and track.points[1], CableCarConfig.blip, 'Teleferik') end
    end
    if on(DivingConfig) then
        for _, location in ipairs(DivingConfig.locations or {}) do add(location.npc, DivingConfig.blip, 'Ganimet Avı') end
    end
    if on(FerrisConfig) then add(FerrisConfig.entry, FerrisConfig.blip, 'Dönme Dolap') end
    if on(GokartConfig) then add(GokartConfig.entry, GokartConfig.blip, 'Go-Kart') end
    if on(HammerConfig) then add(HammerConfig.npc and HammerConfig.npc.coords, HammerConfig.blip, 'Serbest Düşüş Kulesi') end
    if on(HydroflyConfig) then add(HydroflyConfig.npc and HydroflyConfig.npc.coords, HydroflyConfig.blip, 'Hydrofly') end
    if on(ActivityItemShopConfig) then add(ActivityItemShopConfig.npc and ActivityItemShopConfig.npc.coords, ActivityItemShopConfig.npc and ActivityItemShopConfig.npc.blip, 'Aktivite Eşyaları') end
    if type(RacesConfig) == 'table' and (on(RacesConfig.formula1) or on(RacesConfig.skart_race)) then add(RacesConfig.entry, RacesConfig.blip, 'Formula 1 ve Skart Yarışı') end
    if on(CoasterConfig) then add(CoasterConfig.entry, CoasterConfig.blip, 'Hız Treni') end
    if on(SharkCageConfig) then add(SharkCageConfig.npc and SharkCageConfig.npc.entry, SharkCageConfig.npc and SharkCageConfig.npc.blip, 'Köpekbalığı Kafesi') end
    if on(SkyDiveConfig) then
        for _, entry in ipairs(SkyDiveConfig.entryPoints or {}) do add(entry, SkyDiveConfig.blip, 'Paraşüt Atlayışı') end
    end
    if on(WaterActivitiesConfig) then add(WaterActivitiesConfig.npc, WaterActivitiesConfig.blip, 'Tekne Aktiviteleri') end
    if on(WaterSlideConfig) then add(WaterSlideConfig.coords, WaterSlideConfig.blip, 'Su Kaydırağı') end
    if on(ZiplineConfig) then
        for _, line in ipairs(ZiplineConfig.locations or {}) do add(line.start, ZiplineConfig.blip, line.name or 'Zipline') end
    end
    return list
end)
