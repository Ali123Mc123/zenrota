-- illenium-appearance exports (fivem-appearance shares them). Its editor does not save, so the lib saves on submit.
local SECTIONS = {
    ped = true, headBlend = true, faceFeatures = true, headOverlays = true, components = true, props = true, tattoos = true,
    componentConfig = { masks = true, upperBody = true, lowerBody = true, bags = true, shoes = true, scarfAndChains = true,
        bodyArmor = true, shirts = true, decals = true, jackets = true },
    propConfig = { hats = true, glasses = true, ear = true, watches = true, bracelets = true },
    enableExit = false, enableSave = true, shopType = 'creator', hasTracker = false, automaticFade = false,
}

return function(ctx)
    local resource, shared = ctx.resource, ctx.shared
    local adapter = {}

    local function call(name, ...)
        local target = exports[resource]
        local ok, result = pcall(target[name], target, ...)
        return ok, result
    end

    -- illenium keeps one tattoo list for every ped it dresses; an explicit empty list stops it leaking between peds.
    local function prepared(skin, model)
        local out = shared.copy(skin)
        out.model = out.model or model
        out.tattoos = out.tattoos or {}
        return out
    end

    -- Works on local preview peds as well as the player.
    function adapter.apply(ped, skin)
        return (call('setPedAppearance', ped, prepared(skin)))
    end

    function adapter.applyPlayer(data)
        return (call('setPlayerAppearance', prepared(data.skin, data.model)))
    end

    -- Not InitializeCharacter: that moves the player to another routing bucket.
    function adapter.creator(gender, session)
        call('setPlayerModel', shared.FREEMODE[gender])
        call('setPedAppearance', PlayerPedId(), shared.defaults(gender))
        if IsScreenFadedOut() then DoScreenFadeIn(500) end -- the editor waits for a faded-in screen
        local config = shared.copy(SECTIONS)
        for key, value in pairs(session.opts.sections or {}) do config[key] = value end
        return (call('startPlayerCustomization', function(appearance) session.finish(appearance or false) end, config))
    end

    -- Same call as illenium's own InitializeCharacter makes after its editor.
    adapter.save = ctx.save or function(appearance)
        TriggerServerEvent('illenium-appearance:server:saveAppearance', appearance)
    end

    return adapter
end
