-- Blip icons: GTA's blip art lives in the minimap texture dictionary (four blips_texturesheet* sheets); the page reads it
-- through https://nui-img/minimap/<sheet> and cuts cells with web/apps/pausemenu/src/map/blipAtlas.json. No Rockstar
-- image ships with this resource. The game keeps the dictionary for its radar; it is asked for only when it is not
-- resident, and never released. Research: maplegend/icons.md, plan.md section 3.
local Cfg = Config.Map or {}
local TXD = 'minimap'
local LOAD_MS = 3000

-- { ok = true, loaded } or { ok = false, error = 'disabled' } (Config.Map.GameIcons = false: category letters).
PM.Callback('pm:map:icons', function()
    if Cfg.GameIcons == false then return { ok = false, error = 'disabled' } end
    if not HasStreamedTextureDictLoaded(TXD) then
        RequestStreamedTextureDict(TXD, false)
        local stop = GetGameTimer() + LOAD_MS
        while not HasStreamedTextureDictLoaded(TXD) and GetGameTimer() < stop do Wait(0) end
    end
    -- loaded false is not a refusal: the page still asks nui-img, whose 404 is the real answer (diagnostic I1/I2).
    return { ok = true, loaded = HasStreamedTextureDictLoaded(TXD) }
end)
