-- Sitting on benches, stumps and chairs; lying in tents, sleeping bags and the hammock. Only for role play.
local defs = Config.Pieces
Rest = { busy = false }

local function free(at)
    for _, ped in ipairs(GetGamePool('CPed')) do
        if ped ~= PlayerPedId() and #(GetEntityCoords(ped) - at) < 0.45 then return false end
    end
    return true
end

-- The free spot of a piece closest to the player, in the world.
local function spot(entity, spots)
    local me, best, bestDistance = GetEntityCoords(PlayerPedId()), nil, math.huge
    for _, s in ipairs(spots) do
        local at = GetOffsetFromEntityInWorldCoords(entity, s.x, s.y, s.z)
        local d = #(at - me)
        if d < bestDistance and free(at) then best, bestDistance = { at = at, h = GetEntityHeading(entity) + s.w }, d end
    end
    return best
end

local function hold(scenario, s, entity)
    local ped = PlayerPedId()
    Rest.busy = true
    SetEntityNoCollisionEntity(ped, entity, true)
    TaskStartScenarioAtPosition(ped, scenario, s.at.x, s.at.y, s.at.z, s.h % 360.0, 0, true, true)
    lib.showTextUI(Client.t('camp.stand_help'))
    while Rest.busy do
        if IsControlJustPressed(0, 73) or IsPedRagdoll(ped) or IsEntityDead(ped) then break end
        Wait(0)
    end
    lib.hideTextUI()
    ClearPedTasks(ped)
    SetEntityNoCollisionEntity(ped, entity, false)
    Rest.busy = false
end

function Rest.sit(id, entity)
    local p = Client.pieces[id]
    local s = p and not Rest.busy and spot(entity, defs[p.key].seats)
    if not s then return Client.notify('camp.seat_taken', 'error') end
    hold('PROP_HUMAN_SEAT_BENCH', s, entity)
end

function Rest.lie(id, entity)
    local p = Client.pieces[id]
    local s = p and not Rest.busy and spot(entity, defs[p.key].lie)
    if not s then return Client.notify('camp.seat_taken', 'error') end
    Client.act(id, 'lie')
    hold('WORLD_HUMAN_SUNBATHE_BACK', s, entity)
end
