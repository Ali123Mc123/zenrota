if GetResourceState("esx_skin") ~= "started" then return end

Clothing = Clothing or {}

function Clothing.SetAppearance(data)
    local skin = {}
    skin.sex = data.model == "mp_m_freemode_01" and 0 or 1

    for _, comp in ipairs(data.components) do
        if comp.id == 11 then skin.torso_1, skin.torso_2 = comp.drawable, comp.texture end
        if comp.id == 8 then skin.tshirt_1, skin.tshirt_2 = comp.drawable, comp.texture end
        if comp.id == 4 then skin.pants_1, skin.pants_2 = comp.drawable, comp.texture end
        if comp.id == 6 then skin.shoes_1, skin.shoes_2 = comp.drawable, comp.texture end
    end
    for _, prop in ipairs(data.props) do
        if prop.id == 0 then skin.helmet_1, skin.helmet_2 = prop.drawable, prop.texture end
        if prop.id == 1 then skin.glasses_1, skin.glasses_2 = prop.drawable, prop.texture end
    end

    TriggerEvent('skinchanger:loadSkin', skin)
end
exports("SetAppearance", Clothing.SetAppearance)

function Clothing.GetAppearance(cb)
    TriggerEvent('skinchanger:getSkin', function(skin)
        if not skin then return cb(nil) end

        local data = {
            model = (skin.sex == 0) and "mp_m_freemode_01" or "mp_f_freemode_01",
            components = {},
            props = {}
        }

        table.insert(data.components, { id = 11, drawable = skin.torso_1, texture = skin.torso_2, palette = 0 })
        table.insert(data.components, { id = 8, drawable = skin.tshirt_1, texture = skin.tshirt_2, palette = 0 })
        table.insert(data.components, { id = 4, drawable = skin.pants_1, texture = skin.pants_2, palette = 0 })
        table.insert(data.components, { id = 6, drawable = skin.shoes_1, texture = skin.shoes_2, palette = 0 })

        table.insert(data.props, { id = 0, drawable = skin.helmet_1, texture = skin.helmet_2 })
        table.insert(data.props, { id = 1, drawable = skin.glasses_1, texture = skin.glasses_2 })

        return data
    end)
end
exports("GetAppearance", Clothing.GetAppearance)

function Clothing.ReloadSkin()
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
        if skin then
            TriggerEvent('skinchanger:loadSkin', skin)
        elseif jobSkin then
            TriggerEvent('skinchanger:loadSkin', jobSkin)
        else
            TriggerEvent('skinchanger:loadSkin', { sex = 0 })
        end
    end)
end
exports("ReloadSkin", Clothing.ReloadSkin)

print("^2[esx_skin] working.^0")

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