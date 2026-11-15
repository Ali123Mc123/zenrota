-- =============================================================================
-- ADMIN PANEL & FARM CREATOR SETTINGS
-- =============================================================================
Config.AdminPanel = {
    enabled = true,
    command = 'farmadmin',               -- Ana komut: /farmadmin
    acePermission = 'krypton.admin',     -- nil ise framework admin kontrolü kullanılır

    -- ═══════════════════════════════════════════════════════════════════════
    -- NOCLIP AYARLARI
    -- ═══════════════════════════════════════════════════════════════════════
    noclip = {
        autoEnable = true,               -- Placement moduna girince otomatik noclip
        defaultSpeed = 1.0,              -- Baz hız (m/frame)
        fastMultiplier = 3.0,            -- SHIFT ile hız çarpanı
    },

    -- ═══════════════════════════════════════════════════════════════════════
    -- FARM CREATOR AYARLARI
    -- ═══════════════════════════════════════════════════════════════════════
    creator = {
        -- Zone (Polyzone)
        minZonePoints = 3,               -- Minimum köşe noktası
        maxZonePoints = 50,              -- Maximum köşe noktası
        zoneLineColor = { r = 0, g = 200, b = 255, a = 200 },
        zonePointColor = { r = 0, g = 255, b = 100, a = 220 },
        zonePointSize = 0.4,

        -- Spot
        maxSpotsPerFarm = 50,
        minSpotSpacing = 1.5,            -- Spotlar arası minimum mesafe (metre)
        spotMarkerColor = { r = 0, g = 150, b = 255, a = 180 },
        spotGhostColor = { r = 255, g = 255, b = 255, a = 100 },
        spotMarkerSize = 0.5,
        snapToGround = true,

        -- Top-down camera height (false/nil max = no hard ceiling)
        minCameraHeight = 1.0,
        maxCameraHeight = false,
        cameraHeightStep = 0.8,

        -- Event Zone
        eventZoneColor = { r = 255, g = 100, b = 0, a = 60 },
        eventZoneOutline = { r = 255, g = 150, b = 0, a = 200 },
        defaultEventRadius = 8.0,
        minEventRadius = 2.0,
        maxEventRadius = 50.0,
        defaultEventChance = 30,         -- %30 varsayılan şans

        -- Crosshair
        crosshairSize = 0.008,
    },

    -- ═══════════════════════════════════════════════════════════════════════
    -- EVENT TİPLERİ
    -- ═══════════════════════════════════════════════════════════════════════
    events = {
        enabled = false,
    },

    eventTypes = {
        { id = 'thief',   label = 'Hırsız Baskını',       icon = 'fa-mask',        color = { r = 255, g = 50,  b = 50  } },
        { id = 'storm',   label = 'Fırtına',            icon = 'fa-cloud-bolt',  color = { r = 100, g = 100, b = 200 } },
        { id = 'pest',    label = 'Haşere İstilası',    icon = 'fa-bug',         color = { r = 50,  g = 200, b = 50  } },
        { id = 'bonus',   label = 'Bonus Hasat',    icon = 'fa-star',        color = { r = 255, g = 215, b = 0   } },
        { id = 'trader',  label = 'Gezgin Tüccar',  icon = 'fa-truck',       color = { r = 100, g = 200, b = 255 } },
        { id = 'drought', label = 'Kuraklık',          icon = 'fa-sun',         color = { r = 255, g = 165, b = 0   } },
    },

    -- ═══════════════════════════════════════════════════════════════════════
    -- VARSAYILAN DEĞERLER
    -- ═══════════════════════════════════════════════════════════════════════
    defaults = {
        difficulty = 'medium',
        hourReq = 0,
        multiplier = 1.0,
        minYield = 1,
        maxYield = 3,
        cooldown = 300,
        useCycleSystem = true,
        rewardMoney = 150,
        rewardXP = 75,
    },
}
