-- Settings, reading: every row's value comes live from the game each time the screen loads (profile and FiveM convars,
-- GTA's profile, pma-voice) and changes made anywhere are mirrored to the page while the menu is open. GTA never
-- reports graphics, so those show what the settings driver set or read last (PM.Driver.Cached).
PM.Settings = PM.Settings or {}
local S = PM.Settings
local RESOURCE = GetCurrentResourceName()
local VOICE_KVP = RESOURCE .. ':settings:voice'

local function config() return Config.Settings or {} end

local function readKvp(key)
    local ok, data = pcall(json.decode, GetResourceKvpString(key) or '')
    return ok and type(data) == 'table' and data or {}
end

function S.VoiceResource()
    local name = (config().Voice or {}).Resource or 'pma-voice'
    return GetResourceState(name) == 'started' and name or nil
end

-- Rows the config hides or brings back. Config does not change at runtime and nothing writes these sets: built once.
local hide, show = {}, {}
for _, id in ipairs(config().Hide or {}) do hide[id] = true end
for _, id in ipairs(config().Show or {}) do show[id] = true end
if (Config.Theme or {}).langChoice == false then hide.lang = true end

-- What engines and visibility depend on right now (PMSettings.view / engine / clamp).
function S.Env()
    local cfg = config()
    return {
        privileged = cfg.PrivilegedWrite ~= false,
        driver = cfg.FrontendDriver ~= false and type(PM.Driver) == 'table',
        voice = S.VoiceResource() ~= nil,
        voiceModes = tonumber((cfg.Voice or {}).Modes) or 3,
        -- The last input was a pad: the Gamepad group comes first and open.
        pad = not IsUsingKeyboard(2),
        ranges = cfg.Ranges or {},
        defaults = cfg.Defaults or {},
        hide = hide,
        show = show,
    }
end

function S.RememberVoice(id, value)
    local data = readKvp(VOICE_KVP)
    data[id] = value
    SetResourceKvp(VOICE_KVP, json.encode(data))
end

-- pma-voice keeps the range in the player's state bag (1-based mode) and volumes behind exports (0-100).
local function voiceValue(row, res)
    if row.id == 'voice_proximity' then
        local proximity = LocalPlayer.state.proximity
        local index = type(proximity) == 'table' and tonumber(proximity.index)
        return index and math.floor(index) - 1 or nil
    end
    local fn = row.id == 'radio_volume' and 'getRadioVolume' or 'getCallVolume'
    local ok, volume = pcall(function() return exports[res][fn](exports[res]) end)
    return ok and tonumber(volume) and math.floor(volume / 10 + 0.5) or nil
end

-- A row's current value, nil while the game cannot tell.
function S.Read(row)
    if row.cls == 'F' then return PMSettings.decode(row, GetConvar(row.convar, 'false')) end
    if row.cls == 'P' then
        local res = S.VoiceResource()
        return res and voiceValue(row, res) or nil
    end
    if row.convar then
        local value = GetConvarInt(row.convar, -999)
        return value ~= -999 and value or nil
    end
    if row.pid then return GetProfileSetting(row.pid) end
    if row.cls == 'G' and type(PM.Driver) == 'table' and PM.Driver.Cached then
        local ok, cached = pcall(PM.Driver.Cached)
        return ok and type(cached) == 'table' and tonumber(cached[row.id]) or nil
    end
end

-- Values of the rows the page shows, and the key each key binding row is on ('t_W', 'b_100').
function S.Snapshot(rows)
    local values, keys = {}, {}
    for _, view in ipairs(rows) do
        local row = PMSettings.row(view.id) or view
        if row.cls == 'K' then
            if row.ctrl then
                local ok, code = pcall(GetControlInstructionalButton, 0, row.ctrl, true)
                keys[row.id] = ok and code or ''
            end
        elseif row.kind ~= 'header' and row.cls ~= 'O' and row.cls ~= 'R' then
            values[row.id] = S.Read(row)
        end
    end
    return values, keys
end

-- The server's own key bindings (RegisterKeyMapping): commands of started resources with a key on them ('+' hold
-- commands and plain ones; '-' release commands never carry one). Their key comes from the same native GTA's rows use,
-- on the mapping's hash with the high bit set. This resource's own mappings are left out.
local OWN = GetCurrentResourceName()

local function s32(v)
    v = v & 0xFFFFFFFF
    return v >= 0x80000000 and v - 0x100000000 or v
end

-- The key a command's mapping is on ('t_E', 'b_1013'), nil when the native gives no key.
local function keyOf(name)
    local got, key = pcall(GetControlInstructionalButton, 0, s32(GetHashKey(name) | 0x80000000), true)
    if got and type(key) == 'string' and (key:match('^t_.') or key:match('^b_%d+$')) then return key end
end

