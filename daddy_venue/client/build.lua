-- The build menu (hammer button of the business window, Build in the admin window): the owner (or a member with the build permission) places, moves and removes objects inside the own place.
-- Whatever is shown here is only a preview, the server checks every spot again.

local KEY = { place = 191, cancel = 177, up = 172, down = 173, left = 174, right = 175, scrollUp = 241, scrollDown = 242, fine = 21 }
local REACH = 12.0

local known = { forbidden = true, locked = true, open = true, limit = true, no_funds = true, invalid = true, busy = true, not_found = true, taken = true }

local building = false
-- every build menu ends the build flow when it is closed with ESC, not only the top one (ox_lib only calls the onExit
-- of the menu that is open), otherwise the build menu stays dead after ESC in a sub menu
local function stop() building = false end

local function fail(error)
    lib.notify({ type = 'error', description = known[error] and L('err_' .. error) or L('failed') })
end

local function aim(ignore)
    local origin = GetFinalRenderedCamCoord()
    local rotation = GetFinalRenderedCamRot(2)
    local rx, rz = math.rad(rotation.x), math.rad(rotation.z)
    local flat = math.abs(math.cos(rx))
    local target = origin + vec3(-math.sin(rz) * flat, math.cos(rz) * flat, math.sin(rx)) * REACH
    local ray = StartExpensiveSynchronousShapeTestLosProbe(origin.x, origin.y, origin.z, target.x, target.y, target.z, 17, ignore, 4)
    local _, hit, at, _, entity = GetShapeTestResult(ray)
    if hit ~= 1 then return nil end
    return at, entity
end

local function blockControls()
    for _, control in ipairs({ 24, 25, 14, 15, 37, 99, 100, 261, 262, 140, 141, 142, 257 }) do DisableControlAction(0, control, true) end
end

-- The preview follows the camera. Returns the spot when the owner confirms, nil when cancelled.
local function pick(state, def, from)
    local hash = joaat(def.model)
    if not IsModelInCdimage(hash) then
        lib.notify({ type = 'error', description = L('model_missing', def.model) })
        return nil
    end
    lib.requestModel(hash, 5000)
    local lowest = GetModelDimensions(hash).z

    local me = GetEntityCoords(cache.ped)
    local fwd = GetEntityForwardVector(cache.ped)
    local spot = from and vec3(from.x, from.y, from.z) or vec3(me.x + fwd.x * 2.0, me.y + fwd.y * 2.0, me.z - 1.0 - lowest)
    local heading, lift = from and from.h or GetEntityHeading(cache.ped), 0.0

    pcall(function() exports['FeloxAC']:CreateObject(hash) end) --[[FeloxAC:auto]]
    local ghost = CreateObject(hash, spot.x, spot.y, spot.z, false, false, false)
    SetEntityCollision(ghost, false, false)
    SetEntityAlpha(ghost, 170, false)
    FreezeEntityPosition(ghost, true)
    SetModelAsNoLongerNeeded(hash)

    lib.showTextUI(L('build_help'))
    local result
    while true do
        Wait(0)
        blockControls()
        local hit = aim(ghost)
        if hit then spot = vec3(hit.x, hit.y, hit.z - lowest) end
        local step = IsControlPressed(0, KEY.fine) and 0.01 or 0.05
        if IsControlPressed(0, KEY.up) then lift = lift + step end
        if IsControlPressed(0, KEY.down) then lift = lift - step end
        if IsControlPressed(0, KEY.left) then heading = (heading + (IsControlPressed(0, KEY.fine) and 0.5 or 2.0)) % 360 end
        if IsControlPressed(0, KEY.right) then heading = (heading - (IsControlPressed(0, KEY.fine) and 0.5 or 2.0)) % 360 end
        if IsControlJustPressed(0, KEY.scrollUp) then heading = (heading + 15.0) % 360 end
        if IsControlJustPressed(0, KEY.scrollDown) then heading = (heading - 15.0) % 360 end

        local x, y, z = spot.x, spot.y, spot.z + lift
        SetEntityCoordsNoOffset(ghost, x, y, z, false, false, false)
        SetEntityHeading(ghost, heading)
        local valid = Venue.inPlace(state.place, x, y, z + lowest) and #(GetEntityCoords(cache.ped) - vec3(x, y, z)) <= 30.0
        SetEntityDrawOutline(ghost, true)
        if valid then SetEntityDrawOutlineColor(61, 220, 151, 255) else SetEntityDrawOutlineColor(229, 36, 59, 255) end

        if IsControlJustPressed(0, KEY.cancel) then break end
        if IsControlJustPressed(0, KEY.place) then
            if valid then
                result = { x = x, y = y, z = z, h = heading }
                break
            end
            lib.notify({ type = 'error', description = L('err_invalid') })
        end
    end
    lib.hideTextUI()
    DeleteEntity(ghost)
    return result
