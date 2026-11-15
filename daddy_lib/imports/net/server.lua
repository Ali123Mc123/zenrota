-- Big answers and uploads (6-tahta-video-sanat.md 3.6, DL.net, since 1.16.0). reply() sends up to 48 KB inline and
-- more as one latent event at 256 KB/s. receive() takes uploads in latent pieces of up to 128 KB, each acknowledged before
-- the next comes: one upload per player at a time, a size cap, a rate, a timeout; nothing a client says is trusted.
--   DL.net.receive('photo', function(src, data, meta) return { id = 7 } end, { max = 1048576, check = function(src, meta) end })
local net = { INLINE = 49152, LATENT_BPS = 262144, PIECE = 131072 }

-- One event to one player: inline when small, latent when big. bytes: the payload's size when the caller knows it.
function net.reply(src, name, payload, bytes)
    bytes = tonumber(bytes) or #json.encode(payload)
    if bytes > net.INLINE then
        TriggerLatentClientEvent(name, src, net.LATENT_BPS, payload)
    else
        TriggerClientEvent(name, src, payload)
    end
    return bytes
end

-- Uploads called `name`: handler(src, data, meta) runs once the last piece is in and its answer goes back.
-- opts: max (bytes, 1 MB), stale (ms without a piece, 15000), perMinute (uploads a player starts, 6),
-- check(src, meta, total) -> true | false, why (before the first piece).
function net.receive(name, handler, opts)
    opts = opts or {}
    local max, stale, perMinute = opts.max or 1048576, opts.stale or 15000, opts.perMinute or 6
    local E = ('%s:net:%s'):format(GetCurrentResourceName(), name)
    local open, started = {}, {} -- src -> upload; src -> { ms of recent starts }

    local function ack(src, id, index, ok, extra)
        TriggerClientEvent(E .. ':ack', src, id, index, ok, extra)
    end

    local function allowed(src, now)
        local list = started[src] or {}
        local kept = {}
        for _, t in ipairs(list) do
            if now - t < 60000 then kept[#kept + 1] = t end
        end
        started[src] = kept
        if #kept >= perMinute then return false end
        kept[#kept + 1] = now
        return true
    end

    RegisterNetEvent(E .. ':begin', function(id, total, meta)
        local src, now = source, GetGameTimer()
        id, total = math.tointeger(tonumber(id)), math.tointeger(tonumber(total))
        if not id then return end
        local current = open[src]
        if current and now - current.at < stale then return ack(src, id, 0, false, 'busy') end
        if not total or total < 1 or total > max then return ack(src, id, 0, false, 'too_big') end
        if not allowed(src, now) then return ack(src, id, 0, false, 'slow') end
        if opts.check then
            local fine, ok, why = pcall(opts.check, src, meta, total)
            if not fine or not ok then return ack(src, id, 0, false, fine and why or 'error') end
        end
        open[src] = { id = id, total = total, meta = meta, parts = {}, size = 0, next = 1, at = now }
        ack(src, id, 0, true)
    end)

    RegisterNetEvent(E .. ':piece', function(id, index, chunk)
        local src = source
        local up = open[src]
        if not up or up.id ~= id then return end
        if index ~= up.next or type(chunk) ~= 'string' or #chunk == 0 or #chunk > net.PIECE or up.size + #chunk > up.total then
            open[src] = nil
            return ack(src, id, index, false, 'bad')
        end
        up.parts[#up.parts + 1], up.size, up.next, up.at = chunk, up.size + #chunk, up.next + 1, GetGameTimer()
        if up.size < up.total then return ack(src, id, index, true) end
        open[src] = nil
        local fine, result = pcall(handler, src, table.concat(up.parts), up.meta)
        ack(src, id, -1, fine and result ~= nil and result ~= false, fine and result or 'error')
    end)

    AddEventHandler('playerDropped', function()
        open[source], started[source] = nil, nil
    end)
end

return net
