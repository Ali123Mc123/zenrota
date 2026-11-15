-- What the caller's client adds to an alert: street and area names, gender and mask, the weapon's kind, the car (model,
-- colour, part of the plate).
Context = {}

local WEAPON_GROUPS = {
    [joaat('GROUP_PISTOL')] = 'pistol', [joaat('GROUP_SMG')] = 'smg', [joaat('GROUP_RIFLE')] = 'rifle',
    [joaat('GROUP_SHOTGUN')] = 'shotgun', [joaat('GROUP_SNIPER')] = 'sniper', [joaat('GROUP_MG')] = 'mg',
    [joaat('GROUP_HEAVY')] = 'heavy', [joaat('GROUP_THROWN')] = 'thrown', [joaat('GROUP_MELEE')] = 'melee',
}

-- The street and the area at a point ('Vespucci Blvd', 'Pillbox Hill').
function Context.street(p)
    local hash = GetStreetNameAtCoord(p.x, p.y, p.z)
    local street = GetStreetNameFromHashKey(hash)
    local zone = GetNameOfZone(p.x, p.y, p.z)
    local area = zone and GetLabelText(zone) or ''
    if area == 'NULL' then area = '' end
    return street ~= '' and street or nil, area ~= '' and area or nil
end

-- A colour name from red, green, blue (black, grey, white, then by hue).
local function colourName(r, g, b)
    local max, min = math.max(r, g, b), math.min(r, g, b)
    if max < 45 then return 'black' end
    local sat = max == 0 and 0 or (max - min) / max
    if sat < 0.18 then return max > 200 and 'white' or 'grey' end
    local h
    if max == r then h = (g - b) / (max - min) % 6 elseif max == g then h = (b - r) / (max - min) + 2 else h = (r - g) / (max - min) + 4 end
    h = h * 60
    if h >= 15 and h < 45 and max < 150 then return 'brown' end
    if h < 15 or h >= 340 then return 'red' end
    if h < 42 then return 'orange' end
    if h < 70 then return 'yellow' end
    if h < 170 then return 'green' end
    if h < 255 then return 'blue' end
    if h < 295 then return 'purple' end
    return 'pink'
end

-- GTA's vehicle classes (GetVehicleClass) by number, as locale keys.
local CLASSES = {
    [0] = 'compact', 'sedan', 'suv', 'coupe', 'muscle', 'sports_classic', 'sports', 'super', 'motorcycle', 'offroad',
    'industrial', 'utility', 'van', 'cycle', 'boat', 'helicopter', 'plane', 'service', 'emergency', 'military',
    'commercial', 'train', 'open_wheel',
}
local DIRS = { 'n', 'nw', 'w', 'sw', 's', 'se', 'e', 'ne' }

-- 'going north-east' from a heading (GTA: 0 north, turning left as it grows).
function Context.heading(h)
    return Core.t('context.dirs.' .. DIRS[math.floor(((h % 360) + 22.5) / 45) % 8 + 1])
end

-- 'Sultan · Blue · plate 12A•••••'
function Context.vehicle(veh)
    local model = GetEntityModel(veh)
    local name = GetLabelText(GetDisplayNameFromVehicleModel(model))
    if name == 'NULL' then name = GetDisplayNameFromVehicleModel(model) end
    local parts = { name }
    if Config.Context.Colour then
        local ok, r, g, b = pcall(GetVehicleColor, veh)
        if ok and r then parts[#parts + 1] = Core.t('context.colours.' .. colourName(r, g, b)) end
    end
    if Config.Context.Class then
        local class = CLASSES[GetVehicleClass(veh)]
        if class then parts[#parts + 1] = Core.t('context.classes.' .. class) end
        if class ~= 'motorcycle' and class ~= 'cycle' and class ~= 'boat' and class ~= 'helicopter' and class ~= 'plane' then
            parts[#parts + 1] = Core.t('context.doors', GetIsDoorValid(veh, 2) and 4 or 2)
        end
    end
    local plate = (GetVehicleNumberPlateText(veh) or ''):gsub('%s+', '')
    if plate ~= '' and Config.Context.Plate > 0 then
        local shown = math.random(100) <= Config.Context.PlateFullChance and #plate or math.min(Config.Context.Plate, #plate)
        parts[#parts + 1] = Core.t('context.plate', plate:sub(1, shown) .. ('•'):rep(#plate - shown))
    end
    return table.concat(parts, ' · ')
end

-- The weapon in hand: the framework's name for it, or its kind.
function Context.weapon(ped)
    local hash = GetSelectedPedWeapon(ped)
    if hash == joaat('WEAPON_UNARMED') then return nil end
    local label = Bridge.fw.weaponLabel and Bridge.fw.weaponLabel(hash)
    if label then return label end
    return Core.t('context.weapons.' .. (WEAPON_GROUPS[GetWeapontypeGroup(hash)] or 'unknown'))
end

-- The rows an alert type asks for (gender, weapon, vehicle), as { icon, text }.
function Context.fields(wants)
    local ped = PlayerPedId()
    local out = {}
    for _, want in ipairs(wants or {}) do
        if want == 'gender' and Config.Context.Gender then
            local text = Core.t(IsPedMale(ped) and 'context.male' or 'context.female')
            if Config.Context.Mask and GetPedDrawableVariation(ped, 1) > 0 then text = text .. ', ' .. Core.t('context.masked') end
            out[#out + 1] = { icon = 'user', text = text }
        elseif want == 'weapon' and Config.Context.Weapon then
            local weapon = Context.weapon(ped)
            if weapon then out[#out + 1] = { icon = 'gun', text = weapon } end
        elseif want == 'vehicle' then
            local veh = GetVehiclePedIsIn(ped, false)
            if veh == 0 then veh = GetVehiclePedIsTryingToEnter(ped) end
            if veh ~= 0 then
                out[#out + 1] = { icon = 'car', text = Context.vehicle(veh) }
                if Config.Context.Heading and GetEntitySpeed(veh) > 3.0 then out[#out + 1] = { icon = 'route', text = Context.heading(GetEntityHeading(veh)) } end
            end
        end
    end
    return out
end

-- An alert of a type from this player, where they stand (or at coords), with the type's rows (or extra.context's) and
-- extra ones.
function Context.raise(typeName, extra)
    extra = extra or {}
    local def = Config.Alerts[typeName] or Config.Alerts.custom
    local p = Core.vec3(extra.coords) or GetEntityCoords(PlayerPedId())
    local street, area = Context.street(p)
    local fields = Context.fields(extra.context or def.context)
    for _, f in ipairs(extra.fields or {}) do fields[#fields + 1] = f end
    TriggerServerEvent('daddy_dispatch:alert', {
        type = typeName, title = extra.title, code = extra.code, priority = extra.priority, icon = extra.icon,
        coords = Core.plain(p), to = extra.to, fields = fields, message = extra.message, blip = extra.blip,
        street = street and (area and street .. ', ' .. area or street) or area, fuzz = extra.fuzz, auto = extra.auto == true,
    })
end
