-- Art Studio admin menu (6-tahta-video-sanat.md 3.5): canvases (add with three corners and a floor area, edit with
-- access presets, place again keeping the painting, resolution, mode, delete) and moderation (open reports with the
-- painters: hide, show, clear, dismiss), plus each canvas's log.
local RESOURCE = GetCurrentResourceName()
local PREVIEW = '__preview'
local t = DL.locale.t
local openMenu

local function call(action, data)
    local result = lib.callback.await(RESOURCE .. ':admin', false, action, data or {})
    if type(result) ~= 'table' or not result.ok then
        Studio.notify(type(result) == 'table' and result.error or 'generic')
        return nil
    end
    return result.data
end

local function confirm(text)
    return lib.alertDialog({ header = t('admin.confirm'), content = text, centered = true, cancel = true }) == 'confirm'
end

local function options(list, label)
    local out = {}
    for _, value in ipairs(list) do out[#out + 1] = { value = value, label = label(value) } end
    return out
end

local function presets()
    local out = {}
    for _, p in ipairs(Config.Access.Presets) do out[#out + 1] = { value = p.key, label = t('presets.' .. p.key) } end
    out[#out + 1] = { value = 'custom', label = t('presets.custom') }
    return out
end

local function fields(entry)
    entry = entry or {}
    return {
        { type = 'input', label = t('admin.label'), default = entry.label, max = 60 },
        { type = 'select', label = t('admin.background'), options = options(Config.Backgrounds, function(v) return v end), default = entry.background or Config.Paper },
        { type = 'select', label = t('admin.resolution'), options = options(Config.Resolution.Choices, function(v) return ('%d px'):format(v) end), default = entry.resolution or Config.Resolution.Default },
        { type = 'select', label = t('admin.mode'), options = options({ 'open', 'owned', 'gallery' }, function(v) return t('modes.' .. v) end), default = entry.mode or Config.DefaultMode },
        { type = 'select', label = t('admin.access'), options = presets(), default = entry.preset or 'members' },
        { type = 'input', label = t('admin.custom'), description = t('admin.access_help'), default = entry.paint },
        { type = 'input', label = t('admin.manage'), description = t('admin.access_help'), default = entry.manage },
    }
end

local function values(input)
    return {
        label = input[1], background = input[2], resolution = tonumber(input[3]), mode = input[4], preset = input[5],
        paint = input[6], manage = input[7],
    }
end

local function preview(geometry)
    if not geometry then return Studio.surfaces.remove(PREVIEW) end
    Studio.surfaces.set(PREVIEW, {
        coords = geometry.coords, heading = geometry.heading, width = geometry.width, height = geometry.height,
        background = Config.Paper, ink = false, streamDistance = 60.0,
    })
end

-- Three corners on a wall, then the floor area (optional).
local function place()
    local geometry = DL.place.surface({ preview = preview })
    local zone = geometry and DL.place.zone({ optional = true })
    Studio.surfaces.remove(PREVIEW)
    if not geometry or zone == nil then return nil end
    local c = geometry.coords
    return {
        geometry = { coords = { x = c.x, y = c.y, z = c.z }, heading = geometry.heading, width = geometry.width, height = geometry.height },
        zone = zone or nil,
    }
end

local function add()
    local spot = place()
    if not spot then return end
    local input = lib.inputDialog(t('admin.new_title'), fields())
    if not input then return end
    local data = values(input)
    data.geometry, data.zone = spot.geometry, spot.zone
    local created = call('create', data)
    if created then lib.notify({ description = t('admin.created', created.label), type = 'success' }) end
end

local function teleport(entry)
    local rad = math.rad(entry.heading)
    local c = entry.coords
    pcall(function() exports['FeloxAC']:markExternalTeleport() end) --[[FeloxAC:auto]]
    SetEntityCoords(PlayerPedId(), c.x + math.cos(rad) * 1.5, c.y + math.sin(rad) * 1.5, c.z - entry.height * 0.5, false, false, false, false)
end

local function showLog(entry)
    local lines = call('log', { uid = entry.uid }) or {}
    local list = {}
    for _, line in ipairs(lines) do
        list[#list + 1] = {
            title = ('%s: %s'):format(line.name, t('log.' .. line.action)),
            description = line.detail ~= '' and line.detail or nil,
            readOnly = true,
        }
    end
    if #list == 0 then list[1] = { title = t('admin.no_log'), readOnly = true } end
    lib.registerContext({ id = RESOURCE .. ':log', title = entry.label, menu = RESOURCE .. ':canvas', options = list })
    lib.showContext(RESOURCE .. ':log')
end

local function canvasMenu(entry)
    local opts = {
        { title = t('admin.teleport'), icon = 'location-dot', onSelect = function() teleport(entry) end },
        { title = t('admin.open'), icon = 'palette', onSelect = function() CreateThread(function() Studio.open(entry.uid) end) end },
        {
            title = t('admin.edit'), icon = 'pen',
            onSelect = function()
                local input = lib.inputDialog(entry.label, fields(entry))
                if input then
                    local data = values(input)
                    data.uid = entry.uid
                    call('update', data)
                end
                openMenu()
            end,
        },
        {
            title = t('admin.move'), icon = 'up-down-left-right', description = t('admin.move_help'),
            onSelect = function()
                local spot = place()
                if spot then
                    spot.uid = entry.uid
                    call('move', spot)
                end
            end,
        },
        { title = t('admin.log'), icon = 'list', onSelect = function() showLog(entry) end },
        entry.hidden and {
            title = t('admin.show'), icon = 'eye', onSelect = function() call('show', { uid = entry.uid }) openMenu() end,
        } or {
            title = t('admin.hide'), icon = 'eye-slash', description = t('admin.hide_help'),
            onSelect = function() call('hide', { uid = entry.uid }) openMenu() end,
        },
        {
            title = t('admin.clear'), icon = 'eraser', description = t('admin.clear_help'),
            onSelect = function()
                if confirm(t('admin.clear_confirm', entry.label)) then call('clear', { uid = entry.uid }) end
            end,
        },
        {
            title = t('admin.delete'), icon = 'trash',
            onSelect = function()
                if confirm(t('admin.delete_confirm', entry.label)) and call('delete', { uid = entry.uid }) then openMenu() end
            end,
        },
    }
    lib.registerContext({ id = RESOURCE .. ':canvas', title = entry.label, menu = RESOURCE .. ':menu', options = opts })
    lib.showContext(RESOURCE .. ':canvas')
end

local function reportMenu(report)
    local entry = report.canvas
    local image
    if Ink.blobClient and type(report.thumb) == 'string' and report.thumb ~= '' then
        local map = Ink.blobClient(RESOURCE .. ':ink').await({ report.thumb }, 8000)
        local b64 = type(map) == 'table' and map[report.thumb]
        if type(b64) == 'string' then image = ('data:image/%s;base64,%s'):format(b64:sub(1, 4) == '/9j/' and 'jpeg' or 'png', b64) end
    end
    local painters = {}
    for _, p in ipairs(report.painters or {}) do painters[#painters + 1] = { label = p.name, value = p.n } end
    local function act(action)
        return function()
            call(action, { uid = entry.uid })
            openMenu()
        end
    end
    lib.registerContext({
        id = RESOURCE .. ':report', title = entry.label, menu = RESOURCE .. ':reports',
        options = {
            { title = t('admin.painters'), icon = 'users', metadata = painters, image = image, readOnly = true },
            { title = t('admin.teleport'), icon = 'location-dot', onSelect = function() teleport(entry) end },
            { title = t('admin.hide'), icon = 'eye-slash', description = t('admin.hide_help'), onSelect = act('hide') },
            { title = t('admin.show'), icon = 'eye', onSelect = act('show') },
            {
                title = t('admin.clear'), icon = 'eraser', description = t('admin.clear_help'),
                onSelect = function()
                    if confirm(t('admin.clear_confirm', entry.label)) then act('clear')() end
                end,
            },
            { title = t('admin.dismiss'), icon = 'check', onSelect = act('dismiss') },
        },
    })
    lib.showContext(RESOURCE .. ':report')
end

local function reasons(list)
    local out = {}
    for key in tostring(list or ''):gmatch('[^,]+') do out[#out + 1] = t('reasons.' .. key) end
    return table.concat(out, ', ')
end

local function reportsMenu(list)
    local opts = {}
    for _, r in ipairs(list) do
        opts[#opts + 1] = {
            title = r.canvas.label .. (r.canvas.hidden and t('admin.flag_hidden') or ''), icon = 'flag', arrow = true,
            description = t('admin.report_row', r.n, reasons(r.reasons)), onSelect = function() CreateThread(function() reportMenu(r) end) end,
        }
    end
    if #opts == 0 then opts[1] = { title = t('admin.no_reports'), readOnly = true } end
    lib.registerContext({ id = RESOURCE .. ':reports', title = t('admin.reports'), menu = RESOURCE .. ':menu', options = opts })
    lib.showContext(RESOURCE .. ':reports')
end

openMenu = function()
    local list = call('list') or {}
    local reports = call('reports') or {}
    local here = GetEntityCoords(PlayerPedId())
    local function away(e) return #(here - vector3(e.coords.x, e.coords.y, e.coords.z)) end
    table.sort(list, function(a, b) return away(a) < away(b) end)
    local opts = {
        { title = t('admin.add'), icon = 'plus', description = t('admin.add_help'), onSelect = add },
        { title = t('admin.reports'), icon = 'flag', description = t('admin.reports_count', #reports), arrow = true, onSelect = function() reportsMenu(reports) end },
    }
    for _, entry in ipairs(list) do
        local flags = t('modes.' .. entry.mode) .. (entry.hidden and t('admin.flag_hidden') or '')
        opts[#opts + 1] = {
            title = entry.label, icon = 'palette', arrow = true,
            description = t('admin.row', flags, entry.width, entry.height, away(entry)),
            onSelect = function() canvasMenu(entry) end,
        }
    end
    lib.registerContext({ id = RESOURCE .. ':menu', title = t('admin.title'), options = opts })
    lib.showContext(RESOURCE .. ':menu')
end

RegisterCommand(Config.Command, function()
    if not lib.callback.await(RESOURCE .. ':isAdmin', false) then return Studio.notify('no_permission') end
    openMenu()
end, false)
