if GetResourceState("qb-clothing") ~= "started" then return end

Clothing = Clothing or {}

function Clothing.SetAppearance(data, ped)
    local qbData = {
        model = data.model,
        components = {},
        props = {}
    }

    for _, comp in ipairs(data.components) do
        table.insert(qbData.components, {
            component_id = comp.id,
            drawable = comp.drawable,
            texture = comp.texture,
            palette = comp.palette
        })
    end

    for _, prop in ipairs(data.props) do
        table.insert(qbData.props, {
            prop_id = prop.id,
            drawable = prop.drawable,
            texture = prop.texture
        })
    end

    TriggerEvent('qb-clothing:client:loadPlayerClothing', qbData, ped and ped or PlayerPedId())
end
exports("SetAppearance", Clothing.SetAppearance)

function Clothing.GetAppearance(cb)
    TriggerEvent('qb-clothing:client:getOutfit', function(app)
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
    end)
end
exports("GetAppearance", Clothing.GetAppearance)

function Clothing.ReloadSkin()
    QBCore.Functions.TriggerCallback('qb-clothing:server:getOutfit', function(outfit)
        if outfit then
            TriggerEvent('qb-clothing:client:loadPlayerClothing', outfit, PlayerPedId())
        else
            print("^3[qb-clothing] no saved outfit found.^0")
        end
    end)
end
exports("ReloadSkin", Clothing.ReloadSkin)

print("^2[qb-clothing] working.^0")

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