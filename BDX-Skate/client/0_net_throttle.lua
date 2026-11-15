-- BDX-Skate: istemci -> sunucu ağ olayı freni
-- ProSkate.lua escrowlu (okunamıyor); bu dosya ondan ÖNCE yüklenir ve bu kaynağın
-- TriggerServerEvent'ini sarar. Aynı isimli olay saniyede BURST'ten fazla atılırsa
-- (her karede gönderen döngü) araya giren çağrılar birleştirilir: en son argümanlar
-- en geç MIN_INTERVAL ms'de bir gönderilir. Tek seferlik olaylar hiç beklemez.
-- Sebep: FiveM istemci başına güvenilir olay bayt bütçesini aşınca oyuncuyu
-- "Reliable network event size overflow: <olay>" ile atıyor (FeloxAC tünel olayı adıyla).

local rawTSE = TriggerServerEvent
if type(rawTSE) ~= 'function' then return end
local rawLatent = TriggerLatentServerEvent -- FeloxAC bunu da kendi tünelinden geçiriyor

local BURST = 4            -- 1 sn pencerede aynı olaydan beklemeden geçen adet
local MIN_INTERVAL = 250   -- ms, spam başlayınca aynı olay en fazla bu sıklıkta
local BIG_PAYLOAD = 8192   -- bayt, bundan büyük tek olay güvenilir kanaldan GİTMEZ (latent'e çevrilir)
local LATENT_BPS = 100000  -- bayt/sn, latent gönderim hızı

local state = {}
local warned = {}

local function exempt(name)
    -- ox_lib callback'leri ve cfx iç olayları yanıt bekler, dokunma
    return type(name) ~= 'string' or name:find('^__ox_cb') or name:find('^__cfx')
end

local function warnOnce(key, msg)
    if warned[key] then return end
    warned[key] = true
    print(('^3[BDX-Skate] %s^7'):format(msg))
end

local function send(name, args)
    local ok, packed = pcall(msgpack.pack, args)
    if ok and packed and #packed > BIG_PAYLOAD and type(rawLatent) == 'function' then
        -- Asıl atılma sebebi: tek bir güvenilir olay boyut sınırını aşınca istemci
        -- "Reliable network event size overflow" ile düşüyor. Büyük olay latent
        -- kanaldan parça parça gider; sunucudaki RegisterNetEvent aynen alır.
        warnOnce('big:' .. name, ('büyük ağ olayı latent gönderildi: %s (%d bayt)'):format(name, #packed))
        return rawLatent(name, LATENT_BPS, table.unpack(args, 1, args.n))
    end
    return rawTSE(name, table.unpack(args, 1, args.n))
end

TriggerServerEvent = function(name, ...)
    if exempt(name) then
        return send(name, table.pack(...))
    end

    local now = GetGameTimer()
    local s = state[name]
    if not s then
        s = { win = now, count = 0, last = 0 }
        state[name] = s
    end
    if now - s.win >= 1000 then
        s.win = now
        s.count = 0
    end
    s.count = s.count + 1

    if s.count <= BURST and not s.scheduled then
        s.last = now
        return send(name, table.pack(...))
    end

    -- spam: en son argümanları tut, tek bir gecikmeli gönderim planla
    s.pending = table.pack(...)
    if s.scheduled then return end
    s.scheduled = true
    warnOnce('spam:' .. name, ('ağ olayı spamı frenlendi: %s'):format(name))
    CreateThread(function()
        local waitMs = MIN_INTERVAL - (GetGameTimer() - s.last)
        if waitMs > 0 then Wait(waitMs) end
        local args = s.pending
        s.pending = nil
        s.scheduled = false
        s.last = GetGameTimer()
        if args then send(name, args) end
    end)
end
