local interiors = {

    ["neox_lstuners"] = {
        coords = vec3(882.8219, -2512.03418, 41.7234764),
        sets = {
            ["lstuners_neon-on"] = true,
            ["lstuners_neon-off"] = false,
            ["lstuners_reds_auto"] = false,
        }
    },
}

for name, v in pairs(interiors) do
    RequestIpl(name)
    local interior = GetInteriorAtCoordsWithType(v.coords, "neox_lstuners_col")

    if IsValidInterior(interior) then
        for name, enable in pairs(v.sets) do
            if enable then
                ActivateInteriorEntitySet(interior, name)
            else
                DeactivateInteriorEntitySet(interior, name)
            end
        end

        RefreshInterior(interior)
    end
end
