-- Names shown in the war kill feed. A weapon that is not here shows as its hash.
local names = {
    WEAPON_UNARMED = 'Yumruk', WEAPON_KNIFE = 'Bıçak', WEAPON_BAT = 'Beyzbol sopası', WEAPON_MACHETE = 'Pala', WEAPON_SWITCHBLADE = 'Sustalı',
    WEAPON_KNUCKLE = 'Muşta', WEAPON_HAMMER = 'Çekiç', WEAPON_CROWBAR = 'Levye', WEAPON_GOLFCLUB = 'Golf sopası', WEAPON_BOTTLE = 'Şişe',
    WEAPON_PISTOL = 'Pistol', WEAPON_PISTOL_MK2 = 'Pistol Mk II', WEAPON_COMBATPISTOL = 'Combat pistol', WEAPON_APPISTOL = 'AP pistol',
    WEAPON_PISTOL50 = 'Pistol .50', WEAPON_SNSPISTOL = 'SNS pistol', WEAPON_HEAVYPISTOL = 'Heavy pistol', WEAPON_VINTAGEPISTOL = 'Vintage pistol',
    WEAPON_REVOLVER = 'Revolver', WEAPON_DOUBLEACTION = 'Double action', WEAPON_CERAMICPISTOL = 'Ceramic pistol', WEAPON_MACHINEPISTOL = 'Machine pistol',
    WEAPON_MICROSMG = 'Micro SMG', WEAPON_SMG = 'SMG', WEAPON_SMG_MK2 = 'SMG Mk II', WEAPON_ASSAULTSMG = 'Assault SMG', WEAPON_MINISMG = 'Mini SMG',
    WEAPON_COMBATPDW = 'Combat PDW', WEAPON_GUSENBERG = 'Gusenberg',
    WEAPON_ASSAULTRIFLE = 'Assault rifle', WEAPON_ASSAULTRIFLE_MK2 = 'Assault rifle Mk II', WEAPON_CARBINERIFLE = 'Carbine rifle',
    WEAPON_CARBINERIFLE_MK2 = 'Carbine rifle Mk II', WEAPON_SPECIALCARBINE = 'Special carbine', WEAPON_BULLPUPRIFLE = 'Bullpup rifle',
    WEAPON_COMPACTRIFLE = 'Compact rifle', WEAPON_ADVANCEDRIFLE = 'Advanced rifle',
    WEAPON_PUMPSHOTGUN = 'Pompalı tüfek', WEAPON_SAWNOFFSHOTGUN = 'Kesik pompalı', WEAPON_ASSAULTSHOTGUN = 'Assault shotgun', WEAPON_DBSHOTGUN = 'Çift namlu',
    WEAPON_HEAVYSHOTGUN = 'Heavy shotgun', WEAPON_SNIPERRIFLE = 'Keskin nişancı tüfeği', WEAPON_HEAVYSNIPER = 'Ağır keskin nişancı tüfeği', WEAPON_MARKSMANRIFLE = 'Marksman rifle',
    WEAPON_MG = 'MG', WEAPON_COMBATMG = 'Combat MG', WEAPON_GRENADE = 'El bombası', WEAPON_MOLOTOV = 'Molotof', WEAPON_RUN_OVER_BY_CAR = 'Araç',
}

Config.Weapons = {}
for name, label in pairs(names) do Config.Weapons[joaat(name) & 0xFFFFFFFF] = label end
