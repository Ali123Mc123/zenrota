-- What shops sell, cart checks and prices.

Catalog = {}

local function mod(slot, max) return { kind = 'mod', slot = slot, max = max or 80 } end

Catalog.keys = {
    performance = {
        modEngine = mod(11, 3), modBrakes = mod(12, 2), modTransmission = mod(13, 2),
        modSuspension = mod(15, 3), modArmor = mod(16, 4), modTurbo = { kind = 'toggle', slot = 18 },
    },
    cosmetics = {
        modSpoilers = mod(0), modFrontBumper = mod(1), modRearBumper = mod(2), modSideSkirt = mod(3),
        modExhaust = mod(4), modFrame = mod(5), modGrille = mod(6), modHood = mod(7), modFender = mod(8),
        modRightFender = mod(9), modRoof = mod(10), modHorns = { kind = 'mod', slot = 14, max = 80, flat = true }, modPlateHolder = mod(25),
        modVanityPlate = mod(26), modTrimA = mod(27), modOrnaments = mod(28), modDashboard = mod(29),
        modDial = mod(30), modDoorSpeaker = mod(31), modSeats = mod(32), modSteeringWheel = mod(33),
        modShifterLeavers = mod(34), modAPlate = mod(35), modSpeakers = mod(36), modTrunk = mod(37),
        modHydrolic = mod(38), modEngineBlock = mod(39), modAirFilter = mod(40), modStruts = mod(41),
        modArchCover = mod(42), modAerials = mod(43), modTrimB = mod(44), modTank = mod(45),
        modWindows = mod(46), modLivery = { kind = 'mod', slot = 48, max = 80, group = 'livery' },
        livery = { kind = 'livery', slot = 48, group = 'livery' }, liveryRoof = { kind = 'livery', slot = 48, roof = true },
        plateIndex = { kind = 'range', lo = 0, hi = 5 },
        windowTint = { kind = 'range', lo = -1, hi = 6 },
    },
    respray = {
        color1 = { kind = 'colour', group = 'primary' }, paintType1 = { kind = 'paint', group = 'primary' },
        customPrimaryColor = { kind = 'rgb', group = 'primary' },
        color2 = { kind = 'colour', group = 'secondary' }, paintType2 = { kind = 'paint', group = 'secondary' },
        customSecondaryColor = { kind = 'rgb', group = 'secondary' },
        pearlescentColor = { kind = 'colour', group = 'pearl' },
        wheelColor = { kind = 'colour', group = 'wheel' },
        interiorColor = { kind = 'colour', group = 'interior' },
        dashboardColor = { kind = 'colour', group = 'dashboard' },
    },
    wheels = {
        wheels = { kind = 'range', lo = 0, hi = 12, group = 'wheels', bill = 'wheel' },
        modFrontWheels = { kind = 'mod', slot = 23, max = 250, bill = 'wheel' }, modBackWheels = mod(24, 250),
        modCustomTiresF = { kind = 'toggle', group = 'tyres' }, modCustomTiresR = { kind = 'toggle', group = 'tyres' },
    },
    headlights = {
        modXenon = { kind = 'toggle', slot = 22, group = 'xenon' },
        xenonColor = { kind = 'range', lo = -1, hi = 12, group = 'xenon' },
        customXenonColor = { kind = 'rgb', group = 'xenon' },
    },
    neonLights = {
        neonEnabled = { kind = 'neon', group = 'neon' },
        neonColor = { kind = 'rgb', group = 'neon' },
    },
    tyreSmoke = {
        modSmokeEnabled = { kind = 'toggle', slot = 20, group = 'smoke' },
        tyreSmokeColor = { kind = 'rgb', group = 'smoke' },
    },
    bulletproofTyres = { bulletProofTyres = { kind = 'toggle' } },
    extras = { extras = { kind = 'extras' } },
    stance = { stance = { kind = 'stance' } },
}

Catalog.categoryOf = {}
for category, keys in pairs(Catalog.keys) do
    for key in pairs(keys) do Catalog.categoryOf[key] = category end
end

local function rgb(v)
    if type(v) ~= 'table' then return nil end
    local r, g, b = Core.int(v[1] or v.r, 0, 255), Core.int(v[2] or v.g, 0, 255), Core.int(v[3] or v.b, 0, 255)
    return r and g and b and { r, g, b } or nil
