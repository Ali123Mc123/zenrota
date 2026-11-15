-- Uploads to the server (6-tahta-video-sanat.md 3.6, DL.net, since 1.16.0): a string in 128 KB latent pieces, each sent
-- once the server acknowledged the one before; one upload at a time per name. The server side is DL.net.receive(name).
-- Pieces go latent: FXServer drops a player past 128 KB/s (384 KB burst) of reliable events ("size overflow").
--   local ok, result = DL.net.upload('photo', base64, { kind = 'jpeg' })  -- inside a thread
local net = { PIECE = 131072, BPS = 262144 }
local listening, waiting, lastId = {}, {}, 0

local function listen(E)
    if listening[E] then return end
    listening[E] = true
    RegisterNetEvent(E .. ':ack', function(id, index, ok, extra)
        local w = waiting[E]
        if w and w.id == id then w.answer = { index = index, ok = ok, extra = extra } end
    end)
end

-- One answer for the upload in flight, or nil after timeoutMs.
local function answer(E, id, timeoutMs)
    local t = GetGameTimer()
    while GetGameTimer() - t < timeoutMs do
        local w = waiting[E]
        if not w or w.id ~= id then return nil end
        if w.answer then
            local a = w.answer
            w.answer = nil
            return a
        end
        Wait(20)
    end
    return nil
end

-- data: a string. true and the handler's answer, or false and why ('busy', 'too_big', 'slow', 'bad', 'timeout', ...).
function net.upload(name, data, meta, timeoutMs)
    if type(data) ~= 'string' or #data == 0 then return false, 'empty' end
    local E = ('%s:net:%s'):format(GetCurrentResourceName(), name)
    listen(E)
    if waiting[E] then return false, 'busy' end
    timeoutMs = timeoutMs or 15000
    lastId = lastId + 1
    local id = lastId
    waiting[E] = { id = id }
    local function done(ok, extra)
        waiting[E] = nil
        return ok, extra
    end
    TriggerServerEvent(E .. ':begin', id, #data, meta)
    local a = answer(E, id, timeoutMs)
    if not a then return done(false, 'timeout') end
    if not a.ok then return done(false, a.extra) end
    local index = 0
    for at = 1, #data, net.PIECE do
        index = index + 1
        TriggerLatentServerEvent(E .. ':piece', net.BPS, id, index, data:sub(at, at + net.PIECE - 1))
        a = answer(E, id, timeoutMs)
        if not a then return done(false, 'timeout') end
        if not a.ok then return done(false, a.extra) end
        if a.index == -1 then return done(true, a.extra) end
    end
    a = answer(E, id, timeoutMs)
    if not a then return done(false, 'timeout') end
    return done(a.ok == true, a.extra)
end

return net
