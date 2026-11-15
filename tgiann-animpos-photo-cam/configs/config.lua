tgiCoreExports = exports["tgiann-core"]
config = tgiCoreExports:getConfig()
-- Config file: configs/config.lua (shared). Photos are stored by tgiann-media-lib (configs/configStorageServer.lua there)

-- Animation position: move the character while an emote plays
---@type AnimPosConfig
config.animPos = {
    active = true,
    command = {
        active = true,
        name   = "poz", -- "animpos" is also cylex_animmenuv2's client command, which won and opened cylex's clone-ped animpos instead
    },
    key = {
        active = true,
        name   = "F5",
    },
    maxDistance = { xy = 2.0, z = 1.5 }, -- xy: for right, left, forward, backward, z for height
    cameraMaxDistance = 20.0,            -- Max distance of the camera from the player when animpos is active
    abuseControl = true,                 -- If true, the player can teleport to the previous position when animation canceled or re open animpos
    playerOpacity = {
        active = true,                   -- If true, the player will be transparent when animpos ui is active
        opacity = 200,                   -- Player opacity value (0-254)
    },
    headText = {
        active = true,   -- when true, when the player opens the ui, other players will see ANIM_POS_CAM_HEAD_TEXT on the player's head
        cd = 10000,      -- how many milliseconds after the text is shown, show it again
        showTime = 3000, -- display time of the text on the screen
        dist = 10,       -- the distance at which players can see the text
    },
    destroyAnimPosKeys = { -- control ids that end the placed position (jump, move keys)
        22, 30, 31, 32, 33, 34, 35
    }
}

