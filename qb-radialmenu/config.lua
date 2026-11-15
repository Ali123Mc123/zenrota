Config = {}

Config.EnableExtraMenu = false
Config.ExtrasEnabled = true
Config.UseWhilstWalking = true

Config.MenuItems = {
    {
        id = 'blips',
        title = 'Harita',
        icon = 'map-marked-alt',
        items = {
            {
                id = 'enyakins',
                title = 'En Yakın Konum',
                icon = 'map-marker',
                items = {
                    { id = 'gasstation', title = 'Benzinlik',   icon = 'gas-pump',   type = 'client', event = 'qb-radialmenu:client:togglegas',      shouldClose = true },
                    { id = 'barbershop', title = 'Berber',      icon = 'cut',        type = 'client', event = 'qb-radialmenu:client:togglebarber',   shouldClose = true },
                    { id = 'clothing',   title = 'Kıyafetci',   icon = 'tshirt',     type = 'client', event = 'qb-radialmenu:client:toggleclothing', shouldClose = true },
                    { id = 'store',      title = 'Marketler',   icon = 'store',      type = 'client', event = 'qb-radialmenu:client:togglestores',   shouldClose = true },
                    { id = 'ammunation', title = 'Silahcı',     icon = 'crosshairs', type = 'client', event = 'qb-radialmenu:client:togglegun',      shouldClose = true },
                    { id = 'carwash',    title = 'Araç Yıkama', icon = 'soap',       type = 'client', event = 'qb-radialmenu:client:toggleyikama',   shouldClose = true },
                }
            },
            {
                id = 'blipackapas',
                title = 'Blip Aç/Kapat',
                icon = 'eye',
                items = {
                    { id = 'store',      title = 'Marketler',     icon = 'store',      type = 'client', event = 'blips:toggleMarket',   shouldClose = true },
                    { id = 'garages',    title = 'Garajlar',      icon = 'warehouse',  type = 'client', event = 'blips:toggleGaraj',    shouldClose = true },
                    { id = 'specialgarages', title = 'Özel Garajlar', icon = 'helicopter', type = 'client', event = 'blips:toggleOzelGaraj', shouldClose = true },
                    { id = 'tattos',     title = 'Dövme Dükkanı', icon = 'brush',      type = 'client', event = 'blips:toggleTattos',   shouldClose = true },
                    { id = 'sea',        title = 'Bot Garajı',    icon = 'ship',       type = 'client', event = 'blips:toggleSeaGaraj', shouldClose = true },
                    { id = 'gasstation', title = 'Benzinlik',     icon = 'gas-pump',   type = 'client', event = 'blips:toggleBenzin',   shouldClose = true },
                    { id = 'ammunation', title = 'Silahcı',       icon = 'crosshairs', type = 'client', event = 'blips:toggleGunShop',  shouldClose = true },
                    { id = 'yikama',     title = 'Araç Yıkama',   icon = 'soap',       type = 'client', event = 'blips:toggleYikama',   shouldClose = true },
                    { id = 'aktiviteler', title = 'Aktiviteler',  icon = 'person-swimming', type = 'client', event = 'blips:toggleAktiviteler', shouldClose = true }
                }
            },
            { id = 'butunblip', title = 'Bütün Blipleri Aç/Kapat', icon = 'map', type = 'client', event = 'blips:toggleAll', shouldClose = true }
        }
    },
    {
        id = 'actions',
        title = 'Etkileşimler',
        icon = 'hand-pointer',
        items = {
            { id = 'getintrunk',       title = 'Bagaja Gir',     icon = 'box-open',     type = 'client',  event = 'qb-trunk:client:GetIn',             shouldClose = true },
            { id = 'çapa',             title = 'Çapa At/Kaldır', icon = 'anchor',       type = 'client',  event = 'qb-radialmenu:capaat',              shouldClose = true },
            { id = 'rob',              title = 'Soy',            icon = 'mask',         type = 'client',  event = 'police:client:RobPlayer',           shouldClose = true },
            { id = 'playerinvehicle',  title = 'Araca Koy',      icon = 'walking',      type = 'client',  event = 'police:client:PutPlayerInVehicle',  shouldClose = true },
            { id = 'playeroutvehicle', title = 'Araçtan Çıkart', icon = 'walking',      type = 'client',  event = 'police:client:SetPlayerOutVehicle', shouldClose = true },
            { id = 'escort2',          title = 'Taşı',           icon = 'user-friends', type = 'client',  event = 'police:client:EscortPlayer',        shouldClose = true },
            { id = 'escort3',          title = 'Kucakla',        icon = 'hands',        type = 'command', event = 'kucakla',                           shouldClose = true },
            { id = 'dondurbea',        title = 'Araç Çevir',     icon = 'car-crash',    type = 'client',  event = 'qb-radialmenu:aracevir',            shouldClose = true }
        }
    },
    {
        id = 'clothesmenu',
        title = 'Kıyafet',
        icon = 'tshirt',
        items = {
            { id = 'hırka',    title = 'Hırka',    icon = 'tshirt',        type = 'command', event = 'hırka',    shouldClose = true },
            { id = 'tişört',   title = 'Tişört',   icon = 'tshirt',        type = 'command', event = 'tişört',   shouldClose = true },
            { id = 'pantolon', title = 'Pantolon', icon = 'user',          type = 'command', event = 'pantolon', shouldClose = true },
            { id = 'ayakkabı', title = 'Ayakkabı', icon = 'shoe-prints',   type = 'command', event = 'ayakkabı', shouldClose = true },
            { id = 'maske',    title = 'Maske',    icon = 'theater-masks', type = 'command', event = 'maske',    shouldClose = true },
            { id = 'hair',     title = 'Saç',      icon = 'cut',           type = 'command', event = 'saç',      shouldClose = true },
            { id = 'gloves',   title = 'Eldiven',  icon = 'mitten',        type = 'command', event = 'eldiven',  shouldClose = true },
            {
                id = 'meer',
                title = 'Aksesuarlar',
                icon = 'plus',
                items = {
                    { id = 'şapka',      title = 'Şapka',    icon = 'hat-cowboy-side', type = 'command', event = 'şapka',      shouldClose = true },
                    { id = 'vizör',      title = 'Vizör',    icon = 'hat-cowboy-side', type = 'command', event = 'vizör',      shouldClose = true },
                    { id = 'gözlük',     title = 'Gözlük',   icon = 'glasses',         type = 'command', event = 'gözlük',     shouldClose = true },
                    { id = 'kulaklık',   title = 'Kulaklık', icon = 'deaf',            type = 'command', event = 'kulaklık',   shouldClose = true },
                    { id = 'kolye',      title = 'Kolye',    icon = 'user-tie',        type = 'command', event = 'kolye',      shouldClose = true },
                    { id = 'yelek',      title = 'Yelek',    icon = 'vest',            type = 'command', event = 'yelek',      shouldClose = true },
                    { id = 'çanta',      title = 'Çanta',    icon = 'shopping-bag',    type = 'command', event = 'çanta',      shouldClose = true },
                    { id = 'bileklik',   title = 'Bileklik', icon = 'user',            type = 'command', event = 'bileklik',   shouldClose = true },
                    { id = 'saat',       title = 'Saat',     icon = 'stopwatch',       type = 'command', event = 'saat',       shouldClose = true },
                    { id = 'kıyafetgiy', title = 'Giyin',    icon = 'undo',            type = 'command', event = 'kıyafetgiy', shouldClose = true }
                }
            }
        }
    }
}

