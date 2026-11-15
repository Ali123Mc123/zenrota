-- Signs and screens: a web page (dui/display.html) drawn as a flat surface in front of the prop. It only exists while you are
-- close, and the page is only asked for new data every few seconds while you look at it.
local counter = 0

-- both faces of the screen, each as seen from its own side: { tl, tr, bl, br }
local function faces(entity)
    local min, max = GetModelDimensions(GetEntityModel(entity))
    local pad = math.min(max.x - min.x, max.z - min.z) * 0.04
    local x1, x2, z1, z2 = min.x + pad, max.x - pad, min.z + pad, max.z - pad
    local front, back = max.y + 0.006, min.y - 0.006
    local function at(x, y, z) return GetOffsetFromEntityInWorldCoords(entity, x, y, z) end
    return {
        { at(x2, front, z2), at(x1, front, z2), at(x2, front, z1), at(x1, front, z1) },
        { at(x1, back, z2), at(x2, back, z2), at(x1, back, z1), at(x2, back, z1) },
    }
end

-- a face is drawn with both windings, the side facing away is hidden by the prop itself
local function draw(face, name)
    local tl, tr, bl, br = face[1], face[2], face[3], face[4]
    DrawSpritePoly(bl.x, bl.y, bl.z, tl.x, tl.y, tl.z, tr.x, tr.y, tr.z, 255, 255, 255, 255, name, 'tex', 0.0, 1.0, 1.0, 0.0, 0.0, 1.0, 1.0, 0.0, 1.0)
    DrawSpritePoly(bl.x, bl.y, bl.z, tr.x, tr.y, tr.z, br.x, br.y, br.z, 255, 255, 255, 255, name, 'tex', 0.0, 1.0, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0)
    DrawSpritePoly(tr.x, tr.y, tr.z, tl.x, tl.y, tl.z, bl.x, bl.y, bl.z, 255, 255, 255, 255, name, 'tex', 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 1.0)
    DrawSpritePoly(br.x, br.y, br.z, tr.x, tr.y, tr.z, bl.x, bl.y, bl.z, 255, 255, 255, 255, name, 'tex', 1.0, 1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 1.0, 1.0)
end

local function corners(data)
    local q = Config.Display.Quad
    local h = math.rad(data.h)
    local forward = vec3(-math.sin(h), math.cos(h), 0.0)
    local right = vec3(math.cos(h), math.sin(h), 0.0)
    local centre = vec3(data.x, data.y, data.z + q.up) + forward * q.out
    local dx, dz = right * (q.w / 2), q.h / 2
    return centre - dx + vec3(0.0, 0.0, dz), centre + dx + vec3(0.0, 0.0, dz), centre - dx - vec3(0.0, 0.0, dz), centre + dx - vec3(0.0, 0.0, dz)
end

function Venue.Local.display(entry, def)
    local data = entry.data
    local urls = data.data and data.data ~= '' and json.decode(data.data) or {}
    local fallback = { { corners(data) } }
    local shape, shapeOf
    local dui, txd, texture, name
    -- every create() gets its own generation: a loop of an older one (left and came back within the 5 s wait) sees
    -- that it is no longer the current one and stops, instead of running next to the new loop
    local generation = 0
    local setupKey

    local function destroy()
        generation = generation + 1
        if dui then DestroyDui(dui) end
        dui, texture, setupKey = nil, nil, nil
    end

    local function refresh(gen)
        local info = lib.callback.await('daddy_venue:queue', false, data.id)
        if not (info and dui) or gen ~= generation then return end
        -- the setup restarts the slideshow, so it only goes again when the name or colour changed
        local key = tostring(info.name) .. '|' .. tostring(info.accent)
        if key ~= setupKey then
            setupKey = key
            SendDuiMessage(dui, json.encode({ type = 'setup', mode = def.display, name = info.name, accent = info.accent, urls = urls, preparing = L('screen_preparing'), ready = L('screen_ready') }))
        end
        if def.display == 'screen' then SendDuiMessage(dui, json.encode({ type = 'queue', orders = info.orders })) end
    end

    local function create()
        destroy()
        local gen = generation
        counter = counter + 1
        local handle = CreateDui('nui://' .. GetCurrentResourceName() .. '/dui/display.html', 1024, 576)
        dui = handle
        local waited = 0
        while gen == generation and not IsDuiAvailable(handle) and waited < 4000 do Wait(50) waited = waited + 50 end
        -- whoever moved the generation on (onExit, a newer create) already destroyed this handle in destroy()
        if gen ~= generation then return end
        name = ('daddy_venue_%d_%d'):format(data.id, counter)
        txd = CreateRuntimeTxd(name)
        texture = 'tex'
        CreateRuntimeTextureFromDuiHandle(txd, texture, GetDuiHandle(dui))
        refresh(gen)
        while gen == generation do
            Wait(5000)
            if gen == generation then refresh(gen) end
        end
    end

    local point = lib.points.new({
        coords = vec3(data.x, data.y, data.z), distance = Config.Display.Distance,
        onEnter = function() CreateThread(create) end,
        onExit = destroy,
        nearby = function(self)
            -- nothing to draw while the screen is behind the camera
            if not texture or not IsSphereVisible(self.coords.x, self.coords.y, self.coords.z, 1.0) then return end
            local entity = entry.entity
            if entity and DoesEntityExist(entity) then
                if shapeOf ~= entity then shape, shapeOf = faces(entity), entity end
            else
                shape, shapeOf = fallback, nil
            end
            for i = 1, #shape do draw(shape[i], name) end
        end,
    })

    return { remove = function() point:remove() destroy() end }
end
