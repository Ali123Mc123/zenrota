-- The owner's side of the door: everything the old menu did, as calls from the door's inside. The server callbacks
-- are the same; a success shows the same notice as before.
local t = DL.locale.t
local call = Lockers.call

local PLATE_ORDER = { 'classic', 'luxury', 'racing', 'gothic', 'anime', 'street', 'cyberpunk', 'tactical', 'leather', 'vaporwave', 'hazard' }

local OUTFIT_MENUS = {
    { resource = 'illenium-appearance', event = 'illenium-appearance:client:openOutfitMenu' },
    { resource = 'fivem-appearance', event = 'fivem-appearance:client:openOutfitMenu' },
    { resource = 'qb-clothing', event = 'qb-clothing:client:openOutfitMenu' },
}

local function uid() return Lockers.current and Lockers.current.uid end

-- A call from the door: its data, and the answer straight back to the page.
local function bridge(name, fn)
    RegisterNUICallback('lockers:' .. name, function(data, cb)
        cb(fn(type(data) == 'table' and data or {}) or { ok = false, error = 'unavailable' })
    end)
end

-- A success sounds and shows its notice; a failure goes back to the page, which says why in its own way.
local function done(result, key, ...)
    if result.ok then
        PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
        if key then Nui.notify(key, 'success', ...) end
    end
    return result
end

local function outfitMenu()
    if not Config.Wardrobe.OutfitMenu then return nil end
    for _, menu in ipairs(OUTFIT_MENUS) do
        if GetResourceState(menu.resource) == 'started' then return menu end
    end
end

local function plates(info)
    local unlocked = {}
    for _, id in ipairs(info.unlocked or {}) do unlocked[id] = true end
    local out = {}
    for _, id in ipairs(PLATE_ORDER) do
        local plate = Config.Plates[id]
        if plate then
            out[#out + 1] = { id = id, label = t(('plates.%s.label'):format(id)), price = plate.price, owned = unlocked[id] or plate.price == 0, current = info.plate == id }
        end
    end
    return out
end

local function uniforms()
    if not Config.Wardrobe.Enabled then return {} end
    local out = {}
    for i, uniform in ipairs(Config.Wardrobe.Uniforms) do out[#out + 1] = { index = i, label = uniform.label } end
    return out
end

-- Everything the door's inside shows, read in one go.
bridge('owner', function()
    local u = uid()
    if not u then return nil end
    local info = call('info', { uid = u })
    if not info.ok then return info end
    local keys = call('keys', { uid = u })
    local price = call('price', { uid = u })
    local up = Config.Upgrades
    return {
        ok = true, info = info, plates = plates(info), keys = keys.ok and keys.keys or {},
        extend = price.ok and { price = price.price, base = price.base, discount = price.discount, days = price.days } or nil,
        upgrades = { alarm = up.AlarmPrice, shelf = up.ShelfPrice, bonusSlots = up.BonusSlots },
        uniforms = uniforms(), outfits = outfitMenu() ~= nil, notes = Config.Notes.Enabled,
    }
end)

bridge('extend', function()
    local result = call('extend', { uid = uid() })
    return done(result, 'lockers.extended', result.expiresAt and os.date('%d.%m.%Y %H:%M', result.expiresAt))
end)

bridge('release', function()
    local result = done(call('release', { uid = uid() }), 'lockers.released')
    if result.ok then Nui.close() end
    return result
end)

bridge('title', function(data) return done(call('title', { uid = uid(), title = data.title }), 'lockers.title_set') end)
bridge('plate', function(data) return done(call('plate', { uid = uid(), plate = data.plate }), 'lockers.plate_changed') end)
bridge('upgrade', function(data) return done(call('upgrade', { uid = uid(), upgrade = data.upgrade }), 'lockers.upgraded') end)
bridge('takeKey', function(data) return done(call('takeKey', { uid = uid(), citizenid = data.citizenid }), 'lockers.key_taken') end)
bridge('giveKey', function(data) return done(call('giveKey', { uid = uid(), target = data.target }), 'lockers.key_given') end)

-- The players close by, named by the server.
bridge('nearby', function()
    local ids = {}
    for _, player in ipairs(lib.getNearbyPlayers(GetEntityCoords(cache.ped), 3.0)) do ids[#ids + 1] = GetPlayerServerId(player.id) end
    return call('nearbyNames', { uid = uid(), ids = ids })
end)

-- Putting a uniform on at the open locker.
bridge('wear', function(data)
    local uniform = Config.Wardrobe.Enabled and Config.Wardrobe.Uniforms[tonumber(data.index) or 0]
    if not uniform then return { ok = false, error = 'validation' } end
    if uniform.model and GetEntityModel(cache.ped) ~= joaat(uniform.model) then Nui.notify('lockers.uniform_model', 'warning') end
    for _, c in ipairs(uniform.components or {}) do SetPedComponentVariation(cache.ped, c.component_id, c.drawable, c.texture, 0) end
    for _, p in ipairs(uniform.props or {}) do
        if p.drawable == -1 then ClearPedProp(cache.ped, p.prop_id) else SetPedPropIndex(cache.ped, p.prop_id, p.drawable, p.texture, true) end
    end
    if pcall(lib.requestAnimDict, 'clothingtie', 2000) then TaskPlayAnim(cache.ped, 'clothingtie', 'try_tie_positive_a', 3.0, 3.0, 1500, 49, 0, false, false, false) end
    Nui.notify('lockers.uniform_worn', 'success', uniform.label)
    return { ok = true }
end)

-- The appearance resource's own outfit menu: the door closes first.
bridge('outfits', function()
    local menu = outfitMenu()
    if not menu then return { ok = false, error = 'unavailable' } end
    Nui.close()
    SetTimeout(300, function() TriggerEvent(menu.event) end)
    return { ok = true }
end)

-- A new PIN: the door closes and opens again on the dial.
bridge('changePin', function()
    local spot = Lockers.spots[uid()]
    if not spot then return nil end
    Nui.close()
    SetTimeout(300, function() Lockers.keypad('change', spot) end)
    return { ok = true }
end)
