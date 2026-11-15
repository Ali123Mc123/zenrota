-- BDX-Sport-Hub: büyük ağ olayı koruması (dosyalar escrowlu, bu dosya hepsinden önce yüklenir)
-- Tek bir güvenilir olay boyut sınırını aşınca FiveM istemciyi
-- "Reliable network event size overflow: <FeloxAC tünel olayı>" ile atıyor.
-- 8 KB üstü olaylar latent kanaldan (parça parça) gönderilir; FeloxAC latent'i de
-- kendi tünelinden geçiriyor, sunucudaki RegisterNetEvent aynen alır.
-- Sıklık freni YOK: sadece boyuta bakar, olaylar birleştirilmez/düşürülmez.

local rawTSE = TriggerServerEvent
local rawLatent = TriggerLatentServerEvent
if type(rawTSE) ~= 'function' or type(rawLatent) ~= 'function' then return end

local BIG_PAYLOAD = 8192
local LATENT_BPS = 100000
local warned = {}

TriggerServerEvent = function(name, ...)
    local args = table.pack(...)
    local ok, packed = pcall(msgpack.pack, args)
    if ok and packed and #packed > BIG_PAYLOAD then
        if not warned[name] then
            warned[name] = true
            print(('^3[BDX-Sport-Hub] büyük ağ olayı latent gönderildi: %s (%d bayt)^7'):format(tostring(name), #packed))
        end
        return rawLatent(name, LATENT_BPS, table.unpack(args, 1, args.n))
    end
    return rawTSE(name, table.unpack(args, 1, args.n))
end
