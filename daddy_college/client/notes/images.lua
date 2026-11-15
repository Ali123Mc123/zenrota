-- Pictures in the notebook on the client: the editor's and reader's calls, whole pictures arriving one at a time over
-- a latent event (a failure stays quiet: the page shows a torn corner), and the staff menu of /noteimages.
if not Core.ModuleEnabled('notes') or not Config.Notes.Images then return end

local t = DL.locale.t
local waiting, fetching = {}, false

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:notes:' .. name, false, data))
end

-- The page reads the answer's own fields; the copy NormalizeResult adds would send pages and thumbnails twice.
local function once(result)
    result.data = nil
    return result
end

-- Calls whose failure the player is told about.
for _, name in ipairs({ 'attachImage', 'removeImage', 'reportImage', 'moderateImage' }) do
    Core.Nui.SafeCallback('notes:' .. name, function(data)
        local result = call(name, data)
        if not result.ok then Core.HandleResult(result, 'notes') end
        return once(result)
    end)
end

-- The picker says itself why it is empty (no phone, an exam, Screen Time).
Core.Nui.SafeCallback('notes:photos', function(data)
    return once(call('photos', { kind = data.kind, before = data.before }))
end)

RegisterNetEvent('daddy_college:notes:image', function(id, src)
    local pending = waiting[id]
    if not pending then return end
    waiting[id] = nil
    pending:resolve(src)
end)

-- The answer says the picture may be seen; its bytes follow (or came first) on the latent event.
local function fetch(id, staff)
    local pending = promise.new()
    waiting[id] = pending
    local result = call('image', { imageId = id, staff = staff == true })
    if result.ok and not result.src then
        SetTimeout(20000, function()
            if waiting[id] == pending then
                waiting[id] = nil
                pending:resolve(false)
            end
        end)
        result.src = Citizen.Await(pending)
        if not result.src then return { ok = false, error = 'timeout' } end
    end
    waiting[id] = nil
    return result
end

-- One picture whole; asked one after another, as the server sends one at a time.
Core.Nui.SafeCallback('notes:image', function(data)
    if type(data.imageId) ~= 'string' then return { ok = false, error = 'validation' } end
    while fetching do Wait(50) end
    fetching = true
    local done, result = pcall(fetch, data.imageId, data.staff)
    fetching = false
    return done and result or { ok = false, error = 'generic_error' }
end, 45000)

-- Staff ----------------------------------------------------------------------------------------------------------

local function openPage(id)
    local result = call('imagePage', { imageId = id })
    if not result.ok then return Core.HandleResult(result, 'notes') end
    Core.Nui.Open('notes.reader', result)
end

local function act(id, action)
    if action == 'remove' and lib.alertDialog({ header = t('notes.images.action_remove'), content = t('notes.images.confirm_remove'), centered = true, cancel = true }) ~= 'confirm' then
        return lib.showContext('college_note_images')
    end
    local result = call('moderateImage', { imageId = id, action = action })
    if not result.ok then Core.HandleResult(result, 'notes') end
end

-- What staff may do with one picture of the list.
local function pick(row)
    local options = { { title = t('notes.images.open_page'), icon = 'fa-solid fa-book-open', onSelect = function() CreateThread(function() openPage(row.id) end) end } }
    local function add(action, icon)
        options[#options + 1] = { title = t('notes.images.action_' .. action), icon = icon, onSelect = function() CreateThread(function() act(row.id, action) end) end }
    end
    if row.state == 'live' then add('hide', 'fa-solid fa-eye-slash') end
    if row.state == 'hidden' then add('show', 'fa-solid fa-eye') end
    if row.state ~= 'removed' then add('remove', 'fa-solid fa-trash') end
    lib.registerContext({ id = 'college_note_image', title = row.by, menu = 'college_note_images', options = options })
    lib.showContext('college_note_image')
end

RegisterNetEvent('daddy_college:notes:imageList', function(title, list)
    local options = {}
    for _, row in ipairs(type(list) == 'table' and list or {}) do
        options[#options + 1] = {
            title = ('%s · %s'):format(row.at, t('notes.images.state_' .. row.state)),
            description = t('notes.images.list_row', row.by, t('notes.images.source_' .. row.source), row.reports, t('notes.images.in_' .. row.where)),
            onSelect = function() pick(row) end,
        }
    end
    if #options == 0 then options[1] = { title = t('notes.images.list_empty'), disabled = true } end
    lib.registerContext({ id = 'college_note_images', title = title, options = options })
    lib.showContext('college_note_images')
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    for id, pending in pairs(waiting) do
        waiting[id] = nil
        pending:resolve(false)
    end
end)