end

local menu

local function price(entry)
    if entry.freeLeft and entry.freeLeft > 0 then return L('build_free', entry.freeLeft) end
    return Config.Currency .. entry.price
end

local function crosshair()
    DrawRect(0.5, 0.5, 0.0045, 0.008, 0, 0, 0, 200)
    DrawRect(0.5, 0.5, 0.0025, 0.0045, 255, 255, 255, 255)
end

local function tag(at, text)
    SetDrawOrigin(at.x, at.y, at.z, 0)
    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
end

-- the edges of the model box of an entity, returns the point just above it
local EDGES = { { 1, 2 }, { 3, 4 }, { 5, 6 }, { 7, 8 }, { 1, 3 }, { 2, 4 }, { 5, 7 }, { 6, 8 }, { 1, 5 }, { 2, 6 }, { 3, 7 }, { 4, 8 } }
local function box(entity, r, g, b)
    local min, max = GetModelDimensions(GetEntityModel(entity))
    local p = {}
    for _, x in ipairs({ min.x, max.x }) do
        for _, y in ipairs({ min.y, max.y }) do
            for _, z in ipairs({ min.z, max.z }) do p[#p + 1] = GetOffsetFromEntityInWorldCoords(entity, x, y, z) end
        end
    end
    for _, edge in ipairs(EDGES) do
        local a, c = p[edge[1]], p[edge[2]]
        DrawLine(a.x, a.y, a.z, c.x, c.y, c.z, r, g, b, 255)
    end
    return GetOffsetFromEntityInWorldCoords(entity, 0.0, 0.0, max.z + 0.3)
end

-- the prop under the crosshair: what the ray hits, or the closest prop to that point, map collisions often cover props
local function propAt(at, entity)
    if entity and entity ~= 0 and GetEntityType(entity) == 3 and not Venue.Local.owns(entity) then return entity end
    local best, bestDistance
    local owned = Venue.Local.ownedTest()
    for _, object in ipairs(GetGamePool('CObject')) do
        -- the cheap distance test first, the ownership test only for the few props close to the point
        local distance = #(GetEntityCoords(object) - at)
        if distance < 1.5 and (not bestDistance or distance < bestDistance) and IsEntityVisible(object) and not owned(object) then
            best, bestDistance = object, distance
        end
    end
    return best
end

-- aim at a prop of the map; returns { entity } when the owner confirms
local function pickEntity(state)
    lib.showTextUI(L('pick_help'))
    local chosen, marked, nextScan = nil, nil, 0
    while true do
        Wait(0)
        blockControls()
        crosshair()
        local at, entity = aim(cache.ped)
        if at and (GetGameTimer() >= nextScan or (entity and entity ~= marked and GetEntityType(entity) == 3)) then
            marked = propAt(at, entity)
            nextScan = GetGameTimer() + 150
        elseif not at then
            marked = nil
        end
        local valid = false
        if marked and DoesEntityExist(marked) then
            local c = GetEntityCoords(marked)
            valid = Venue.inPlace(state.place, c.x, c.y, c.z)
            local top = valid and box(marked, 61, 220, 151) or box(marked, 229, 36, 59)
            tag(top, valid and L('pick_enter') or L('pick_outside'))
        end
        if IsControlJustPressed(0, KEY.cancel) then break end
        if IsControlJustPressed(0, KEY.place) then
            if valid then chosen = { entity = marked } break end
            lib.notify({ type = 'error', description = L('pick_none') })
        end
    end
    lib.hideTextUI()
    return chosen
end

-- a spot on any surface, no prop at all; returns { x, y, z, h }
local function pickSpot(state)
    lib.showTextUI(L('spot_help'))
    local chosen
    while true do
        Wait(0)
        blockControls()
        crosshair()
        local at = aim(cache.ped)
        local valid = at and Venue.inPlace(state.place, at.x, at.y, at.z + 0.05)
        if at then
            local r, g, b = 61, 220, 151
            if not valid then r, g, b = 229, 36, 59 end
            DrawMarker(28, at.x, at.y, at.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.12, 0.12, 0.12, r, g, b, 220, false, false, 2, false, nil, nil, false)
            DrawMarker(2, at.x, at.y, at.z + 0.9, 0.0, 0.0, 0.0, 180.0, 0.0, 0.0, 0.25, 0.25, 0.25, r, g, b, 160, false, true, 2, false, nil, nil, false)
            tag(vec3(at.x, at.y, at.z + 1.25), valid and L('pick_enter') or L('pick_outside'))
        end
        if IsControlJustPressed(0, KEY.cancel) then break end
        if IsControlJustPressed(0, KEY.place) then
            if valid then
                -- facing the player, so a screen on a wall looks at the room
                chosen = { x = at.x, y = at.y, z = at.z + 0.05, h = (GetGameplayCamRot(2).z + 180.0) % 360 }
                break
            end
            lib.notify({ type = 'error', description = L('pick_none') })
        end
    end
    lib.hideTextUI()
    return chosen
end

local function assign(target, entry)
    local body = { type = entry.type, existing = true, model = 0 }
    if target.entity then
        local c = GetEntityCoords(target.entity)
        body.model, body.x, body.y, body.z, body.h = GetEntityModel(target.entity), c.x, c.y, c.z, GetEntityHeading(target.entity)
    else
        body.x, body.y, body.z, body.h = target.x, target.y, target.z, target.h
    end
    local res = lib.callback.await('daddy_venue:objectPlace', false, body)
    if not (res and res.ok) then fail(res and res.error) end
end

local function useExisting(state)
    local target = pickEntity(state)
    if not target then return menu() end
    local list = {}
    for _, entry in ipairs(state.catalog) do
        list[#list + 1] = {
            title = Venue.objectName(entry.type), icon = (entry.icon:gsub('^fa%-', '')), disabled = entry.count >= entry.max or state.total >= state.place.limit,
            description = ('%s · %d / %d'):format(price(entry), entry.count, entry.max),
            onSelect = function()
                assign(target, entry)
                menu()
            end,
        }
    end
    lib.registerContext({ id = 'daddy_build_pick', title = L('pick_as'), menu = 'daddy_build', onExit = stop, options = list })
    lib.showContext('daddy_build_pick')
end

local function addNew(state, entry)
    local spot = pick(state, entry)
    if spot then
        local res = lib.callback.await('daddy_venue:objectPlace', false, { type = entry.type, decor = entry.key, x = spot.x, y = spot.y, z = spot.z, h = spot.h })
        if not (res and res.ok) then fail(res and res.error) end
    end
    menu()
end

local function edit(state, target)
    local def = Config.Build.Objects[target.type]
    local name = Venue.objectName(target.type)
    local options = {
        { title = L('build_move'), icon = 'arrows-up-down-left-right', onSelect = function()
            local spot = pick(state, { model = target.model }, target)
            if spot then
                local res = lib.callback.await('daddy_venue:objectMove', false, { id = target.id, x = spot.x, y = spot.y, z = spot.z, h = spot.h })
                if not (res and res.ok) then fail(res and res.error) end
            end
            menu()
        end },
        { title = L('build_remove'), description = target.existing and L('build_unassign') or L('build_refund', state.refund), icon = 'trash', onSelect = function()
            if lib.alertDialog({ header = L('build_remove_q', name), content = L('build_undo'), centered = true, cancel = true }) ~= 'confirm' then return menu() end
            local res = lib.callback.await('daddy_venue:objectRemove', false, target.id)
            if not (res and res.ok) then fail(res and res.error) end
            menu()
        end },
    }
    if target.existing then table.remove(options, 1) end
    if def.display then
        options[#options + 1] = { title = L('build_image'), description = L('build_image_desc'), icon = 'image', onSelect = function()
            local current = target.data and target.data ~= '' and json.decode(target.data) or {}
            local fields = {}
            for i = 1, Config.Display.MaxUrls do fields[i] = { type = 'input', label = L('build_image_n', i), default = current[i], description = i == 1 and table.concat(Config.Display.Domains, ', ') or nil } end
            local input = lib.inputDialog(name, fields)
            if input then
                local urls = {}
                for _, url in ipairs(input) do
                    if type(url) == 'string' and url ~= '' then urls[#urls + 1] = url end
                end
                local res = lib.callback.await('daddy_venue:objectImage', false, target.id, urls)
                if not (res and res.ok) then fail(res and res.error) end
            end
            menu()
        end }
    end
    lib.registerContext({ id = 'daddy_build_edit', title = name, menu = 'daddy_build', onExit = stop, options = options })
    lib.showContext('daddy_build_edit')
end

menu = function()
    local state = lib.callback.await('daddy_venue:buildState', false)
    if not (state and state.ok) then
        building = false
        return fail(state and state.error)
    end

    local options = {
        { title = state.place.label, description = L('build_header', state.total, state.place.limit, Config.Currency .. state.funds), icon = 'store', readOnly = true },
    }
    local group
    for _, entry in ipairs(state.catalog) do
        if entry.group ~= group then
            group = entry.group
            options[#options + 1] = { title = group == 'point' and L('build_points') or group == 'display' and L('build_displays') or L('build_stations'), readOnly = true }
        end
        local full = entry.count >= entry.max or state.total >= state.place.limit
        local function put()
            if not state.pick then return addNew(state, entry) end
            lib.registerContext({ id = 'daddy_build_how', title = Venue.objectName(entry.type), menu = 'daddy_build', onExit = stop, options = {
                { title = L('build_new'), description = L('build_new_desc'), icon = 'plus', onSelect = function() addNew(state, entry) end },
                { title = L('build_pick'), description = L('build_pick_one'), icon = 'hand-pointer', onSelect = function()
                    local target = pickEntity(state)
                    if target then assign(target, entry) end
                    menu()
                end },
                { title = L('build_spot'), description = L('build_spot_desc'), icon = 'location-crosshairs', onSelect = function()
                    local target = pickSpot(state)
                    if target then assign(target, entry) end
                    menu()
                end },
            } })
            lib.showContext('daddy_build_how')
        end
        options[#options + 1] = {
            title = Venue.objectName(entry.type), icon = (entry.icon:gsub('^fa%-', '')), disabled = entry.count == 0 and full,
            description = ('%s · %d / %d'):format(price(entry), entry.count, entry.max), arrow = entry.count > 0,
            onSelect = function()
                if entry.count == 0 then return put() end
                -- DaddyRP: a type that is placed already lists its objects here, to move or remove them; a new one only while there is room
                local list = { { title = L('build_new'), description = full and L('build_full') or L('build_new_desc'), icon = 'plus', disabled = full, onSelect = put } }
                for i, item in ipairs(Venue.Local.ofType(state.place.id, entry.type)) do
                    list[#list + 1] = {
                        title = ('%s %d'):format(Venue.objectName(entry.type), i), description = L('build_away', item.distance), icon = 'pen',
                        onSelect = function() edit(state, item.data) end,
                    }
                end
                lib.registerContext({ id = 'daddy_build_type', title = Venue.objectName(entry.type), menu = 'daddy_build', onExit = stop, options = list })
                lib.showContext('daddy_build_type')
            end,
        }
    end
    if state.pick then
        options[#options + 1] = {
            title = L('build_pick'), description = L('build_pick_desc'), icon = 'hand-pointer', disabled = state.total >= state.place.limit,
            onSelect = function() useExisting(state) end,
        }
    end
    options[#options + 1] = {
        title = L('build_decor'), description = state.decorFree > 0 and L('build_decor_free', #state.decor, state.decorFree) or L('build_decor_desc', #state.decor), icon = 'couch', disabled = state.total >= state.place.limit,
        onSelect = function()
            local list = {}
            for _, item in ipairs(state.decor) do
                list[#list + 1] = {
                    title = item.label, description = state.decorFree > 0 and L('build_free', state.decorFree) or Config.Currency .. item.price, icon = 'chair',
                    onSelect = function() addNew(state, { type = 'decor', key = item.key, model = item.model }) end,
                }
            end
            lib.registerContext({ id = 'daddy_build_decor', title = L('build_decor'), menu = 'daddy_build', onExit = stop, options = list })
            lib.showContext('daddy_build_decor')
        end,
    }
    options[#options + 1] = {
        title = L('build_packs'), description = L('build_packs_desc'), icon = 'layer-group',
        onSelect = function()
            local res = lib.callback.await('daddy_venue:packs', false)
            if not (res and res.ok) then return fail(res and res.error) end
            local list = {}
            for _, pack in ipairs(res.packs) do
                list[#list + 1] = {
                    title = pack.label, description = L('build_pack_count', Config.Currency .. pack.price, pack.count), icon = 'layer-group',
                    onSelect = function()
                        if lib.alertDialog({ header = pack.label, content = L('build_pack_warn'), centered = true, cancel = true }) ~= 'confirm' then return menu() end
                        local done = lib.callback.await('daddy_venue:packApply', false, pack.id)
                        if not (done and done.ok) then fail(done and done.error) end
                        menu()
                    end,
                }
            end
            if #list == 0 then list[1] = { title = L('build_no_packs'), readOnly = true } end
            lib.registerContext({ id = 'daddy_build_packs', title = L('build_packs'), menu = 'daddy_build', onExit = stop, options = list })
            lib.showContext('daddy_build_packs')
        end,
    }
    options[#options + 1] = {
        title = L('build_edit'), description = L('build_edit_desc'), icon = 'hand',
        onSelect = function()
            -- DaddyRP: the objects around, the closest first, so the right one is picked even when several stand together
            local list = Venue.Local.near(GetEntityCoords(cache.ped), 10.0)
            if #list == 0 then
                lib.notify({ type = 'inform', description = L('build_none_near') })
                return menu()
            end
            if #list == 1 then return edit(state, list[1].data) end
            local options = {}
            for i, item in ipairs(list) do
                options[i] = {
                    title = Venue.objectName(item.data.type), description = ('%.1f m'):format(item.distance), icon = 'cube',
                    onSelect = function() edit(state, item.data) end,
                }
            end
            lib.registerContext({ id = 'daddy_build_pick', title = L('build_edit'), menu = 'daddy_build', onExit = stop, options = options })
            lib.showContext('daddy_build_pick')
        end,
    }
    lib.registerContext({ id = 'daddy_build', title = L('build_title'), options = options, onExit = stop })
    lib.showContext('daddy_build')
end

function Venue.Local.build()
    if building then return end
    building = true
    menu()
end