-- Photo camera: filters, depth blur, lights and screenshots
---@type PhotoCamConfig
config.photoCam = {
    active = false, -- daddy_photocam took over F6
    command = {
        active = true,
        name   = "photocam",
    },
    key = {
        active = true,
        name   = "F6",
    },
    item = {
        active = false,     -- If true, the player can use the item to open the menu
        name = "photo_cam", -- Item name
    },
    polaroidImageItem = {
        active = true,              -- If set to true, the captured image will be added to the inventory and become a usable item.
        name = "polaroid",          -- Item name
        needItem = {
            active = true,          -- If set to true, the player needs to have the item in their inventory to use the camera.
            name = "polaroid_empty" -- Item name
        }
    },
    camSetting = {
        distance = 3,
        zoom = 50.0,
        minZoom = 10.0,
        maxZoom = 90.0,
        height = 0.1,
        lookButton = "both", -- The mouse button used to rotate the camera: "left", "right" or "both"
        move = {
            active = true, -- If true, the player can move the camera with the w-a-s-d
            maxDistance = 5.0
        },
    },
    canOpen = {
        damage = {
            active = false, -- kapalı: yerine aşağıdaki damageTimer (client/editable.lua) kalan saniyeyi gösteriyor
            time = 300000   -- milisecond (300000 = 5 minutes)
        },
        handWeapon = true  -- If true, the player can't open the menu when holding a weapon
    },
    damageTimer = {   -- hasar alınca/verince foto kamera beklemesi; mesajda kalan saniye yazar (client/editable.lua)
        active = true,
        seconds = 30,  -- en fazla 30 sn
    },
    headText = {
        active = true,   -- when true, when the player opens the ui, other players will see PHOTO_CAM_HEAD_TEXT on the player's head
        cd = 10000,      -- how many milliseconds after the text is shown, show it again
        showTime = 3000, -- display time of the text on the screen
        dist = 10,       -- the distance at which players can see the text
    },
    filterList = {
        {
            label = 'Filtre Yok',
            source = false,
        },
        {
            label = 'Siyah beyaz',
            source = 'spectator4',
        },
        {
            label = 'Güvenlik Kamerası',
            source = 'CAMERA_secuirity_FUZZ',
        },
        {
            label = 'Parlaklık',
            source = 'BeastLaunch02',
        },
        {
            label = 'Merkeze odak',
            source = 'AirRaceBoost01',
        },
        {
            label = 'Yeşil efekt',
            source = 'AirRaceBoost02',
        },
        {
            label = 'Keskinlik',
            source = 'AmbientPUSH',
        },
        {
            label = 'Eski efekt mor',
            source = 'ArenaEMP',
        },
        {
            label = 'Eski efekt açık mavi',
            source = 'ArenaEMP_Blend',
        },
        {
            label = 'Eski efekt kahverengi',
            source = 'BeastIntro01',
        },
        {
            label = 'Eski efekt kırmızı',
            source = 'BeastIntro02',
        },
        {
            label = 'Plaj normal',
            source = 'ArenaWheelPurple01',
        },
        {
            label = 'Plaj vurgulu',
            source = 'ArenaWheelPurple02',
        },
        {
            label = 'Derinlik',
            source = 'Bank_HLWD',
        },
        {
            label = '420',
            source = 'Barry1_Stoned',
        },
        {
            label = 'Fazla uyuşturucu',
            source = 'BikerFilter',
        },
        {
            label = 'Kenar Gölgesi',
            source = 'BikerForm01',
        },
        {
            label = 'Meksika filmi açık',
            source = 'Bikers',
        },
        {
            label = 'Meksika filmi koyu',
            source = 'BikersSPLASH',
        },
        {
            label = 'Çizgili yeşil',
            source = 'blackNwhite',
        },
        {
            label = 'Kirli Bulanıklık',
            source = 'BlackOut',
        },
        {
            label = 'Pembe sıcaklık',
            source = 'BleepYellow02',
        },
        {
            label = 'Parlama yoğun',
            source = 'Bloom',
        },
        {
            label = 'Parlama orta',
            source = 'BloomLight',
        },
        {
            label = 'Parlama hafif',
            source = 'BloomMid',
        },
        {
            label = 'Eski TV',
            source = 'Broken_camera_fuzz',
        },
        {
            label = 'Sıcak mavi',
            source = 'BulletTimeDark',
        },
        {
            label = 'Sıcak kırmızı',
            source = 'casino_managersoffice',
        },
        {
            label = 'Gece ve gündüz',
            source = 'casino_mainfloor',
        },
        {
            label = 'Eski Kamera',
            source = 'CHOP',
        },
        {
            label = 'Sinema hafif',
            source = 'cinema',
        },
        {
            label = 'Sinema yoğun',
            source = 'cinema_001',
        },
        {
            label = 'Siyah beyaz parlama',
            source = 'cops',
        },
        {
            label = 'Hafif mor dokunuş',
            source = 'CopsSPLASH',
        },
        {
            label = 'Hafif turuncu dokunuş',
            source = 'CrossLine01',
        },
        {
            label = 'Temiz arka plan',
            source = 'CS1_railwayB_tunnel',
        },
        {
            label = 'Tüm ışığı kaldır',
            source = 'downtown_FIB_cascades_opt',
        },
        {
            label = 'Kırmızı gölge',
            source = 'damage',
        },
        {
            label = 'Sarı vurgu',
            source = 'DrivingFocusLight',
        },
        {
            label = 'Yeşil vurgu',
            source = 'DrivingFocusDark',
        },
        {
            label = 'Mavi damla',
            source = 'DRUG_2_drive',
        },
        {
            label = 'Mor damla',
            source = 'drug_drive_blend02',
        },
        {
            label = 'Su altı',
            source = 'Drug_deadman',
        },
        {
            label = 'Saf yeşil',
            source = 'drug_flying_02',
        },
        {
            label = 'Saf pembe',
            source = 'drug_flying_base',
        },
        {
            label = 'Daha çok ışık',
            source = 'eatra_bouncelight_beach',
        },
        {
            label = 'Kontrast',
            source = 'epsilion',
        },
        {
            label = 'Kontrast 2',
            source = 'exile1_plane',
        },
        {
            label = 'Parlak ışıklar',
            source = 'Facebook_NEW',
        },
        {
            label = 'Parlak ışıklar 2',
            source = 'facebook_serveroom',
        },
        {
            label = 'Parlak ışıklar 3',
            source = 'FIB_5',
        },
        {
            label = 'Parlak ışıklar 4',
            source = 'FIB_6',
        },
        {
            label = 'Parlak ışıklar 5',
            source = 'FIB_A',
        },
        {
            label = 'Parlak ışıklar 6',
            source = 'FIB_B',
        },
        {
            label = 'Bulanık gölge',
            source = 'fp_vig_blue',
        },
        {
            label = 'Bulanık yeşil gölge',
            source = 'fp_vig_green',
        },
        {
            label = 'Yeşile soyulmuş',
            source = 'FranklinColorCode',
        },
        {
            label = 'Yeşile soyulmuş 2',
            source = 'FranklinColorCodeBasic',
        },
        {
            label = 'Yeşile soyulmuş 3',
            source = 'FranklinColorCodeBright',
        },
        {
            label = 'Soğuk renkler',
            source = 'glasses_brown',
        },
        {
            label = 'Mavi ton',
            source = 'glasses_Darkblue',
        },
        {
            label = 'Yeşil ton',
            source = 'glasses_green',
        },
        {
            label = 'Turuncu ton',
            source = 'glasses_orange',
        },
        {
            label = 'Pembe ton',
            source = 'glasses_pink',
        },
        {
            label = 'Mor ton',
            source = 'glasses_purple',
        },
        {
            label = 'Kırmızı ton',
            source = 'glasses_red',
        },
        {
            label = 'Turuncu ve yeşil',
            source = 'glasses_yellow',
        },
        {
            label = 'Sis',
            source = 'graveyard_shootout',
        },
        {
            label = 'Belirsiz gölge',
            source = 'helicamfirst',
        },
        {
            label = 'Kırmızı ve mavi',
            source = 'Hint_cam',
        },
        {
            label = 'Açık mavi',
            source = 'hud_def_colorgrade',
        },
        {
            label = 'Siyah beyaz 2',
            source = 'hud_def_desat_cold_kill',
        },
        {
            label = 'Siyah beyaz 3',
            source = 'hud_def_desatcrunch',
        },
        {
            label = 'Plaj yumuşak',
            source = 'InchPurple01',
        },
        {
            label = 'Beyaz ve açık mavi',
            source = 'int_Hospital2_DM',
        },
        {
            label = 'Düşük siyah ve mavi',
            source = 'introblue',
        },
        {
            label = 'Mor bulanıklık',
            source = 'Kifflom',
        },
        {
            label = 'Soluk arka plan',
            source = 'michealspliff',
        },
        {
            label = 'Duman',
            source = 'MP_Arena_theme_atlantis',
        },
        {
            label = 'Sarı gökyüzü',
            source = 'MP_Arena_theme_evening',
        },
        {
            label = 'Mavi spot ışığı',
            source = 'mp_lad_day',
        },
        {
            label = 'Kırmızı spot ışığı',
            source = 'mp_lad_judgment',
        },
        {
            label = 'Duman 2',
            source = 'nervousRON_fog',
        },
        {
            label = 'Siyah beyaz 4',
            source = 'NG_deathfail_BW_base',
        },
        {
            label = 'Sıcak renkler',
            source = 'NG_filmic10',
        },
        {
            label = 'Siyah beyaz 5',
            source = 'phone_cam7',
        },
        {
            label = 'Koyu sis',
            source = 'SALTONSEA',
        },
        {
            label = 'Koyu sis 2',
            source = 'WATER_cove',
        },
        {
            label = 'Su altı',
            source = 'underwater_deep',
        },
        {
            label = 'Yumuşak pembe',
            source = 'TinyPink01',
        },
    }
}

