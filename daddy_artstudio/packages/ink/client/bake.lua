-- Ink baking on the client (6-tahta-video-sanat.md 3.2, baking; P3): the server hands this player a bake or a check
-- job (server/bake.lua). The tiles it starts from come by hash (Ink.blobClient), the product's NUI draws it in a
-- worker (web/src/bake/bake.ts and bake.worker.ts) and the answer goes up in 64 KB pieces (DL.net.upload). One job at
-- a time; one that cannot be done is handed back at once (<event>:unbaked), so the server asks the next player.
--   Ink.baker({ event = 'res:ink' })  -- this file starts one for '<resource>:ink'
Ink = Ink or {}

local started, pending, busy = {}, {}, false -- event -> baker; nonce -> { job, E }; a job in hand

RegisterNUICallback('ink:baked', function(data, cb)
    cb('ok')
    local task = type(data) == 'table' and pending[data.nonce]
    if not task then return end
    pending[data.nonce] = nil
    CreateThread(function()
        local job = task.job
        if data.error or not (DL and DL.net) then
            TriggerServerEvent(task.E .. ':unbaked', job.nonce)
        else
            local body = job.mode == 'bake' and { job = job.job, nonce = job.nonce, tiles = data.tiles or {}, thumb = data.thumb or '' }
                or { job = job.job, nonce = job.nonce, sums = data.sums or {} }
            local ok, why = DL.net.upload(job.mode == 'bake' and 'ink_bake' or 'ink_check', json.encode(body), { job = job.job, nonce = job.nonce }, 30000)
            if not ok then print(('[ink] a %s upload failed: %s'):format(tostring(job.mode), tostring(why))) end
        end
        busy = false
    end)
end)

function Ink.baker(opts)
    opts = opts or {}
    local E = opts.event or (GetCurrentResourceName() .. ':ink')
    if started[E] then return started[E] end
    local blobs = Ink.blobClient(E)

    RegisterNetEvent(E .. ':bake', function(job)
        if type(job) ~= 'table' or not math.tointeger(job.nonce) then return end
        if busy then return TriggerServerEvent(E .. ':unbaked', job.nonce) end
        busy = true
        CreateThread(function()
            local hashes = {}
            for _, h in pairs(type(job.start) == 'table' and job.start or {}) do hashes[#hashes + 1] = h end
            local got = blobs.await(hashes, 15000)
            if not got then
                busy = false
                return TriggerServerEvent(E .. ':unbaked', job.nonce)
            end
            local start = {}
            for key, h in pairs(job.start or {}) do start[key] = got[h] end
            pending[job.nonce] = { job = job, E = E }
            SendNUIMessage({ type = 'ink:bake', job = job, start = start })
            SetTimeout(30000, function() -- the NUI never answered (an old build): free for the next job
                if pending[job.nonce] then
                    pending[job.nonce], busy = nil, false
                end
            end)
        end)
    end)

    started[E] = { event = E }
    return started[E]
end

Ink.baker()
