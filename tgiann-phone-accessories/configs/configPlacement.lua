-- Where each kind of accessory can sit on the phone. Meters from the phone center:
-- x = right side (seen from the screen), y = toward the back of the phone, z = up
-- The case is 0.0878 x 0.181 m (edges at x = +-0.0439, z = +-0.0905). config.debug draws every area in the editor
-- surface = slides on the back (min/max = edges of the back, every piece stays inside by its own size)
-- edge = hangs from the left or right side with its ring half inside the case, the charm swings outward by tilt
-- rim = holds the top, left or right edge (the closest one to the cursor) and turns to face it
-- cover = covers the whole back at the phone center, never moved (the skin model already sits on the back, stickers and letters sit on top of it)
---@type table<PhoneAccKind, PhoneAccMount>
config.accMounts = {
    sticker = { mount = "surface", y = 0.0023, minX = -0.0425, maxX = 0.0425, minZ = -0.0885, maxZ = 0.0885, rotate = true },
    decor = { mount = "surface", y = 0.002, minX = -0.0425, maxX = 0.0425, minZ = -0.0885, maxZ = 0.0885, rotate = true },
    letters = { mount = "surface", y = 0.0023, minX = -0.0425, maxX = 0.0425, minZ = -0.0885, maxZ = 0.0885, rotate = true },
    skin = { mount = "cover", y = 0.0 },
    charm = { mount = "edge", y = 0.0, x = 0.0439, minZ = -0.078, maxZ = 0.079, tilt = 16.0 }, -- x = ring center on the side (half of it inside the case), tilt in degrees (negative if it swings inward)
    hugger = {
        mount = "rim",
        y = 0.0019,
        top = 0.0905, -- Top edge of the case
        side = 0.0439, -- Left/right edge of the case
        minX = -0.03,
        maxX = 0.03, -- Slide range on the top edge
        minZ = -0.072,
        maxZ = 0.072, -- Slide range on the side edges
        angles = { top = 0.0, right = 90.0, left = -90.0 }, -- Turn of the hugger on each edge (degrees, swap the signs if it faces inward)
    },
}

-- Raised parts of the back: surface pieces whose center is inside a box sit higher by lift (meters).
-- Pieces sinking in = raise lift, floating = lower it (config.debug shows the y of the selected piece)
---@type PhoneAccRaised[]
config.accRaised = {
    { minX = -0.004, maxX = 0.0395, minZ = 0.042, maxZ = 0.087, lift = 0.0048 }, -- Camera island
}

-- Editor scene
---@type PhoneAccEditorConfig
config.accEditor = {
    previewOffset = vec3(0.0, 0.0, 2.0), -- Without a preview point the phone floats here from the player (right, forward, up meters), the player is hidden; lowered under a ceiling
    distance = 0.36, -- Meters between the camera and the phone
    fov = 40.0, -- Camera field of view
    zoom = { min = 0.2, max = 0.6 }, -- Mouse wheel camera distance limits
    blurBackground = true, -- Depth of field when the studio background is off: only the phone stays sharp
    backdropDistance = 0.45, -- Meters between the phone and the studio background behind it
    light = {
        -- Soft light on the phone so it reads well at night
        active = true,
        range = 1.2,
        intensity = 3.0,
        color = { 255, 244, 230 },
    },
    rotateStep = 15.0, -- Degrees per mouse wheel step / Q-E press when turning a sticker
    orbit = {
        -- Dragging empty space turns the phone
        speed = 220.0, -- Degrees turned by a drag across the whole screen height
        invertX = false, -- true = left/right turns the other way
        invertY = false, -- true = up/down tilts the other way
    },
}

-- Charms swinging on phones in hands: they hang along gravity and react to the hand moving
---@type PhoneAccSwayConfig
config.accSway = {
    active = true, -- false = charms stay still
    strength = 1.0, -- How much hand movement throws them around (0 = only gravity)
    maxAngle = 28.0, -- Most degrees a charm swings from its resting pose
    stiffness = 45.0, -- Higher = snaps back faster
    damping = 6.0, -- Higher = stops swinging sooner
    distance = 15.0, -- Meters: farther phones keep their charms still (saves frame time)
}

-- Where exports["tgiann-phone-accessories"]:SpawnHandPhone() puts the player's decorated phone (emote / animation menus).
-- 28422 = right hand prop bone. The export takes its own bone/offset/rotation too
---@type PhoneAccHandSpawn
config.accHandSpawn = {
    bone = 28422,
    offset = vec3(0.0, 0.0, 0.0),
    rotation = vec3(0.0, 0.0, 0.0),
}

-- Phone models phone scripts put in the hand. Accessories attach to these.
-- Cases are made for tgiann_phone. Any other model listed here is hidden and tgiann_phone is drawn in its place,
-- offset/rotation line it up with that model in the hand
---@type PhoneAccHandProp[]
config.accHandProps = {
    { model = "tgiann_phone" },
    { model = "prop_npc_phone", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "prop_npc_phone_02", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "prop_amb_phone", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },

    -- Cylex Phone
    { model = "cylex_phoneprop", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },

    -- high-phone holds hsphone turned 90 degrees on X (its config/models.lua)
    { model = "hsphone", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(-90.0, 0.0, 0.0) },

    -- codem-phone (one model per phone color)
    { model = "codem_phone_1", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "codem_phone_2", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "codem_phone_3", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "codem_phone_4", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "codem_phone_5", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "codem_phone_6", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "codem_phone_7", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "codem_phone_8", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },

    -- sd-phone: sd_phone_<color>, and with Foldable on sd_phone_fold_<color> (shut) / sd_phone_fold_<color>_open
    { model = "sd_phone_black", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_blue", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_green", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_orange", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_pink", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_purple", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_red", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_yellow", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_fold_black", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_fold_blue", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_fold_green", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_fold_orange", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_fold_pink", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_fold_purple", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_fold_red", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_fold_yellow", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_fold_black_open", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_fold_blue_open", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_fold_green_open", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_fold_orange_open", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_fold_pink_open", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_fold_purple_open", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_fold_red_open", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sd_phone_fold_yellow_open", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },

    -- sky_phone: sky_phone_prop is the black frame, sky_phone_prop_<color> the others
    { model = "sky_phone_prop", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sky_phone_prop_blue", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sky_phone_prop_burgundy", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sky_phone_prop_cyan", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sky_phone_prop_gold", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sky_phone_prop_green", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sky_phone_prop_lavender", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sky_phone_prop_lime", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sky_phone_prop_orange", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sky_phone_prop_pink", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sky_phone_prop_purple", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sky_phone_prop_red", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sky_phone_prop_rgb", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sky_phone_prop_teal", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sky_phone_prop_white", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
    { model = "sky_phone_prop_yellow", offset = vec3(0.0, 0.0, 0.0), rotation = vec3(0.0, 0.0, 0.0) },
}
