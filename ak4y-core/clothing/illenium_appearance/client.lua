if GetResourceState("illenium-appearance") ~= "started" then return end

Clothing = Clothing or {}

function Clothing.SetAppearance(data, ped)
    local targetPed = ped or PlayerPedId()

    local oldSkin = exports['illenium-appearance']:getPedAppearance(targetPed)
    if not oldSkin then return end

    local illeniumData = oldSkin

    if data.model then
        illeniumData.model = joaat(data.model)
    end

    if data.components then
        for _, comp in ipairs(data.components) do
            for i, old in ipairs(illeniumData.components) do
                if old.component_id == comp.id then
                    illeniumData.components[i].drawable = comp.drawable
                    illeniumData.components[i].texture = comp.texture
                end
            end
        end
    end

    if data.props then
        for _, prop in ipairs(data.props) do
            for i, old in ipairs(illeniumData.props) do
                if old.prop_id == prop.id then
                    illeniumData.props[i].drawable = prop.drawable
                    illeniumData.props[i].texture = prop.texture
                end
            end
        end
    end

    if ped then
        exports['illenium-appearance']:setPedAppearance(targetPed, illeniumData)
    else
        exports['illenium-appearance']:setPlayerAppearance(illeniumData)
        Wait(500)
        local currentOutfit = exports["illenium-appearance"]:getPedAppearance(PlayerPedId())
        TriggerServerEvent("illenium-appearance:server:saveAppearance", currentOutfit)
    end
end
exports("SetAppearance", Clothing.SetAppearance)

function Clothing.GetAppearance(cb)
    local app = exports['illenium-appearance']:getPedAppearance(PlayerPedId())
    if not app then return cb(nil) end

    local data = {
        model = app.model,
        components = {},
        props = {}
    }

    for _, comp in ipairs(app.components) do
        table.insert(data.components, {
            id = comp.component_id,
            drawable = comp.drawable,
            texture = comp.texture,
            palette = comp.palette or 0
        })
    end
    for _, prop in ipairs(app.props) do
        table.insert(data.props, {
            id = prop.prop_id,
            drawable = prop.drawable,
            texture = prop.texture
        })
    end

    return data
end
exports("GetAppearance", Clothing.GetAppearance)

function Clothing.ReloadSkin()
    TriggerEvent("illenium-appearance:client:reloadSkin")
end
exports("ReloadSkin", Clothing.ReloadSkin)

print("^2[illenium-appearance] working.^0")

-- local appearance = {
--     model = "mp_m_freemode_01", -- veya mp_f_freemode_01
--     components = {
--         { id = 0, drawable = 0, texture = 0, palette = 0 },  -- Face
--         { id = 1, drawable = 0, texture = 0, palette = 0 },  -- Mask
--         { id = 2, drawable = 0, texture = 0, palette = 0 },  -- Hair
--         { id = 3, drawable = 0, texture = 0, palette = 0 },  -- Torso
--         { id = 4, drawable = 0, texture = 0, palette = 0 },  -- Leg
--         { id = 5, drawable = 0, texture = 0, palette = 0 },  -- Bag/Parachute
--         { id = 6, drawable = 0, texture = 0, palette = 0 },  -- Shoes
--         { id = 7, drawable = 0, texture = 0, palette = 0 },  -- Accessories
--         { id = 8, drawable = 0, texture = 0, palette = 0 },  -- Undershirt
--         { id = 9, drawable = 0, texture = 0, palette = 0 },  -- Body Armour
--         { id = 10, drawable = 0, texture = 0, palette = 0 }, -- Decals
--         { id = 11, drawable = 0, texture = 0, palette = 0 }  -- Top
--     },
--     props = {
--         { id = 0, drawable = -1, texture = -1 }, -- Hat
--         { id = 1, drawable = -1, texture = -1 }, -- Glasses
--         { id = 2, drawable = -1, texture = -1 }, -- Ear accessories
--         { id = 6, drawable = -1, texture = -1 }, -- Watch
--         { id = 7, drawable = -1, texture = -1 }  -- Bracelet
--     }
-- }