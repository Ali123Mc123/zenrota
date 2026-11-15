-- LiveBoard client: board targets, the paint NUI, media hooks and the admin menu.
local RESOURCE = GetCurrentResourceName()
local PREVIEW = '__preview'
local t = DL.locale.t
local boards

local function notify(code, detail, kind)
    local key = 'errors.' .. tostring(code)
    local text = t(key, detail or '?')
    lib.notify({ description = text == key and t('errors.generic') or text, type = kind or 'error' })
end

RegisterNetEvent(RESOURCE .. ':notify', function(key, kind, ...)
    lib.notify({ description = t(key, ...), type = kind or 'inform' })
end)

local mediaPanel

-- The paint view; a teacher with media rights gets the mini player on its right.
local function openUi(payload)
    local item = boards.items[payload.canvas.uid]
    payload.media = item and mediaPanel(item) or nil
    DL.focus.acquire(function() boards.close() end)
    SendNUIMessage({ action = 'open', view = 'paint', payload = payload, locale = DL.locale.table().ui, theme = Config.Theme })
end

local function closeUi()
    BoardMedia.endPanel()
    SendNUIMessage({ action = 'close' })
    DL.focus.release()
end

local function idle()
    return not IsPedInAnyVehicle(PlayerPedId(), false)
end

local function preset(item)
    return Config.Presets[item.preset] or Config.Presets.classroom
end

-- Rights come from the server (on mount and whenever they change); unknown means no.
local function can(item, key)
    return item.can ~= nil and item.can[key] == true
end

mediaPanel = function(item)
    if not Config.Media.Enabled or not preset(item).media or not can(item, 'media') then return nil end
    return BoardMedia.panelFor(item, false)
end

-- The ink editor (Config.Engine 'ink') or the paint view.
local function openBoard(uid, viewOnly)
    if BoardInk.enabled then return BoardInk.open(uid, viewOnly) end
    boards.open(uid, viewOnly)
end

local function targetOptions(item)
    local function run(fn) return function() CreateThread(fn) end end
    local options = {}
    if preset(item).drawing then
        options[#options + 1] = {
            label = t('target.draw'), icon = 'fa-solid fa-chalkboard', onSelect = run(function() openBoard(item.uid) end),
            canInteract = function() return idle() and can(item, 'paint') end,
        }
        options[#options + 1] = {
            label = t('target.view'), icon = 'fa-solid fa-eye', onSelect = run(function() openBoard(item.uid, true) end),
            canInteract = function() return idle() and not can(item, 'paint') end,
        }
        options[#options + 1] = {
            label = t('target.classroom'), icon = 'fa-solid fa-person-chalkboard',
            onSelect = run(function() BoardClassroom.open(item, notify) end),
            canInteract = function() return idle() and can(item, 'teacher') end,
        }
    end
    if Config.Media.Enabled and preset(item).media then
        options[#options + 1] = {
            label = t('target.media'), icon = 'fa-solid fa-photo-film',
            onSelect = run(function() BoardMedia.open(item) end),
            canInteract = function() return idle() and can(item, 'media') end,
        }
    end
    return options
end

Surface.setup({
    page = 'dui/board.html', maxLive = Config.Surface.MaxLive,
    files = { 'dui/board.html', 'dui/media.js', 'packages/canvas/dui/boot.js', 'packages/canvas/dui/canvas.js', 'packages/canvas/dui/canvas.css' },
})

boards = Canvas.client({
    radius = Config.Radius,
    height = Config.Canvas.NearbyHeight,
    distance = Config.Interact.Distance,
    options = targetOptions,
    open = openUi,
    close = closeUi,
    notify = notify,
    key = function(item) return item.preset .. '|' .. item.screen end,
    surface = function(item, data)
        data.resolution = preset(item).resolution
        data.text = DL.locale.table().dui
    end,
    onMount = function(item) BoardMedia.attach(item) end,
    onUnmount = function(uid)
        BoardMedia.detach(uid)
        if BoardInk.enabled then BoardInk.detach(uid) end
    end,
    -- With ink the strokes and surfaces are the engine's: a mount reads the rights, the list goes to the pool.
    rights = BoardInk.enabled and BoardInk.rights or nil,
    onList = BoardInk.enabled and function(items) BoardInk.set(items, boards and boards.streamDistance) end or nil,
})

