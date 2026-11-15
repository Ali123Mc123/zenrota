-- Club logos on the stands: a thin disc prop sits on an open stand's banner and on its cloth (daddy_schoolprops has 12
-- copies of each disc, the slots). Each player gives the logo stands near them a slot of their own, fills the slot's
-- four runtime textures (256, 128, 64 and a soft 64 px, made by College's NUI) with the logo, points the slot's disc
-- models at them and puts the discs on the parents the world spawns. Pictures come from ClubLogos (logocache.lua), once
-- per revision. Nothing runs per frame: the work is when a stand, its logo or its parents change.
if not Core.ModuleEnabled('affairs') then return end

local cfg = Config.Affairs.Club.Logo or {}
local names = ((Config.Affairs.Club.Table or {}).Models or {}).logo or {}
local SLOTS = math.max(1, math.min(32, math.floor(tonumber(cfg.Slots) or 12)))
local SIZES = { 256, 128, 64, 64 } -- every level at least 64 px: a smaller texture's rows are padded and the picture is never written
local STEAL = 5.0 -- a stand takes the farthest stand's slot only when it is this much nearer

StandLogos = {}

local stands = {} -- uid -> { key, clubId, logo, sample, parents = { [part] = { entity, colour } }, discs = { [part] = entity }, slot }
local slots = {} -- n -> { uid, key (the picture in it), full (all four levels written), textures, written, freed }
for n = 1, SLOTS do slots[n] = { written = {}, freed = 0 } end
local txd, txdName
local made, replaced, failed = 0, {}, {} -- runtime textures made; disc models pointed at slots; key -> try again after

local function keyOf(state)
    if type(state.sample) == 'string' then return 'sample:' .. state.sample end
    local clubId, rev = tonumber(state.clubId), tonumber(state.logo) or 0
    return clubId and rev > 0 and ('%d:%d'):format(clubId, rev) or nil
end

local function discModel(part, n, colour)
    local pattern = names[part]
    if not pattern then return nil end
    return part == 'cloth' and pattern:format(colour, n) or pattern:format(n)
end

local function remove(entity) if entity and DoesEntityExist(entity) then DeleteEntity(entity) end end

-- Metres from the player to the stand's nearest parent.
local function distanceOf(st)
    local here, best = GetEntityCoords(cache.ped), math.huge
    for _, parent in pairs(st.parents) do
        if DoesEntityExist(parent.entity) then best = math.min(best, #(here - GetEntityCoords(parent.entity))) end
    end
    return best
end

-- Discs off and the slot free; its picture stays in it for a stand that comes back.
local function unbind(st)
    for part, disc in pairs(st.discs) do
        remove(disc)
        st.discs[part] = nil
    end
    if st.slot then
        slots[st.slot].uid, slots[st.slot].freed = nil, GetGameTimer()
        st.slot = nil
    end
end

-- A slot for the stand: its own, a free one that already holds its picture, a never used one, the longest free one,
-- or the farthest stand's when that one is STEAL metres farther (its discs go).
local function claim(uid, st)
    if st.slot then return st.slot end
    local pick, fresh, oldest
    for n = 1, SLOTS do
        local slot = slots[n]
        if not slot.uid then
            if slot.key == st.key then pick = n break end
            if not slot.key then fresh = fresh or n
            elseif not oldest or slot.freed < slots[oldest].freed then oldest = n end
        end
    end
    pick = pick or fresh or oldest
    if not pick then
        local mine, far, farthest = distanceOf(st), nil, -1
        for _, other in pairs(stands) do
            local d = other.slot and distanceOf(other) or -1
            if d > farthest then far, farthest = other, d end
        end
        if not far or farthest < mine + STEAL then return nil end
        pick = far.slot
        unbind(far)
    end
    slots[pick].uid, st.slot = uid, pick
    return pick
end

-- The picture of a stand: its club's live logo (ClubLogos) or a test kit sample from web/dist/testlogos.
local function picture(st)
    if st.sample then
        local data = LoadResourceFile(cache.resource, ('web/dist/testlogos/%s.txt'):format(st.sample))
        return data and (data:gsub('%s+$', '')), not data and 'logo_gone' or nil
    end
    local data = ClubLogos and ClubLogos.get(st.clubId, st.logo)
    return data, not data and 'logo_gone' or nil
end

-- The four levels from College's NUI (canvas halvings on the logo background), or nil.
local leveling = {}
local function levels(key, data)
    local p = promise.new()
    leveling[key] = p
    SendNUIMessage({ action = 'clubLogo:levels', data = { key = key, image = data, bg = cfg.Background or '#e5ded0', numbered = key == 'sample:levels' } })
    SetTimeout(10000, function()
        if leveling[key] ~= p then return end
        leveling[key] = nil
        p:resolve(false)
    end)
    return Citizen.Await(p) or nil
end

RegisterNUICallback('clubLogo:levels', function(data, cb)
    cb({ ok = true })
    local p = type(data) == 'table' and leveling[data.key]
    if not p then return end
    leveling[data.key] = nil
    p:resolve(type(data.levels) == 'table' and #data.levels == 4 and data.levels or false)
end)

-- Slot n's textures sNN_0..3 in this session's runtime dictionary (made on first use, then reused).
local function texturesOf(n)
    local slot = slots[n]
    if slot.textures then return slot.textures end
    if not txd then
        txdName = ('daddy_college_logo_%d'):format(GetGameTimer()) -- a new name each start: a dictionary never takes a name twice
        txd = CreateRuntimeTxd(txdName)
    end
    slot.textures = {}
    for k = 0, 3 do
        slot.textures[k] = CreateRuntimeTexture(txd, ('s%02d_%d'):format(n, k), SIZES[k + 1], SIZES[k + 1])
        made = made + 1
    end
    return slot.textures
end

local function write(n, list)
    local textures, slot, full = texturesOf(n), slots[n], true
    for k = 0, 3 do
        slot.written[k] = SetRuntimeTextureImage(textures[k], list[k + 1]) == true
        full = full and slot.written[k]
    end
    if not full then print(('^3[daddy_college] club logo: slot %d took only some of its levels (/clublogodebug)^7'):format(n)) end
    return full
end

-- The slot's disc on one parent, at the parent's place and turn; the disc model's textures point at the slot first, in
-- the same tick, so its first frame shows the logo. Waits only for the model.
local function putDisc(uid, st, part)
    local parent, n = st.parents[part], st.slot
    if not parent or not n or st.discs[part] or slots[n].key ~= st.key or not slots[n].full then return end
    local model = discModel(part, n, parent.colour)
    local hash = model and joaat(model)
    if not hash or not IsModelInCdimage(hash) then return end
    if not HasModelLoaded(hash) and not pcall(lib.requestModel, hash, 5000) then return end
    if stands[uid] ~= st or st.parents[part] ~= parent or st.slot ~= n or st.discs[part] or slots[n].key ~= st.key or not DoesEntityExist(parent.entity) then
        return SetModelAsNoLongerNeeded(hash)
    end
    for k = 0, 3 do AddReplaceTexture(model, ('club_logo_%d'):format(k), txdName, ('s%02d_%d'):format(n, k)) end
    replaced[model] = true
    local at = GetEntityCoords(parent.entity)
    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local disc = CreateObjectNoOffset(hash, at.x, at.y, at.z, false, false, false)
    SetModelAsNoLongerNeeded(hash)
    SetEntityCollision(disc, false, false)
    AttachEntityToEntity(disc, parent.entity, 0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 2, true)
    st.discs[part] = disc
end

-- One stand: a slot, its picture written in it (unless it holds it already), its discs on.
local function fill(uid, st)
    local n = claim(uid, st)
    if not n then return end
    local slot, key = slots[n], st.key
    if slot.key ~= key or not slot.full then
        local data, why = picture(st)
        local list = data and levels(key, data)
        if stands[uid] ~= st or st.key ~= key or st.slot ~= n then return end
        if not list then
            failed[key] = GetGameTimer() + (why and 60000 or 10000)
            return unbind(st)
        end
        slot.key, slot.full = key, write(n, list)
        if not slot.full then
            failed[key] = GetGameTimer() + 60000
            return unbind(st)
        end
    end
    for _, part in ipairs({ 'banner', 'cloth' }) do putDisc(uid, st, part) end -- not pairs: a parent may come or go while a model loads
end

-- Whether a stand needs work: a logo, a parent up, and no slot holding its picture or a parent without its disc.
local function needy(st)
    if not st.key or not next(st.parents) then return false end
    local slot = st.slot and slots[st.slot]
    if not slot or slot.key ~= st.key or not slot.full then return true end
    for part in pairs(st.parents) do
        if not st.discs[part] then return true end
    end
    return false
end

-- The needy stands, nearest first, one at a time on one thread.
local working = false
local function pump()
    if working then return end
    working = true
    CreateThread(function()
        local list, now = {}, GetGameTimer()
        for uid, st in pairs(stands) do
            if needy(st) and (failed[st.key] or 0) <= now then list[#list + 1] = { uid = uid, st = st, d = distanceOf(st) } end
        end
        table.sort(list, function(a, b) return a.d < b.d end)
        for _, job in ipairs(list) do
            if stands[job.uid] == job.st then
                local ok, err = pcall(fill, job.uid, job.st)
                if not ok then print(('^1[daddy_college] club logo: %s^7'):format(err)) end
            end
        end
        working = false
    end)
end

-- While a logo stand near the player waits (the slots are taken by nearer ones, a picture failed), look again now and
-- then: walking on, the nearest ones take the slots.
local watching = false
local function watch()
    if watching then return end
    watching = true
    CreateThread(function()
        while true do
            Wait(1500)
            local waiting = false
            for _, st in pairs(stands) do waiting = waiting or needy(st) end
            if not waiting then break end
            pump()
        end
        watching = false
    end)
end

-- The open stands (GlobalState daddy_college:clubTables), before the world places their props: a new logo is written
-- into the stand's own slot in place (its discs stay), a logo taken off takes its discs off.
local present -- the disc props are in the game (daddy_schoolprops with the logo discs); else no world logos at all
function StandLogos.sync(open)
    for uid, st in pairs(stands) do
        if not open[uid] then
            unbind(st)
            stands[uid] = nil
        end
    end
    if not present then present = names.banner ~= nil and IsModelInCdimage(joaat(names.banner:format(1))) end
    if cfg.Enabled == false or not present then return end
    for uid, state in pairs(open) do
        local st = stands[uid]
        if not st then
            st = { parents = {}, discs = {} }
            stands[uid] = st
        end
        local key = keyOf(state)
        st.clubId, st.logo, st.sample = tonumber(state.clubId), tonumber(state.logo) or 0, state.sample
        if st.key ~= key then
            st.key = key
            if not key then unbind(st) end
        end
    end
    pump()
    watch()
end

-- The world's hooks for a stand's banner or cloth (part); colour picks the cloth's disc.
function StandLogos.hooks(uid, part, colour)
    return {
        onSpawn = function(_, entity)
            local st = stands[uid]
            if not st or not entity then return end
            remove(st.discs[part])
            st.discs[part] = nil
            st.parents[part] = { entity = entity, colour = colour }
            pump()
            watch()
        end,
        onDespawn = function(_, entity)
            local st = stands[uid]
            local parent = st and st.parents[part]
            if not parent or parent.entity ~= entity then return end
            st.parents[part] = nil
            remove(st.discs[part])
            st.discs[part] = nil
            if not next(st.parents) then unbind(st) end
        end,
    }
end

-- /clublogodebug: the slot table and PASS or FAIL (every logo stand with a slot has a disc on each parent, each disc
-- sits on its parent within 1 mm and 0.1 degrees, no slot taken twice, no more runtime textures than slots x 4).
RegisterCommand('clublogodebug', function()
    local pass, held = true, {}
    local function fail(text)
        pass = false
        print('^1[clublogo] FAIL ' .. text .. '^7')
    end
    print(('[clublogo] dictionary %s, %d runtime textures (most %d), %d slots'):format(txdName or '-', made, SLOTS * 4, SLOTS))
    for n = 1, SLOTS do
        local slot = slots[n]
        local st = slot.uid and stands[slot.uid]
        local levels, discs = 0, {}
        for k = 0, 3 do levels = levels + (slot.written[k] and 1 or 0) end
        for part, disc in pairs(st and st.discs or {}) do discs[#discs + 1] = part .. (DoesEntityExist(disc) and '' or '(gone)') end
        if slot.uid or slot.key then
            print(('[clublogo] s%02d  stand %s  logo %s  levels %d/4  discs %s  %s'):format(n, slot.uid or '-', slot.key or '-', levels,
                #discs > 0 and table.concat(discs, ',') or '-', st and ('%.1f m'):format(distanceOf(st)) or 'free'))
        end
    end
    for uid, st in pairs(stands) do
        if st.slot then
            if held[st.slot] then fail(('slot %d held by %s and %s'):format(st.slot, held[st.slot], uid)) end
            held[st.slot] = uid
        end
        if st.key and st.slot and slots[st.slot].key == st.key and slots[st.slot].full then
            for part, parent in pairs(st.parents) do
                local disc = st.discs[part]
                if not disc or not DoesEntityExist(disc) then
                    fail(('%s %s has no disc'):format(uid, part))
                elseif DoesEntityExist(parent.entity) then
                    local moved = #(GetEntityCoords(disc) - GetEntityCoords(parent.entity))
                    local a, b, turned = GetEntityRotation(disc, 2), GetEntityRotation(parent.entity, 2), 0.0
                    for _, axis in ipairs({ 'x', 'y', 'z' }) do turned = math.max(turned, math.abs((a[axis] - b[axis] + 180.0) % 360.0 - 180.0)) end
                    if moved > 0.001 or turned > 0.1 then fail(('%s %s disc off its parent by %.4f m, %.3f deg'):format(uid, part, moved, turned)) end
                end
            end
        elseif st.key and next(st.parents) then
            print(('[clublogo] wait %s  logo %s  (%s)'):format(uid, st.key, (failed[st.key] or 0) > GetGameTimer() and 'picture failed, tried again soon' or 'no free slot'))
        end
    end
    if made > SLOTS * 4 then fail(('%d runtime textures made'):format(made)) end
    print(pass and '^2[clublogo] PASS^7' or '^1[clublogo] FAIL^7')
    Core.NotifyL('clubs.logo_debug', pass and 'success' or 'error', pass and 'PASS' or 'FAIL')
end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= cache.resource then return end
    for _, st in pairs(stands) do
        for _, disc in pairs(st.discs) do remove(disc) end
    end
    for model in pairs(replaced) do
        for k = 0, 3 do RemoveReplaceTexture(model, ('club_logo_%d'):format(k)) end
    end
    for key, p in pairs(leveling) do
        leveling[key] = nil
        p:resolve(false)
    end
end)