end

local TONES = '0808080f0f0f1c1e21292c2e5a5e66777c87515459323b473333331f222623292e1211100505051212122f323308080812121220222457596123292e323b470f10122121215b5d5e888a996971873b46546900008a0b006b00006110094a0a0a470e0e380c0026030b6300128028006e4f2dbd4800780000360000ab3f00de7e005200008c04044a1000592525754231210804001207001a0b00211e1f261e0038050b41454185030f1f150236131624192a3625455c56000d140010291c2f4f001b573b4e78272d3b95b2db3e627a1c31400055c41a182e1616290e316d395a8309142e0f1021152a52324654152563223ba11f1fa1030e2e0f1e73001c322a3754303c5e3b6796f5890fd9a6004a341ba2a827568f0057514b291b06262117120d073321113d30235e534337382b2219185750362413093b17006e6246998d73cfc0a51f17093d311d665847f0f0f0b3b9c9615f55241e1a1714133b372f3b40451a1e215e646bc8ccd2b0b0b0999999b56519c45c3347783cba84252a77a12430226b5f54c96e34d9d9d9f0f0f03f4228ffffffb01259f697998f2f55c2661069bd4500aeef00010805000808000056575132064200080f0808083206420500086b0b001217103233253b352d7066562b302b4143476690b547391b47391bffd859c8102e5e12247a2bd01f4fd81e9a4a9ad01eb87333a8692ae8d6b0e0b0321e9a4a1e9a4a1e9a4a1e9a4a1e9a4a0f8a8a14b8b014b8b01cc8e01f4fd81f4fd87a2bd07a2bd0d01e8cd01e8c6a0f24d01e8cb87333d01e8cc8102eff8a1fff8a1feef0f4c8102e1f4fd81e9a4a0f8a8a1f4fd87a2bd02a1f4a1e9a4a1f4fd87a2bd0ff6aa8eef0f4ff6aa8f2d21e1e9a4a1f4fd8efe2c0eef0f43a3d421f4fd87a2bd0ff6aa8c8102e1e6a3a121316121316121316121316eef0f4'

function Catalog.tint(props)
    if type(props) ~= 'table' then return nil end
    for _, key in ipairs({ 'customPrimaryColor', 'color1', 'customSecondaryColor', 'color2' }) do
        local c = rgb(props[key])
        if c then return c end
        local i = Core.int(props[key], 0, #TONES // 6 - 1)
        if i then
            local hex = TONES:sub(i * 6 + 1, i * 6 + 6)
            return { tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16) }
        end
    end
end

local LIMITS = { Height = { -0.3, 0.3 }, Camber = { 0.0, 0.5 }, Track = { 0.5, 1.25 } }

local function within(v, range)
    local n = tonumber(v)
    if not n or n ~= n or n == math.huge or n == -math.huge then return nil end
    return math.floor(math.max(range[1], math.min(range[2], n)) * 100 + 0.5) / 100
end

function Catalog.stanceOf(v)
    if type(v) ~= 'table' then return nil end
    local lim = type(Config) == 'table' and type(Config.Stance) == 'table' and Config.Stance or LIMITS
    local C, T = lim.Camber or LIMITS.Camber, lim.Track or LIMITS.Track
    local camber, track = {}, {}
    if type(v.camber) == 'table' and type(v.track) == 'table' then
        for i = 1, 4 do camber[i], track[i] = within(v.camber[i], C), within(v.track[i], T) end
    else
        local cf, cr, tf, tr = within(v.camberFront, C), within(v.camberRear, C), within(v.trackFront, T), within(v.trackRear, T)
        camber, track = { cf, cf, cr, cr }, { tf, tf, tr, tr }
    end
    local height = within(v.height, lim.Height or LIMITS.Height)
    for i = 1, 4 do
        if not camber[i] or not track[i] then return nil end
    end
    return height and { height = height, camber = camber, track = track, each = v.each == true } or nil
end

