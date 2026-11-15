-- ============================================================================
-- Daddy GPS - Blip Utilities & Global State
-- ============================================================================
-- Central registry for all GPS blip data. Each remote player gets ONE blip
-- entry: { blip, overlay, cur, target, lastSprite, lastColour, lastLabel,
--   lastHeading, isStationary }
-- ============================================================================

Blips = {}
UnitsPresent = {}
CurrentChannel = 'Global'
ForceImmediateReskin = false
IsConnected = false

-- ============================================================================
-- Persistent Settings (KVP)
-- ============================================================================

local KVP_SELFBLIP    = 'daddy_gps_selfblip'
local KVP_BLIPSIZES   = 'daddy_gps_blipsizes'
local KVP_BLIPCATMODE = 'daddy_gps_blipcatmode'

-- Valid blip-category modes:
--   'single'     = all GPS blips share Config.BlipCategory (one legend group)
--   'department' = each department gets its own legend group, header shows dept name
--   'none'       = grouped by department, blip label shows only the dept short label
--                  (e.g. "PD", "EMS") instead of the full officer name+callsign
local VALID_CAT_MODES = { single = true, department = true, none = true }

-- Load SelfBlip preference (falls back to config default)
local _savedSelfBlip = GetResourceKvpString(KVP_SELFBLIP)
if _savedSelfBlip ~= nil then
    ShowSelfBlip = (_savedSelfBlip == 'true')
else
    ShowSelfBlip = Config.SelfBlip and Config.SelfBlip.Default or false
end

-- Load BlipSizes preference (falls back to config defaults)
local _savedSizes = GetResourceKvpString(KVP_BLIPSIZES)
if _savedSizes then
    local decoded = json.decode(_savedSizes)
    if decoded and type(decoded) == 'table' then
        local VALID_KEYS = { Vehicle=true, OnFoot=true, Bike=true, Helicopter=true, Plane=true, Boat=true }
        for k, v in pairs(decoded) do
            if VALID_KEYS[k] and type(v) == 'number' and v >= 0.4 and v <= 1.5 then
                Config.BlipSizes[k] = v
            end
        end
    end
end

function SaveSelfBlipKVP(state)
    SetResourceKvp(KVP_SELFBLIP, state and 'true' or 'false')
end

function SaveBlipSizesKVP()
    SetResourceKvp(KVP_BLIPSIZES, json.encode({
        Vehicle    = Config.BlipSizes.Vehicle    or 0.70,
        OnFoot     = Config.BlipSizes.OnFoot     or 0.70,
        Bike       = Config.BlipSizes.Bike       or 0.70,
        Helicopter = Config.BlipSizes.Helicopter or 0.70,
        Plane      = Config.BlipSizes.Plane      or 0.70,
        Boat       = Config.BlipSizes.Boat       or 0.70,
    }))
end

-- ============================================================================
-- Blip Category Mode (legend grouping preference)
-- ============================================================================

local _savedCatMode = GetResourceKvpString(KVP_BLIPCATMODE)
if _savedCatMode and VALID_CAT_MODES[_savedCatMode] then
    BlipCategoryMode = _savedCatMode
else
    BlipCategoryMode = 'single'
end

function SaveBlipCategoryModeKVP(mode)
    if VALID_CAT_MODES[mode] then
        SetResourceKvp(KVP_BLIPCATMODE, mode)
    end
end

function IsValidBlipCategoryMode(mode)
    return VALID_CAT_MODES[mode] == true
end

-- Per-department category id assignment (stable across session).
-- Categories 11..127 are custom slots that the engine accepts since
-- citizenfx/fivem PR #3223. We assign deterministically from the enabled
-- department list so re-renders stay consistent.
local _deptCategoryIds = nil

