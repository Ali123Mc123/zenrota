-- Media files on Fivemanage (since 1.21.0). The database keeps only the address; the key stays in daddy_lib.
--   local url, err = DL.media.upload('image', dataUrl, { folder = 'my_product/photo', max = 450000, meta = { citizenid = cid } })
--   local list = DL.media.uploadAll({ { 'image', big }, { 'image', thumb } }, { folder = 'my_product/photo' }) -- urls or nil, err
--   local link = DL.media.presign('video', 300)  -- a page POSTs the file there itself (multipart field 'file')
--   local data = DL.media.fetch(url, 600000)     -- the picture back as a data URL (for a canvas; the host sends no CORS)
--   DL.media.track({ { 'my_table', 'image' } })  -- files no row holds any more are deleted on Fivemanage
-- Calls wait for the answer, so they run inside a thread or a handler. err: 'no_key', 'bad_kind', 'bad_type',
-- 'too_large', 'busy', 'timeout' or 'failed'.
local media = {}

local function await(start)
    local p = promise.new()
    local asked, why = pcall(start, function(...) p:resolve({ ... }) end)
    if not asked then return nil, 'failed', why end
    return table.unpack(Citizen.Await(p))
end

-- Whether uploads of a kind are on (a key is set).
function media.ready(kind)
    local ok, on = pcall(function() return exports.daddy_lib:MediaReady(kind) end)
    return ok and on == true
end

function media.upload(kind, data, opts)
    return await(function(done) exports.daddy_lib:MediaUpload(kind, data, opts, done) end)
end

-- Several files at once ({ kind, data, opts? } each, opts falls back to the shared one): every address in order, or
-- nil and the first error. Nothing is kept half way: either all went up or the caller stores none.
function media.uploadAll(list, opts)
    local results, left = {}, #list
    if left == 0 then return results end
    local p = promise.new()
    for i, item in ipairs(list) do
        local asked = pcall(function()
            exports.daddy_lib:MediaUpload(item[1], item[2], item[3] or opts, function(url, err)
                results[i] = { url, err }
                left = left - 1
                if left == 0 then p:resolve(true) end
            end)
        end)
        if not asked then
            results[i] = { nil, 'failed' }
            left = left - 1
            if left == 0 then p:resolve(true) end
        end
    end
    Citizen.Await(p)
    local out = {}
    for i = 1, #list do
        if not results[i][1] then return nil, results[i][2] end
        out[i] = results[i][1]
    end
    return out
end

function media.presign(kind, seconds)
    return await(function(done) exports.daddy_lib:MediaPresign(kind, seconds, done) end)
end

-- The columns this product keeps addresses in ({ { table, column }, ... }). Once named, a file no column holds any
-- more (a deleted row, a replaced picture) is deleted on Fivemanage within the hour after its first hour. A product
-- that never names its columns keeps every file it uploaded.
function media.track(columns)
    pcall(function() exports.daddy_lib:MediaTrack(columns) end)
end

-- Whether a value is an address the lib may have made (https on fivemanage.com), not a data URL or another host.
function media.isLink(value)
    if type(value) ~= 'string' or #value > 400 or value:find('[%s"\'<>\\]') then return false end
    local host = value:match('^https://([%w%.%-]+)/')
    return host ~= nil and (host == 'fivemanage.com' or host:sub(-15) == '.fivemanage.com')
end

-- A stored picture fetched back as a data URL (at most max bytes), or nil and why.
function media.fetch(url, max)
    if not media.isLink(url) then return nil, 'bad_link' end
    local b64, why = await(function(done) exports.daddy_lib:FetchImage(url, max, done) end)
    if type(b64) ~= 'string' then return nil, why or 'failed' end
    local ok, info = pcall(function() return exports.daddy_lib:ImageInfo(b64) end)
    if not ok or type(info) ~= 'table' then return nil, 'bad_type' end
    return ('data:image/%s;base64,%s'):format(info.type, b64)
end

return media