local CHECK = {
    stance = function(v) if v == false then return false end return Catalog.stanceOf(v) end,
    livery = function(v) return Core.int(v, -1, 100) end,
    mod = function(v, spec) return Core.int(v, -1, spec.max) end,
    toggle = function(v) if type(v) == 'boolean' then return v end end,
    colour = function(v) return Core.int(v, 0, 255) end,
    paint = function(v) return Core.int(v, 0, 9) end,
    range = function(v, spec) return Core.int(v, spec.lo, spec.hi) end,
    rgb = rgb,
    neon = function(v)
        if type(v) ~= 'table' then return nil end
        local out = {}
        for i = 1, 4 do
            if type(v[i]) ~= 'boolean' then return nil end
            out[i] = v[i]
        end
        return out
    end,
    extras = function(v)
        if type(v) ~= 'table' then return nil end
        local out = {}
        for id, on in pairs(v) do
            local n = Core.int(tonumber(id), 0, 20)
            if not n or type(on) ~= 'boolean' then return nil end
            out[tostring(n)] = on
        end
        return out
    end,
}

function Catalog.hidden(key)
    return type(Config) == 'table' and type(Config.HiddenMods) == 'table' and Core.has(Config.HiddenMods, key)
end

function Catalog.check(key, value)
    local category = Catalog.categoryOf[key]
    local spec = category and Catalog.keys[category][key]
    if not spec then return nil end
    return CHECK[spec.kind](value, spec)
end

function Catalog.build(wanted, sells, maxLines)
    if type(wanted) ~= 'table' then return nil, 'bad_cart' end
    local props, count = {}, 0
    for key, value in pairs(wanted) do
        count = count + 1
        if count > (maxLines or 100) then return nil, 'bad_cart' end
        local category = type(key) == 'string' and Catalog.categoryOf[key]
        if not category then return nil, 'bad_cart' end
        if not Core.has(sells, category) or Catalog.hidden(key) then return nil, 'not_sold' end
        local checked = Catalog.check(key, value)
        if checked == nil then return nil, 'bad_cart' end
        props[key] = checked
    end
    if count == 0 then return nil, 'empty_cart' end
    return props
end

function Catalog.base(prices, category, value, byValue)
    local p = prices[category]
    if not p then return nil end
    return byValue and value * (p.percent or 0) or (p.price or 0)
end

function Catalog.levelOf(spec, v)
    return spec.kind == 'mod' and not spec.flat and math.max(tonumber(v) or 0, 0) or 0
end

function Catalog.price(props, prices, value, byValue, minPrice)
    local groups = {}
    for key, v in pairs(props) do
        local category = Catalog.categoryOf[key]
        local spec = Catalog.keys[category][key]
        local id = category .. ':' .. (spec.bill or spec.group or key)
        local g = groups[id]
        if not g then
            g = { key = key, category = category, level = 0 }
            groups[id] = g
        elseif spec.kind == 'mod' then
            g.key = key
        end
        g.level = math.max(g.level, Catalog.levelOf(spec, v))
        g.free = spec.kind == 'stance' and v == false
    end
    local total, lines = 0, {}
    for _, g in pairs(groups) do
        local base = Catalog.base(prices, g.category, value, byValue) or 0
        local cost = g.free and 0 or math.max(minPrice or 0, math.floor(base * (1 + g.level * (prices[g.category].mult or 0)) + 0.5))
        lines[#lines + 1] = { key = g.key, category = g.category, cost = cost }
        total = total + cost
    end
    table.sort(lines, function(a, b) return a.key < b.key end)
    return total, lines
end

function Catalog.byCategory(props)
    local out = {}
    for key, value in pairs(props) do
        local category = Catalog.categoryOf[key]
        out[category] = out[category] or {}
        out[category][key] = value
    end
    return out
end

function Catalog.costOf(lines, categories)
    local sum = 0
    for _, l in ipairs(lines) do
        if categories[l.category] then sum = sum + l.cost end
    end
    return sum
end

function Catalog.repairPrice(prices, value, byValue, damage, minPrice, byDamage)
    local base = Catalog.base(prices, 'repair', value, byValue) or 0
    damage = math.min(math.max(damage, 0), 1)
    local share = byDamage == false and 1 or 0.3 + 0.7 * damage
    return math.max(minPrice or 0, math.floor(base * share + 0.5))
end