-- A mapping's own description and resource, as FiveM shows them on GTA's key binding screen: FiveM writes them to the
-- text label INPUT_<command hash> ("~HC_3~(resource)~s~ description") when that screen lists the mapping, so they are
-- there once GTA's FiveM key page was shown in this game session (opening a FiveM key from here lands on it).
local function described(name)
    local text = GetLabelText(('INPUT_%08X'):format(GetHashKey(name) & 0xFFFFFFFF))
    if type(text) ~= 'string' or text == '' or text == 'NULL' then return nil end
    local tag, desc = text:match('^~HC_3~%((.-)%)~s~%s*(.*)$')
    return ((desc or text):gsub('~.-~', '')), tag
end

function S.FiveMKeys()
    local out, seen = {}, {}
    local ok, commands = pcall(GetRegisteredCommands)
    if not ok or type(commands) ~= 'table' then return out end
    -- The native answers a command no mapping carries with a key all the same: what it says for a name nobody
    -- registers is that answer, and plain commands that get it are no key bindings (chat commands, exports'
    -- commands...). '+' commands are hold mappings by FiveM's convention and always stay: one given that answer has
    -- no key on it.
    local none = keyOf('+' .. OWN .. ':no_key_mapping')
    local named = 0
    for _, cmd in ipairs(commands) do
        local name, res = cmd.name, cmd.resource
        if type(name) == 'string' and name ~= '' and name:sub(1, 1) ~= '-' and not seen[name] and type(res) == 'string'
            and res ~= '' and res ~= OWN and GetResourceState(res) == 'started' then
            local key = keyOf(name)
            if key and (key ~= none or name:sub(1, 1) == '+') then
                seen[name] = true
                local desc, tag = described(name)
                if desc then named = named + 1 end
                out[#out + 1] = { id = 'fk:' .. name, cmd = name:gsub('^%+', ''), resource = tag or res, label = desc, key = key ~= none and key or '' }
            end
        end
    end
    -- Once GTA's screen has named the mappings, a command it left unnamed carries none: its key was the native's guess.
    if named > 0 then
        local kept = {}
        for _, item in ipairs(out) do
            if item.label then kept[#kept + 1] = item end
        end
        out = kept
    end
    local function order(item) return item.label or item.cmd end
    table.sort(out, function(a, b) return a.resource == b.resource and order(a) < order(b) or a.resource < b.resource end)
    PM.Debug('fivem keys: %d mapped, %d named by GTA, unbound answer %s', #out, named, tostring(none))
    for _, item in ipairs(out) do PM.Debug('fivem key %s %s %s', item.resource, item.cmd, item.key) end
    return out
end

-- F8 'pausemenu_debug' on: the key each GTA control is on, as GTA's own default keys (docs.fivem.net controls list)
-- tell what an icon code ('b_1009') is. Printed once per game session.
local dumped = false
function S.DebugKeycodes()
    if dumped or not PM.IsDebug() then return end
    dumped = true
    local line = {}
    for control = 0, 360 do
        local got, key = pcall(GetControlInstructionalButton, 0, control, true)
        line[#line + 1] = ('%d=%s'):format(control, got and tostring(key) or '?')
        if #line == 30 or control == 360 then
            PM.Debug('keycodes %s', table.concat(line, ' '))
            line = {}
        end
    end
end

-- GTA lists resolutions by index only, and Auto hides the aspect ratio: both are shown as the screen is now.
local RATIOS = { { '3:2', 1.5 }, { '4:3', 4 / 3 }, { '5:3', 5 / 3 }, { '5:4', 1.25 }, { '16:9', 16 / 9 }, { '16:10', 1.6 }, { '17:9', 17 / 9 }, { '21:9', 21 / 9 } }

function S.Texts()
    local width, height = GetActualScreenResolution()
    local ratio, best = GetAspectRatio(false), nil
    for _, r in ipairs(RATIOS) do
        if not best or math.abs(r[2] - ratio) < math.abs(best[2] - ratio) then best = r end
    end
    return { vid_resolution = ('%d×%d'):format(width, height), vid_aspect = best[1] }
end

-- Mirror: a convar changed (here, in GTA's own menu, from F8) while the menu is open.
local byConvar = {}
for _, row in ipairs(PMSettings.ROWS) do
    if row.convar then
        byConvar[row.convar] = byConvar[row.convar] or {}
        table.insert(byConvar[row.convar], row)
    end
end

local function mirror(name)
    if not PM.IsOpen() then return end
    for _, row in ipairs(byConvar[name] or {}) do
        PM.Send('pm:settings:value', { id = row.id, value = S.Read(row), pending = S.IsPending(row.id) })
    end
end

AddConvarChangeListener('profile_*', mirror)
for convar, rows in pairs(byConvar) do
    if rows[1].cls == 'F' then AddConvarChangeListener(convar, mirror) end
end

-- pma-voice starts every session at its own volumes: the ones picked here come back once the character is in.
local function restoreVoice()
    local saved = readKvp(VOICE_KVP)
    if not next(saved) then return end
    Wait(3000)
    for id, value in pairs(saved) do
        local row = PMSettings.row(id)
        if row and row.cls == 'P' and row.kind == 'slider' then S.WriteVoice(row, tonumber(value)) end
    end
end

DL.fw.onLoaded(function() CreateThread(restoreVoice) end)
CreateThread(function()
    if DL.fw.isLoggedIn() then restoreVoice() end
end)