BoardInk.notify = notify
BoardInk.panel = function(uid)
    local item = boards.items[uid]
    return item and mediaPanel(item) or nil
end

-- A character change closes the paint view.
DL.fw.onUnloaded(function() boards.close() end)

-- Admin menu ------------------------------------------------------------------

local function adminCall(action, data)
    local result = lib.callback.await(RESOURCE .. ':admin', false, action, data or {})
    if type(result) ~= 'table' or not result.ok then
        notify(type(result) == 'table' and result.error or 'generic')
        return nil
    end
    return result.data
end

local function presetOptions(names)
    local out = {}
    for _, name in ipairs(names) do out[#out + 1] = { value = name, label = t('presets.' .. name) } end
    return out
end

local function previewSurface(geometry)
    if not geometry then return Surface.remove(PREVIEW) end
    Surface.set(PREVIEW, {
        coords = geometry.coords, heading = geometry.heading, width = geometry.width, height = geometry.height,
        background = '#ffffff', strokes = {}, streamDistance = 60.0, resolution = 512,
    })
end

local openMenu

local function addBoard(presets)
    local geometry = DL.place.surface({ preview = previewSurface })
    local zone = geometry and DL.place.zone({ optional = true })
    Surface.remove(PREVIEW)
    if not geometry or zone == nil then return end

    local access = DL.product.resource('college') and Config.CollegeAccess or Config.DefaultAccess
    local input = lib.inputDialog(t('admin.new_title'), {
        { type = 'input', label = t('admin.label'), max = 60 },
        { type = 'select', label = t('admin.preset'), options = presetOptions(presets), default = 'classroom' },
        { type = 'input', label = t('admin.group'), description = t('admin.group_help'), max = 48 },
        { type = 'input', label = t('admin.draw_access'), description = t('admin.access_help'), default = access.draw },
        { type = 'input', label = t('admin.media_access'), description = t('admin.access_help'), default = access.media },
    })
    if not input then return end

    local c = geometry.coords
    local created = adminCall('create', {
        geometry = { coords = { x = c.x, y = c.y, z = c.z }, heading = geometry.heading, width = geometry.width, height = geometry.height },
        zone = zone or nil, label = input[1], preset = input[2], group = input[3], draw = input[4], media = input[5], manage = access.manage,
    })
    if not created then return end
    lib.notify({ description = t('admin.created', created.label), type = 'success' })
    if created.room ~= '' then lib.notify({ description = t('admin.linked', created.room), type = 'inform' }) end
end

local function editBoard(entry, presets)
    local input = lib.inputDialog(entry.label, {
        { type = 'input', label = t('admin.label'), default = entry.label, max = 60 },
        { type = 'select', label = t('admin.preset'), options = presetOptions(presets), default = entry.preset },
        { type = 'input', label = t('admin.group'), description = t('admin.group_help'), default = entry.group, max = 48 },
        { type = 'input', label = t('admin.draw_access'), description = t('admin.access_help'), default = entry.draw },
        { type = 'input', label = t('admin.media_access'), description = t('admin.access_help'), default = entry.media },
        { type = 'input', label = t('admin.manage_access'), description = t('admin.access_help'), default = entry.manage },
        { type = 'checkbox', label = t('admin.locked'), checked = entry.locked },
        { type = 'checkbox', label = t('admin.media_locked'), checked = entry.mediaLocked },
        { type = 'checkbox', label = t('admin.active'), checked = entry.active },
    })
    if not input then return end
    adminCall('update', {
        uid = entry.uid, label = input[1], preset = input[2], group = input[3], draw = input[4], media = input[5], manage = input[6],
        locked = input[7] == true, mediaLocked = input[8] == true, active = input[9] == true,
    })
end

local function confirm(text)
    return lib.alertDialog({ header = t('admin.confirm'), content = text, centered = true, cancel = true }) == 'confirm'
end

local function teleport(entry)
    local rad = math.rad(entry.heading)
    local c = entry.coords
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoords(PlayerPedId(), c.x + math.cos(rad) * 2.0, c.y + math.sin(rad) * 2.0, c.z - entry.height * 0.5, false, false, false, false)
end

-- Media of one board's screen: stop it, or lock it so only managers control it.
local function stopScreen(entry)
    if adminCall('stopScreen', { uid = entry.uid }) then lib.notify({ description = t('admin.screen_stopped', entry.label), type = 'success' }) end
end

local function lockScreen(entry)
    local on = not entry.mediaLocked
    if not adminCall('lockScreen', { uid = entry.uid, on = on }) then return end
    entry.mediaLocked = on
    lib.notify({ description = t(on and 'admin.media_locked_on' or 'admin.media_locked_off', entry.label), type = 'success' })
end

local function boardMenu(entry, presets)
    lib.registerContext({
        id = RESOURCE .. ':board',
        title = entry.label,
        menu = RESOURCE .. ':menu',
        options = {
            { title = t('admin.teleport'), icon = 'location-dot', onSelect = function() teleport(entry) end },
            { title = t('admin.edit'), icon = 'pen', onSelect = function() editBoard(entry, presets) openMenu() end },
            { title = t('admin.stop_screen'), icon = 'stop', onSelect = function() stopScreen(entry) end },
            {
                title = entry.mediaLocked and t('admin.unlock_media') or t('admin.lock_media'), icon = entry.mediaLocked and 'lock-open' or 'lock',
                description = t('admin.lock_media_help'), onSelect = function() lockScreen(entry) end,
            },
            {
                title = t('admin.clear'), icon = 'eraser', description = t('admin.strokes', entry.strokes),
                onSelect = function()
                    if confirm(t('admin.clear_confirm', entry.label)) then adminCall('clear', { uid = entry.uid }) end
                end,
            },
            {
                title = t('admin.delete'), icon = 'trash',
                onSelect = function()
                    if confirm(t('admin.delete_confirm', entry.label)) and adminCall('delete', { uid = entry.uid }) then openMenu() end
                end,
            },
        },
    })
    lib.showContext(RESOURCE .. ':board')
end

local function distanceTo(here, entry)
    return #(here - vector3(entry.coords.x, entry.coords.y, entry.coords.z))
end

-- Media operator tools: what plays where, the ban list, the recent log ----------

local function ban(data)
    local input = lib.inputDialog(t('admin.ban_title'), {
        data.key and { type = 'input', label = t('admin.ban_key'), default = data.key, disabled = true }
            or { type = 'input', label = t('admin.ban_url'), description = t('admin.ban_url_help'), required = true, max = 512 },
        { type = 'input', label = t('admin.ban_reason'), max = 160 },
    })
    if not input then return false end
    local done = adminCall('ban', data.key and { lane = data.lane, key = data.key, reason = input[2] } or { url = input[1], reason = input[2] })
    if done then lib.notify({ description = t('admin.banned'), type = 'success' }) end
    return done ~= nil
end

local function playingMenu(entry)
    local name = entry.title ~= '' and entry.title or entry.label
    lib.registerContext({
        id = RESOURCE .. ':playing:one', title = name, menu = RESOURCE .. ':playing',
        options = {
            { title = t('admin.teleport'), icon = 'location-dot', description = entry.label, onSelect = function() teleport(entry) end },
            { title = t('admin.stop_screen'), icon = 'stop', onSelect = function() stopScreen(entry) end },
            { title = entry.mediaLocked and t('admin.unlock_media') or t('admin.lock_media'), icon = entry.mediaLocked and 'lock-open' or 'lock', onSelect = function() lockScreen(entry) end },
            { title = t('admin.ban_this'), icon = 'ban', description = t('admin.ban_this_help'), onSelect = function() ban({ lane = entry.lane, key = entry.key }) end },
        },
    })
    lib.showContext(RESOURCE .. ':playing:one')
end

local function nowPlaying()
    local list = adminCall('playing')
    if not list then return end
    local options = {}
    for _, entry in ipairs(list) do
        options[#options + 1] = {
            title = entry.title ~= '' and entry.title or entry.label, icon = entry.play == 'playing' and 'play' or 'pause', arrow = true,
            description = t('admin.playing_row', entry.label, t('admin.play.' .. entry.play), entry.controller ~= '' and entry.controller or '-', entry.watchers),
            onSelect = function() playingMenu(entry) end,
        }
    end
    if #options == 0 then options[1] = { title = t('admin.nothing_playing'), icon = 'circle-info', disabled = true } end
    lib.registerContext({ id = RESOURCE .. ':playing', title = t('admin.now_playing'), menu = RESOURCE .. ':menu', options = options })
    lib.showContext(RESOURCE .. ':playing')
end

local function banList()
    local list = adminCall('bans')
    if not list then return end
    local options = { { title = t('admin.ban_add'), icon = 'plus', description = t('admin.ban_url_help'), onSelect = function() if ban({}) then banList() end end } }
    for _, entry in ipairs(list) do
        options[#options + 1] = {
            title = entry.key, icon = entry.lane == 'youtube' and 'video' or 'file',
            description = t('admin.ban_row', entry.reason ~= '' and entry.reason or '-', entry.by ~= '' and entry.by or '-'),
            onSelect = function()
                if confirm(t('admin.unban_confirm', entry.key)) and adminCall('unban', { lane = entry.lane, key = entry.key }) then banList() end
            end,
        }
    end
    lib.registerContext({ id = RESOURCE .. ':bans', title = t('admin.bans'), menu = RESOURCE .. ':menu', options = options })
    lib.showContext(RESOURCE .. ':bans')
end

local function recentLog(labels)
    local rows = adminCall('log', { limit = 50 })
    if not rows then return end
    local now, options = GetCloudTimeAsInt(), {}
    for _, row in ipairs(rows) do
        local action = t('admin.log.' .. tostring(row.action))
        options[#options + 1] = {
            title = (action ~= 'admin.log.' .. tostring(row.action) and action or tostring(row.action)) .. (row.detail ~= '' and (': ' .. row.detail) or ''),
            description = t('admin.log_row', row.actor_name ~= '' and row.actor_name or '-', labels[row.board] or row.board or '-', math.max(0, math.floor((now - (tonumber(row.at) or now)) / 60))),
            icon = 'clock-rotate-left', disabled = true,
        }
    end
    if #options == 0 then options[1] = { title = t('admin.log_empty'), icon = 'circle-info', disabled = true } end
    lib.registerContext({ id = RESOURCE .. ':log', title = t('admin.log_title'), menu = RESOURCE .. ':menu', options = options })
    lib.showContext(RESOURCE .. ':log')
end

openMenu = function()
    local data = adminCall('list')
    if not data then return end
    local here = GetEntityCoords(PlayerPedId())
    local labels = {}
    for _, entry in ipairs(data.boards) do labels[entry.uid] = entry.label end
    local options = {
        { title = t('admin.add'), icon = 'plus', description = t('admin.add_help'), onSelect = function() addBoard(data.presets) end },
        { title = t('admin.now_playing'), icon = 'photo-film', arrow = true, description = t('admin.now_playing_help'), onSelect = nowPlaying },
        { title = t('admin.bans'), icon = 'ban', arrow = true, description = t('admin.bans_help'), onSelect = banList },
        { title = t('admin.log_title'), icon = 'clock-rotate-left', arrow = true, onSelect = function() recentLog(labels) end },
        {
            title = t('admin.stop_all'), icon = 'stop',
            onSelect = function()
                local count = adminCall('stopAll')
                if count then lib.notify({ description = t('admin.stopped', count), type = 'success' }) end
            end,
        },
    }
    table.sort(data.boards, function(a, b) return distanceTo(here, a) < distanceTo(here, b) end)
    for _, entry in ipairs(data.boards) do
        local tags = t('presets.' .. entry.preset) .. (entry.group ~= '' and (' | ' .. entry.group) or '')
            .. (entry.room ~= '' and (' | ' .. t('admin.room', entry.room)) or '')
        local flags = (entry.active and '' or t('admin.flag_hidden')) .. (entry.locked and t('admin.flag_locked') or '')
        options[#options + 1] = {
            title = entry.label .. flags, icon = 'chalkboard', arrow = true,
            description = t('admin.row', tags, entry.width, entry.height, distanceTo(here, entry)),
            onSelect = function() boardMenu(entry, data.presets) end,
        }
    end
    lib.registerContext({ id = RESOURCE .. ':menu', title = t('admin.title'), options = options })
    lib.showContext(RESOURCE .. ':menu')
end

RegisterCommand(Config.Command, function()
    if not lib.callback.await(RESOURCE .. ':isAdmin', false) then return notify('no_permission') end
    openMenu()
end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource == RESOURCE and DL.focus.owner() == RESOURCE then SetNuiFocus(false, false) end
end)
