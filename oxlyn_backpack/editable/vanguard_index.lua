-- Vanguard çantaları addon kıyafet; global drawable numarası sunucudaki diğer kıyafet
-- paketlerine göre kayıyor. Sabit numara yerine oyuncunun ped'inde koleksiyondan
-- gerçek numarayı bulup Config.Backpacks'e yazıyoruz (her model değişiminde).
local FREEMODE = { [`mp_m_freemode_01`] = true, [`mp_f_freemode_01`] = true }

-- Koleksiyon adını tahmin etmek yerine ped'in koleksiyonları içinde 'vanguard' geçeni bul
local function findCollection(ped)
    for i = 0, GetPedCollectionsCount(ped) - 1 do
        local name = GetPedCollectionName(ped, i)
        if name and name:lower():find('vanguard', 1, true) then return name end
    end
end

-- Çanta adı -> vanguard doku numarası (0-6)
local TEXTURES = {
    backpack_level_1 = 0,
    backpack_level_2 = 1,
    backpack_level_3 = 2,
    backpack_level_4 = 3,
}

print('^2[Oxlyn Backpack]^7 client yüklendi')

-- Teşhis: /cantatest -> model, koleksiyon numarası, çanta item sayısı, sırttaki kıyafet
RegisterCommand('cantatest', function()
    local ped = PlayerPedId()
    local model = GetEntityModel(ped)
    local collection = FREEMODE[model] and findCollection(ped)
    local ok, drawable = pcall(GetPedDrawableGlobalIndexFromCollection, ped, 5, collection or '', 0)
    local names = {}
    for i = 0, GetPedCollectionsCount(ped) - 1 do names[#names + 1] = tostring(GetPedCollectionName(ped, i)) end
    print('[Oxlyn Backpack] koleksiyonlar: ' .. table.concat(names, ', '))
    print(('[Oxlyn Backpack] model=%s koleksiyon=%s drawable=%s (pcall %s) sırttaki=%d/%d'):format(
        model, tostring(collection), tostring(drawable), tostring(ok),
        GetPedDrawableVariation(ped, 5), GetPedTextureVariation(ped, 5)))
    if ok and drawable and drawable >= 0 then
        print(('[Oxlyn Backpack] toplam çanta=%d  vanguard doku=%d  geçerli=%s  önceki(%d) doku=%d'):format(
            GetNumberOfPedDrawableVariations(ped, 5), GetNumberOfPedTextureVariations(ped, 5, drawable),
            tostring(IsPedComponentVariationValid(ped, 5, drawable, 0)),
            drawable - 1, GetNumberOfPedTextureVariations(ped, 5, drawable - 1)))
    end
    for _, bp in ipairs(Config.Backpacks) do
        local count = GetResourceState('ox_inventory') == 'started' and exports.ox_inventory:GetItemCount(bp.name) or -1
        print(('  %s adet=%s config=%s/%s'):format(bp.name, tostring(count),
            bp.component and tostring(bp.component.male.drawable) or '-', bp.component and tostring(bp.component.male.texture) or '-'))
    end
end, false)

local lastModel
CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local model = GetEntityModel(ped)
        local collection = FREEMODE[model] and findCollection(ped)
        if collection and model ~= lastModel then
            local drawable = GetPedDrawableGlobalIndexFromCollection(ped, 5, collection, 0)
            if drawable and drawable >= 0 then
                lastModel = model
                for _, bp in ipairs(Config.Backpacks) do
                    local tex = TEXTURES[bp.name]
                    if tex then
                        local c = { drawable = drawable, texture = tex }
                        bp.component = { male = c, female = c }
                        bp.prop = nil
                    end
                end
            end
        elseif not collection then
            lastModel = nil
        end
        Wait(2000)
    end
end)

-- Teşhis: /cantadene <drawable> <doku> -> sırt çantası slotunu elle ayarla
RegisterCommand('cantadene', function(_, args)
    local ped = PlayerPedId()
    local d, t = tonumber(args[1]) or 0, tonumber(args[2]) or 0
    SetPedComponentVariation(ped, 5, d, t, 0)
    print(('[Oxlyn Backpack] uygulandı %d/%d -> sırttaki=%d/%d'):format(d, t,
        GetPedDrawableVariation(ped, 5), GetPedTextureVariation(ped, 5)))
end, false)
