-- Shows the layouts that are on: interior sets of the school and map files of the campus.

local ipls = {}  -- map files this script asked for
local tries = {} -- per set: how often it was put the same way without the game agreeing

local function interior()
    local id = GetInteriorAtCoords(Config.Interior.x, Config.Interior.y, Config.Interior.z)
    return id ~= 0 and IsValidInterior(id) and id or nil
end

-- The native answers 1 or false, never true.
local function active(id, set)
    local answer = IsInteriorEntitySetActive(id, set)
    return answer == true or answer == 1
end

local function wanted()
    local layouts = GlobalState.daddySchoolLayouts or {}
    local sets = {}
    for _, name in ipairs(Config.DefaultSets) do sets[name] = true end
    for name, layout in pairs(Config.Layouts) do
        local on = layouts[name] == true
        for _, set in ipairs(layout.on or {}) do sets[set] = on end
        if on then
            for _, set in ipairs(layout.off or {}) do sets[set] = false end
        end
        if layout.ipl and ipls[layout.ipl] ~= on then
            if on then RequestIpl(layout.ipl) else RemoveIpl(layout.ipl) end
            ipls[layout.ipl] = on
        end
    end
    return sets
end

-- Puts the sets right. The interior is rebuilt only when a set really changed.
local function apply()
    local sets = wanted()
    local id = interior()
    if not id then return false end
    local changed = false
    for set, on in pairs(sets) do
        if active(id, set) == on then
            tries[set] = nil
        else
            local try = tries[set]
            if not try or try.on ~= on then
                try = { on = on, count = 0 }
                tries[set] = try
            end
            if try.count < Config.Tries then -- a set the game does not know is not asked for over and over
                if on then ActivateInteriorEntitySet(id, set) else DeactivateInteriorEntitySet(id, set) end
                try.count = try.count + 1
                changed = true
            end
        end
    end
    if changed then RefreshInterior(id) end
    return true
end

AddStateBagChangeHandler('daddySchoolLayouts', 'global', function() SetTimeout(0, apply) end)

-- The interior exists only near the school: keep trying until it is there, then look again now and then
-- (the game puts the sets back to their defaults when it loads the interior anew).
CreateThread(function()
    while true do
        local near = #(GetEntityCoords(PlayerPedId()) - Config.Interior) < Config.Reach
        local done = near and apply()
        Wait(done and 15000 or near and 1000 or 5000)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for ipl, on in pairs(ipls) do
        if on then RemoveIpl(ipl) end
    end
end)

-- Passages: two places joined by a fade (the cellar's tunnel door and the culvert outside the fence).
local ends = {} -- every end of every passage: where it is, where it leads, what it says
for _, passage in ipairs(Config.Passages or {}) do
    ends[#ends + 1] = { at = vec3(passage.a.x, passage.a.y, passage.a.z), to = passage.b, text = passage.textA }
    ends[#ends + 1] = { at = vec3(passage.b.x, passage.b.y, passage.b.z), to = passage.a, text = passage.textB }
end

-- Stands the ped at the far end and holds it until the ground is there (a far place may not be loaded yet).
local function pass(to)
    local ped = PlayerPedId()
    DoScreenFadeOut(Config.PassageFade)
    while not IsScreenFadedOut() do Wait(0) end
    FreezeEntityPosition(ped, true)
    SetEntityCoordsNoOffset(ped, to.x, to.y, to.z, false, false, false)
    SetEntityHeading(ped, to.w)
    RequestCollisionAtCoord(to.x, to.y, to.z)
    local room = GetInteriorAtCoords(to.x, to.y, to.z)
    local limit = GetGameTimer() + 6000
    while GetGameTimer() < limit and not (HasCollisionLoadedAroundEntity(ped) and (room == 0 or IsInteriorReady(room))) do Wait(50) end
    FreezeEntityPosition(ped, false)
    SetGameplayCamRelativeHeading(0.0)
    Wait(300)
    DoScreenFadeIn(Config.PassageFade)
end

if #ends > 0 then
    CreateThread(function()
        while true do
            local wait = 1500
            local ped = PlayerPedId()
            if not IsPedInAnyVehicle(ped, false) and not IsEntityDead(ped) then
                local at = GetEntityCoords(ped)
                for _, e in ipairs(ends) do
                    local far = #(at - e.at)
                    if far < Config.PassageReach then
                        wait = 0
                        BeginTextCommandDisplayHelp('STRING')
                        AddTextComponentSubstringPlayerName(e.text)
                        EndTextCommandDisplayHelp(0, false, true, -1)
                        if IsControlJustReleased(0, 51) then pass(e.to) end -- the key the text names
                        break
                    elseif far < 25.0 and wait > 300 then
                        wait = 300
                    end
                end
            end
            Wait(wait)
        end
    end)
end
