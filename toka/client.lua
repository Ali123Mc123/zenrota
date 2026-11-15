local oldHair = { item = -1, texture = -1 }
local tokaActive = false

RegisterCommand("toka", function()
    local playerPed = PlayerPedId()
    local currentHairItem = GetPedDrawableVariation(playerPed, 2)
    local currentHairTexture = GetPedTextureVariation(playerPed, 2)

    if not tokaActive then
        oldHair.item = currentHairItem
        oldHair.texture = currentHairTexture
    end

    local isMale = GetEntityModel(playerPed) == GetHashKey("mp_m_freemode_01")
    local newHairStyle = isMale and Config.DefaultHairMale or Config.DefaultHairFemale

    if tokaActive then
        SetPedComponentVariation(playerPed, 2, oldHair.item, oldHair.texture, 0)
        tokaActive = false
    else
        local maxHair = GetNumberOfPedDrawableVariations(playerPed, 2)

        if newHairStyle < maxHair then
            SetPedComponentVariation(playerPed, 2, newHairStyle, 0, 0)
            tokaActive = true
        end
    end
end)
