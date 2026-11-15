local function getComponentConfig()
    return {
        masks = not Config.DisableComponents.Masks,
        upperBody = not Config.DisableComponents.UpperBody,
        lowerBody = not Config.DisableComponents.LowerBody,
        bags = not Config.DisableComponents.Bags,
        shoes = not Config.DisableComponents.Shoes,
        scarfAndChains = not Config.DisableComponents.ScarfAndChains,
        bodyArmor = not Config.DisableComponents.BodyArmor,
        shirts = not Config.DisableComponents.Shirts,
        decals = not Config.DisableComponents.Decals,
        jackets = not Config.DisableComponents.Jackets
    }
end
local function getPropConfig()
    return {
        hats = not Config.DisableProps.Hats,
        glasses = not Config.DisableProps.Glasses,
        ear = not Config.DisableProps.Ear,
        watches = not Config.DisableProps.Watches,
        bracelets = not Config.DisableProps.Bracelets
    }
end

local function getHeadOverlayConfig()
    return {
        blemishes = not Config.DisableHeadOverlays.blemishes,
        beard = not Config.DisableHeadOverlays.beard,
        eyebrows = not Config.DisableHeadOverlays.eyebrows,
        ageing = not Config.DisableHeadOverlays.ageing,
        makeUp = not Config.DisableHeadOverlays.makeUp,
        blush = not Config.DisableHeadOverlays.blush,
        complexion = not Config.DisableHeadOverlays.complexion,
        sunDamage = not Config.DisableHeadOverlays.sunDamage,
        lipstick = not Config.DisableHeadOverlays.lipstick,
        moleAndFreckles = not Config.DisableHeadOverlays.moleAndFreckles,
        chestHair = not Config.DisableHeadOverlays.chestHair,
        bodyBlemishes = not Config.DisableHeadOverlays.bodyBlemishes
    }
end

function GetDefaultConfig()
    return {
        ped = false,
        headBlend = false,
        faceFeatures = false,
        headOverlays = false,
        components = false,
        componentConfig = getComponentConfig(),
        props = false,
        propConfig = getPropConfig(),
        headOverlayConfig = getHeadOverlayConfig(),
        tattoos = false,
        enableExit = true,
        hasTracker = Config.PreventTrackerRemoval and Framework.HasTracker(),
        automaticFade = Config.AutomaticFade,
        clothingToggles = Config.ClothingToggles,
    }
end
