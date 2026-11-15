-- One marker at a time: a DUI sign drawn over a spot, seen through walls at a fixed size.
-- Lessons mark classrooms and teachers with it, security marks incidents.
Core.Waypoint = {}

local cfg = Config.Waypoint
local WIDTH, HEIGHT, LEASE = 512, 160, 'college:waypoint'
local marked, handle, ready, txd
local made = 0
local lastLabel, lastDistance = nil, -1

local function destroy()
    if handle then DestroyDui(handle) end
    handle, ready, lastLabel, lastDistance = nil, false, nil, -1
end

-- The DUI comes from the shared budget; losing the lease only hides the label.
local function ensure()
    if handle then return true end
    if not DL.dui.acquire(LEASE, 0.0, destroy) then return false end
    handle = CreateDui(('nui://%s/web/dist/waypoint.html'):format(cache.resource), WIDTH, HEIGHT)
    -- A runtime texture cannot be pointed at a new DUI, so each DUI gets its own.
    made = made + 1
    txd = 'dc_waypoint_' .. made
    CreateRuntimeTextureFromDuiHandle(CreateRuntimeTxd(txd), 'label', GetDuiHandle(handle))
    CreateThread(function()
        local tries = 0
        while handle and not IsDuiAvailable(handle) and tries < 200 do
            tries = tries + 1
            Wait(50)
        end
        ready = handle ~= nil and IsDuiAvailable(handle)
        if ready then SendDuiMessage(handle, json.encode({ accent = Config.Theme.accent })) end
    end)
    return true
end

-- Sends the label (with its kind) and the metre count only when they change.
local function push(label, kind, distance)
    if not ready or (label == lastLabel and distance == lastDistance) then return end
    lastLabel, lastDistance = label, distance
    SendDuiMessage(handle, json.encode({ label = label, kind = kind, distance = distance }))
end

local function finish(arrived)
    if not marked then return end
    local label = marked.label
    marked = nil
    destroy()
    DL.dui.release(LEASE)
    Core.NotifyL(arrived and 'common.waypoint_arrived' or 'common.waypoint_cleared', arrived and 'success' or 'inform', label)
end

local function draw()
    local token = marked
    while marked == token do
        local distance = #(GetEntityCoords(cache.ped) - marked.coords)
        if distance <= cfg.ArriveDistance or GetGameTimer() > marked.expires then return finish(distance <= cfg.ArriveDistance) end
        if ready and (cfg.DrawDistance <= 0 or distance <= cfg.DrawDistance) then
            push(marked.label, marked.kind, math.floor(distance))
            SetDrawOrigin(marked.coords.x, marked.coords.y, marked.coords.z + cfg.Height, 0)
            DrawSprite(txd, 'label', 0.0, 0.0, cfg.ScreenWidth, cfg.ScreenWidth * (HEIGHT / WIDTH) * GetAspectRatio(false), 0.0, 255, 255, 255, 255)
            ClearDrawOrigin()
        end
        Wait(0)
    end
end

-- Marks a spot ({x, y, z} at ground level); id lets the caller toggle the same marker off. gps also sets the map route.
-- kind picks the sign's pictogram: 'classroom', 'teacher', 'incident' or a plain pin.
function Core.Waypoint.mark(label, coords, id, gps, kind)
    if marked and id and marked.id == id then return finish(false) end
    marked = { id = id, label = label, kind = kind, coords = vector3(coords.x + 0.0, coords.y + 0.0, coords.z + 0.0), expires = GetGameTimer() + cfg.Minutes * 60000 }
    lastLabel, lastDistance = nil, -1
    ensure()
    if gps then SetNewWaypoint(coords.x, coords.y) end
    CreateThread(draw)
    Core.NotifyL('common.waypoint_set', 'success', label)
end

function Core.Waypoint.clear() finish(false) end
function Core.Waypoint.marked() return marked and marked.id end

AddEventHandler('onResourceStop', function(resource)
    if resource == cache.resource then destroy() end
end)