Config.JobInteractions = {
    ["leo"] = {
        {
            id = 'citizen_interactions',
            title = 'Vatandaş İşlemleri',
            icon = 'user-slash',
            items = {
                { id = 'searchplayer', title = 'Üst Ara',      icon = 'hand-holding',        type = 'client',  event = 'police:client:SearchPlayer',        shouldClose = true },
                { id = 'escort',       title = 'Taşı',         icon = 'user-friends',        type = 'client',  event = 'police:client:EscortPlayer',        shouldClose = true },
                { id = 'fingerprint',  title = 'Parmak izi',   icon = 'fingerprint',         type = 'client',  event = 'can9work:fingerprint:client:Check', shouldClose = true },
                { id = 'checkstatus',  title = 'GSR Testi',    icon = 'vial',                type = 'client',  event = 'police:client:CheckStatus',         shouldClose = true },
                { id = 'jailplayer',   title = 'Hapis Cezası', icon = 'user-lock',           type = 'client',  event = 'police:client:JailPlayer',          shouldClose = true },
                { id = 'billing',      title = 'Fatura Kes',   icon = 'file-invoice-dollar', type = 'command', event = 'faturakes',                         shouldClose = true },
                { id = 'kamuver',      title = 'Kamu Ver',     icon = 'user-slash',          type = 'command', event = 'kamu',                              shouldClose = true }
            }
        },
        {
            id = 'vehicle_interactions',
            title = 'Araç İşlemleri',
            icon = 'car',
            items = {
                { id = 'towvehicle',         title = 'Aracı Çek',       icon = 'truck-pickup', type = 'client', event = 'qb-radialmenu:arac-cek',                    shouldClose = true },
                { id = 'checkvehicletuning', title = 'Tuning Kontrolü', icon = 'microchip',    type = 'client', event = 'can9work:engineControl:CheckVehicleTuning', shouldClose = true },
                { id = 'vehiclekey',         title = 'Kapıyı Kır',      icon = 'key',          type = 'client', event = 'wais-vehiclekey:client:policeUnlock',       shouldClose = true }
            }
        },
        {
            id = 'police_objects',
            title = 'Nesne İşlemleri',
            icon = 'road',
            items = {
                { id = 'cone',         icon = 'exclamation', title = 'Trafik Konisi',      type = 'client', event = 'can9work-radialmenu/client/spawnCone',       shouldClose = true },
                { id = 'gate',         icon = 'torii-gate',  title = 'Bariyer',            type = 'client', event = 'can9work-radialmenu/client/spawnGate',       shouldClose = true },
                { id = 'speedSign',    icon = 'sign',        title = 'Hız Sınırı Levhası', type = 'client', event = 'can9work-radialmenu/client/spawnSpeedSign',  shouldClose = true },
                { id = 'tent',         icon = 'campground',  title = 'Çadır',              type = 'client', event = 'can9work-radialmenu/client/spawnTent',       shouldClose = true },
                { id = 'lighting',     icon = 'lightbulb',   title = 'Aydınlatma',         type = 'client', event = 'can9work-radialmenu/client/spawnLighting',   shouldClose = true },
                { id = 'spikeStrip',   icon = 'caret-up',    title = 'Lastik Durdurucu',   type = 'client', event = 'can9work-radialmenu/client/spawnSpikeStrip', shouldClose = true },
                { id = 'deleteObject', icon = 'trash',       title = 'Nesneyi Sil',        type = 'client', event = 'can9work-radialmenu/client/deleteObject',    shouldClose = true }
            }
        }
    },
    ["ambulance"] = {
        { id = 'revivep',          title = 'Tedavi et',          icon = 'user-md',      type = 'client', event = 'hospital:client:RevivePlayer',           shouldClose = true },
        { id = 'treatwounds',      title = 'Yaraları iyileştir', icon = 'band-aid',     type = 'client', event = 'hospital:client:TreatWounds',            shouldClose = true },
        { id = 'emergencybutton2', title = 'Acil Durum!',        icon = 'bell',         type = 'client', event = 'police:client:SendPoliceEmergencyAlert', shouldClose = true },
        { id = 'escort',           title = 'Taşı',               icon = 'user-friends', type = 'client', event = 'kd-kelepce:tasi',                        shouldClose = true }
    },
    ["mechanic"] = {
        { id = 'towvehicle', title = 'Aracı Çek', icon = 'truck-pickup', type = 'client', event = 'qb-radialmenu:arac-cek', shouldClose = true }
    },
    ["guvenlik"] = {
        {
            id = 'citizen_interactions',
            title = 'Vatandaş İşlemleri',
            icon = 'user-slash',
            items = {
                { id = 'searchplayer', title = 'Üst Ara', icon = 'hand-holding', type = 'client', event = 'police:client:SearchPlayer', shouldClose = true },
                { id = 'escort', title = 'Taşı', icon = 'user-friends', type = 'client', event = 'police:client:EscortPlayer', shouldClose = true },
                -- Mevcut qbx_police kelepce sistemi (handcuffs item'i gerekir). Ikinci bir
                -- kelepce sistemi YOK; sunucu tarafi dogrulama police:server:CuffPlayer'da.
                { id = 'cuff', title = 'Kelepçele', icon = 'handcuffs', type = 'client', event = 'police:client:CuffPlayer', shouldClose = true }
            }
        },
        {
            id = 'vehicle_interactions',
            title = 'Araç İşlemleri',
            icon = 'car',
            items = {
                { id = 'towvehicle', title = 'Aracı Çek', icon = 'truck-pickup', type = 'client', event = 'qb-radialmenu:arac-cek', shouldClose = true }
            }
        }
    },
    ["security"] = {
        {
            id = 'citizen_interactions',
            title = 'Vatandaş İşlemleri',
            icon = 'user-slash',
            items = {
                { id = 'searchplayer', title = 'Üst Ara', icon = 'hand-holding', type = 'client', event = 'police:client:SearchPlayer', shouldClose = true },
                { id = 'escort', title = 'Taşı', icon = 'user-friends', type = 'client', event = 'police:client:EscortPlayer', shouldClose = true }
            }
        }
    },
    ["news"] = {
        {
            id = 'weazel_objects',
            title = 'Basın Ekipmanları',
            icon = 'video',
            items = {
                { id = 'tv_cam',          icon = 'video',        title = 'Yayın Kamerası',      type = 'client', event = 'can9work-radialmenu/client/spawnNewsProp', prop = 'tv_cam',          shouldClose = true },
                { id = 'film_cam',        icon = 'film',         title = 'Tripodlu Kamera',     type = 'client', event = 'can9work-radialmenu/client/spawnNewsProp', prop = 'film_cam',        shouldClose = true },
                { id = 'studio_light',    icon = 'lightbulb',    title = 'Stüdyo Işığı',        type = 'client', event = 'can9work-radialmenu/client/spawnNewsProp', prop = 'studio_light',    shouldClose = true },
                { id = 'work_light',      icon = 'sun',          title = 'Projektör Işık',      type = 'client', event = 'can9work-radialmenu/client/spawnNewsProp', prop = 'work_light',      shouldClose = true },
                { id = 'mike_stand',      icon = 'microphone',   title = 'Mikrofon Standı',     type = 'client', event = 'can9work-radialmenu/client/spawnNewsProp', prop = 'mike_stand',      shouldClose = true },
                { id = 'director_chair',  icon = 'chair',        title = 'Yönetmen Koltuğu',    type = 'client', event = 'can9work-radialmenu/client/spawnNewsProp', prop = 'director_chair',  shouldClose = true },
                { id = 'press_table',     icon = 'table',        title = 'Basın Masası',        type = 'client', event = 'can9work-radialmenu/client/spawnNewsProp', prop = 'press_table',     shouldClose = true },
                { id = 'press_barrier',   icon = 'torii-gate',   title = 'Basın Bariyeri',      type = 'client', event = 'can9work-radialmenu/client/spawnNewsProp', prop = 'press_barrier',   shouldClose = true },
                { id = 'delete_news_obj', icon = 'trash',        title = 'Nesneyi Kaldır',      type = 'client', event = 'can9work-radialmenu/client/deleteNewsObject',                         shouldClose = true }
            }
        }
    },
    ["weazel"] = {
        {
            id = 'weazel_objects',
            title = 'Basın Ekipmanları',
            icon = 'video',
            items = {
                { id = 'tv_cam',          icon = 'video',        title = 'Yayın Kamerası',      type = 'client', event = 'can9work-radialmenu/client/spawnNewsProp', prop = 'tv_cam',          shouldClose = true },
                { id = 'film_cam',        icon = 'film',         title = 'Tripodlu Kamera',     type = 'client', event = 'can9work-radialmenu/client/spawnNewsProp', prop = 'film_cam',        shouldClose = true },
                { id = 'studio_light',    icon = 'lightbulb',    title = 'Stüdyo Işığı',        type = 'client', event = 'can9work-radialmenu/client/spawnNewsProp', prop = 'studio_light',    shouldClose = true },
                { id = 'work_light',      icon = 'sun',          title = 'Projektör Işık',      type = 'client', event = 'can9work-radialmenu/client/spawnNewsProp', prop = 'work_light',      shouldClose = true },
                { id = 'mike_stand',      icon = 'microphone',   title = 'Mikrofon Standı',     type = 'client', event = 'can9work-radialmenu/client/spawnNewsProp', prop = 'mike_stand',      shouldClose = true },
                { id = 'director_chair',  icon = 'chair',        title = 'Yönetmen Koltuğu',    type = 'client', event = 'can9work-radialmenu/client/spawnNewsProp', prop = 'director_chair',  shouldClose = true },
                { id = 'press_table',     icon = 'table',        title = 'Basın Masası',        type = 'client', event = 'can9work-radialmenu/client/spawnNewsProp', prop = 'press_table',     shouldClose = true },
                { id = 'press_barrier',   icon = 'torii-gate',   title = 'Basın Bariyeri',      type = 'client', event = 'can9work-radialmenu/client/spawnNewsProp', prop = 'press_barrier',   shouldClose = true },
                { id = 'delete_news_obj', icon = 'trash',        title = 'Nesneyi Kaldır',      type = 'client', event = 'can9work-radialmenu/client/deleteNewsObject',                         shouldClose = true }
            }
        }
    }
}

Config.TrunkClasses = {
    [0] = { allowed = true, x = 0.0, y = -1.5, z = 0.0 },
    [1] = { allowed = true, x = 0.0, y = -2.0, z = 0.0 },
    [2] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 },
    [3] = { allowed = true, x = 0.0, y = -1.5, z = 0.0 },
    [4] = { allowed = true, x = 0.0, y = -2.0, z = 0.0 },
    [5] = { allowed = true, x = 0.0, y = -2.0, z = 0.0 },
    [6] = { allowed = true, x = 0.0, y = -2.0, z = 0.0 },
    [7] = { allowed = true, x = 0.0, y = -2.0, z = 0.0 },
    [8] = { allowed = false, x = 0.0, y = -1.0, z = 0.25 },
    [9] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 },
    [10] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 },
    [11] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 },
    [12] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 },
    [13] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 },
    [14] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 },
    [15] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 },
    [16] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 },
    [17] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 },
    [18] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 },
    [19] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 },
    [20] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 },
    [21] = { allowed = true, x = 0.0, y = -1.0, z = 0.25 }
}

