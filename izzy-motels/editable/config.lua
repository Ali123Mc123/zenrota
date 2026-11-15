Config = {}

Config.Framework = "qb" -- qb, qbold, esx, esxold, custom, auto
Config.UseTarget = true -- Only for ox-target or qb-target
Config.CostPerDay = 100
Config.MaxOwnableRooms = 1
Config.DisableLastCheck = true

Config.Motels = {
    [1] = {
        name = "Motel",
        centerCoords = vector3(-1905.7876, -1312.2994, 3.0499),

        buyMotel = vector4(-1909.4893, -1314.5247, 3.0500, 316.3306),
        myRooms = vector4(-1907.1519, -1313.8311, 3.0500, 319.3205),

        outCoords = vector4(-1905.7876, -1312.2994, 3.0499, 319.4852),

        buyMotelPed = "a_m_m_prolhost_01",
        myRoomsPed = "a_m_m_genfat_02",

        maxRooms = 300,

        -- what the screens and the target say here (unset: Config.Local and the defaults below)
        labels = { brand = 'Motel', name = 'Motel', room = 'Motel Odası', place = 'Del Perro Pier', empty = 'Bu motelde kiraladığın bir oda yok. Oda kiralamak için resepsiyondaki görevliyle konuş.' },
    },

    -- Cayo Perico öğrenci yurdu: aynı oda sistemi, her yerde "Yurt" yazar, 200 oda
    [2] = {
        name = "Yurt",
        centerCoords = vector3(4560.2202, -4359.1392, 3.4261),

        buyMotel = vector4(4560.2202, -4359.1392, 3.4261, 3.0223),
        myRooms = vector4(4557.9980, -4359.3540, 3.4261, 3.3829),

        outCoords = vector4(4559.1, -4357.6, 3.4261, 3.0), -- odadan çıkınca: iki görevlinin önü

        buyMotelPed = "a_m_m_prolhost_01",
        myRoomsPed = "a_m_m_genfat_02",

        maxRooms = 200,
        -- costPerDay = 100, -- yurdun kendi günlük ücreti (yoksa Config.CostPerDay)

        labels = { brand = 'Yurt', name = 'Yurt', room = 'Yurt Odası', place = 'Cayo Perico', empty = 'Bu yurtta kiraladığın bir oda yok. Oda kiralamak için resepsiyondaki görevliyle konuş.' },
        texts = {
            OpenBuyMenu = "Yurt Odası Kirala",
            OpenMyRoomMenu = "Yurt Odamı Aç",
            NeedToBeInMotel = "Yurtta olman gerekiyor!",
            TooFaarAway = "Yurda çok uzaktasın",
        },
    }
}

-- A text for one place: its own (Config.Motels[id].texts) or the shared one (Config.Local).
function MotelText(motelId, key)
    local motel = Config.Motels[motelId]
    return motel and motel.texts and motel.texts[key] or Config.Local[key]
end

-- The day price of one place.
function MotelCost(motelId)
    local motel = Config.Motels[motelId]
    return motel and motel.costPerDay or Config.CostPerDay
end

-- What the screens say for one place.
function MotelLabels(motelId)
    local motel = Config.Motels[motelId] or {}
    local l = motel.labels or {}
    return { brand = l.brand or 'Motel', name = l.name or motel.name or 'Motel', room = l.room or 'Motel Odası', place = l.place or '', empty = l.empty }
end

Config.BlipConfig = {
    size = 0.8,
    color = 0,
    sprite = 475,
}

Config.Local = {
    OpenBuyMenu = "Motel Satın Alma Menüsünü Aç",
    OpenMyRoomMenu = "Odamı Aç",
    ExitRoom = "Odadan Çık",
    InviteFriends = "Arkadaşlarını Davet Et",
    OpenStash = "Eşyaları Aç",
    NeedToBeInRoom = "Odada olman gerekiyor!",
    NeedToBeInMotel = "Motelde olman gerekiyor!",
    OpenWardobe = "Dolabı Aç",
    NeedToBeInZoone = "Bölgede olman gerekiyor!",
    NoPermission = "Bu eşyayı açma iznin yok",
    InvitedToRoom = "%s numaralı odaya davet edildin",
    ToAcceptInvite = "Daveti kabul etmek için E tuşuna bas",
    InviteExpired = "Davetin süresi doldu",
    TooFaarAway = "Motele çok uzaktasın",
    RoomAlreadyRented = "Bu oda zaten kiralanmış",
    MaxOwnAbleReached = "Kiralanabilecek maksimum oda sayısına ulaştın",
    RentedRoomForDays = "Odayı %s günlüğüne kiraladın",
    NoMoney = "Yeterli paran yok"

}

-- Do not touch this. If you don't know what you're doing, you can break the script.

-- Auto Framework Detection
if Config.Framework == "auto" then
    if GetResourceState("qb-core") == "started" then
        Config.Framework = "qb"
    elseif GetResourceState("es_extended") == "started" then
        Config.Framework = "esx"
    else
        print("Couldn't find a framework. Using custom framework.")
        Config.Framework = "custom"
    end
end

-- Framework Object
if Config.Framework == "qb" or Config.Framework == "QB" or Config.Framework == "qb-core" then
    Config.Framework = "qb"
    FrameworkObject = exports['qb-core']:GetCoreObject()
elseif Config.Framework == "qbold" then
    FrameworkObject = nil
    Config.Framework = "qb"

    Citizen.CreateThread(function()
        while FrameworkObject == nil do
            TriggerEvent('QBCore:GetObject', function(obj) FrameworkObject = obj end)
            Citizen.Wait(50)
        end
    end)
elseif Config.Framework == "esx" or Config.Framework == "ESX" or Config.Framework == "es_extended" then
    Config.Framework = "esx"
    FrameworkObject = exports['es_extended']:getSharedObject()
elseif Config.Framework == "esxold" then
    FrameworkObject = nil
    Config.Framework = "esx"

    Citizen.CreateThread(function()
        while FrameworkObject == nil do
            TriggerEvent('esx:getSharedObject', function(obj) FrameworkObject = obj end)
            Citizen.Wait(50)
        end
    end)
else
    Config.Framework = "custom"
    -- Write your own code shared object code.
    FrameworkObject = nil
end