local function buildDeptCategoryIds()
    local ids = {}
    local nextId = 11
    -- Stable ordering: sorted dept keys
    local keys = {}
    for k, d in pairs(Config.Departments or {}) do
        if d and d.enabled then keys[#keys+1] = k end
    end
    table.sort(keys)
    for _, k in ipairs(keys) do
        ids[k] = nextId
        -- Register the department short label as the legend category header so
        -- the map legend shows e.g. "PD" or "EMS" instead of a blank/numeric entry.
        local deptLabel = (Config.Departments[k] and Config.Departments[k].label) or k:upper()
        AddTextEntry('BLIP_CTGRY_' .. nextId, deptLabel)
        nextId = nextId + 1
        if nextId > 127 then break end
    end
    return ids
end

function GetDepartmentCategoryId(job)
    if not _deptCategoryIds then
        _deptCategoryIds = buildDeptCategoryIds()
    end
    return _deptCategoryIds[job]
end

-- Resolve which blip-category id to apply for a given job under the active mode.
function ResolveBlipCategory(job)
    local mode = BlipCategoryMode or 'single'
    -- Both 'department' and 'none' (dept-label) group blips by department.
    -- The difference is only in the blip label, not the category id.
    if (mode == 'department' or mode == 'none') and job then
        local id = GetDepartmentCategoryId(job)
        if id then return id end
    end
    -- 'single' (default) and fallback
    return Config.BlipCategory or 2
end

-- Returns the short department label for a job (e.g. "PD", "EMS").
-- Used in 'none' (dept-label) mode where blip names show only the dept tag.
function GetDeptLabel(job)
    local d = Config.Departments[job]
    return (d and d.label) or (job and job:upper()) or 'GPS'
end

-- Constants (from Config with safe defaults)
TICK_MS       = Config.LerpTickMs or 200
LERP_ALPHA    = Config.LerpAlpha or 0.15
EPS           = Config.CoordEpsilon or 0.2
NON_TINTABLE  = Config.NonTintableSprites or { [2]=true, [3]=true, [15]=true, [41]=true, [42]=true }
DefaultSprites = Config.DefaultSprites or { heli=422, plane=16, boat=427, walk=1, car=56, bike=226 }

-- ============================================================================
-- Blip Size Helper
-- ============================================================================

function GetBlipSizeForKind(kind)
    local size
    if kind == 'walk' then size = Config.BlipSizes.OnFoot or 0.70
    elseif kind == 'bike' then size = Config.BlipSizes.Bike or 0.70
    elseif kind == 'heli' then size = Config.BlipSizes.Helicopter or 0.70
    elseif kind == 'plane' then size = Config.BlipSizes.Plane or 0.70
    elseif kind == 'boat' then size = Config.BlipSizes.Boat or 0.70
    else size = Config.BlipSizes.Vehicle or 0.70 end
    -- Clamp size between 0.4 and 1.5
    if size < 0.4 then size = 0.4 end
    if size > 1.5 then size = 1.5 end
    return size
end

-- Chase-aware size: returns Chase size when sprite is chase (42)
function GetBlipSizeForState(kind, sprite)
    if sprite == 42 then
        local size = Config.BlipSizes.Chase or 0.50
        if size < 0.4 then size = 0.4 end
        if size > 1.5 then size = 1.5 end
        return size
    end
    return GetBlipSizeForKind(kind)
end

vTypeIDMap = {
    [1] = 'walking',
    [2] = 'car',
    [3] = 'bike',
    [4] = 'boat',
    [5] = 'heli',
    [6] = 'plane'
}

-- ============================================================================
-- Math Helpers
-- ============================================================================

function Lerp(a, b, t)
    return a + (b - a) * t
end

function Distance2D(x1, y1, x2, y2)
    return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function RemoveBlipSafe(h)
    if h and DoesBlipExist(h) then RemoveBlip(h) end
end

-- ============================================================================
-- Label / Style Helpers
-- ============================================================================

function DeptCode(job)
    local d = Config.Departments[job]
    return d and d.label or (job and job:upper() or "UNK")
end

function GetJobStyle(job)
    local d = Config.Departments[job]
    if d then return d end
    return { color = 0, sprite = 1 }
end

function BuildLabel(u)
    return string.format("[%d] %s", tonumber(u.callsign) or 0, u.name)
end

function VehKind(u)
    local vt = u and u.vehType or nil
    if vt then
        vt = tostring(vt)
        if vt == 'heli'    then return 'heli' end
        if vt == 'plane'   then return 'plane' end
        if vt == 'boat'    then return 'boat' end
        if vt == 'bike'    then return 'bike' end
        if vt == 'walking' or vt == 'nil' then return 'walk' end
        return 'car'
    end
    return 'car'
end

function ResolveSprite(u)
    local kind = VehKind(u)
    -- Chase blip when siren is active on emergency vehicle
    if u.siren then
        if kind == 'heli' then return 422 end
        return 42
    end
    if kind == 'heli' then
        if (u.job == 'lsms' or u.job == 'ambulance') then return 353 end
        return DefaultSprites.heli
    end
    if kind == 'plane' then return DefaultSprites.plane end
    if kind == 'boat'  then return DefaultSprites.boat  end
    if kind == 'walk'  then return DefaultSprites.walk  end
    if kind == 'bike'  then return DefaultSprites.bike  end
    return DefaultSprites.car
end

-- ============================================================================
-- Bulk Cleanup
-- ============================================================================

function ClearAllGpsBlips()
    for _, d in pairs(Blips) do
        RemoveBlipSafe(d.blip)
        RemoveBlipSafe(d.overlay)
    end
    Blips = {}
    UnitsPresent = {}
end