-- Free camera: hold the key to look around your character
---@type FreeCamConfig
config.freeCam = {
    active = false, -- daddy_photocam took over V
    key = {
        name = "V",
        second = 1,
    },
    canOpen = {
        damage = {
            active = false, -- kapalı: yerine aşağıdaki damageTimer (client/editable.lua) kalan saniyeyi gösteriyor
            time = 30000    -- milisecond (30000 = 30 seconds)
        },
        handWeapon = false -- If true, the player can't open the menu when holding a weapon
    },
    damageTimer = {   -- hasar alınca/verince V free kamera beklemesi; mesajda kalan saniye yazar (client/editable.lua)
        active = true,
        seconds = 30,  -- en fazla 30 sn
    },
    camSetting = {
        yOffset = 3.0,
        zOffset = 0.5,
        maxDistance = 10.0,
    },
    hiddenClose = {    -- the character off the screen or behind a wall: the camera counts down and closes
        active = true,
        seconds = 5,
    },
    headText = {
        active = true,   -- when true, when the player switch the free cam, other players will see FREE_CAM_HEAD_TEXT on the player's head
        cd = 30000,      -- how many milliseconds after the text is shown, show it again
        showTime = 1000, -- display time of the text on the screen
        dist = 10,       -- the distance at which players can see the text
    },
}

config.langs = {}