Config.ClothingCommands = {
    ["hırka"] = { Func = function() ToggleClothing("Top") end, Sprite = "top", Desc = "Üstünü çıkar/giy", Button = 1, Name = "Torso" },
    ["eldiven"] = { Func = function() ToggleClothing("gloves") end, Sprite = "gloves", Desc = "Eldivenini çıkar/tak", Button = 2, Name = "Gloves" },
    ["vizör"] = { Func = function() ToggleProps("visor") end, Sprite = "visor", Desc = "Şapka varyasyonunu değiştir", Button = 3, Name = "Visor" },
    ["çanta"] = { Func = function() ToggleClothing("Bag") end, Sprite = "bag", Desc = "Çantanı aç/kapat", Button = 8, Name = "Bag" },
    ["ayakkabı"] = { Func = function() ToggleClothing("Shoes") end, Sprite = "shoes", Desc = "Ayakkabını çıkar/giy", Button = 5, Name = "Shoes" },
    ["yelek"] = { Func = function() ToggleClothing("Vest") end, Sprite = "vest", Desc = "Yeleğini çıkar/giy", Button = 14, Name = "Vest" },
    ["saç"] = { Func = function() ToggleClothing("hair") end, Sprite = "hair", Desc = "Saçını topla/aç/topuz/at kuyruğu yap", Button = 7, Name = "Hair" },
    ["şapka"] = { Func = function() ToggleProps("Hat") end, Sprite = "hat", Desc = "Şapkanı çıkar/tak", Button = 4, Name = "Hat" },
    ["gözlük"] = { Func = function() ToggleProps("Glasses") end, Sprite = "glasses", Desc = "Gözlüğünü çıkar/tak", Button = 9, Name = "Glasses" },
    ["kulaklık"] = { Func = function() ToggleProps("Ear") end, Sprite = "ear", Desc = "Kulak aksesuarını çıkar/tak", Button = 10, Name = "Ear" },
    ["kolye"] = { Func = function() ToggleClothing("Neck") end, Sprite = "neck", Desc = "Boyun aksesuarını çıkar/tak", Button = 11, Name = "Neck" },
    ["saat"] = { Func = function() ToggleProps("Watch") end, Sprite = "watch", Desc = "Saatini çıkar/tak", Button = 12, Name = "Watch" },
    ["bileklik"] = { Func = function() ToggleProps("Bracelet") end, Sprite = "bracelet", Desc = "Bilekliğini çıkar/tak", Button = 13, Name = "Bracelet" },
    ["maske"] = { Func = function() ToggleClothing("Mask") end, Sprite = "mask", Desc = "Maskeni çıkar/tak", Button = 6, Name = "Mask" },
    ["pantolon"] = { Func = function() ToggleClothing("Pants", true) end, Sprite = "pants", Desc = "Pantolonunu çıkar/giy", Name = "Pants" },
    ["tişört"] = { Func = function() ToggleClothing("Shirt", true) end, Sprite = "shirt", Desc = "Üstünü çıkar/giy", Name = "shirt" },
    ["kıyafetgiy"] = { Func = function() if not ResetClothing(true) then Notify('Kıyafetlerini giydin', 'success') end end, Sprite = "reset", Desc = "Hızlıca kıyafetlerini giyin", Name = "reset" }
}
