-- /camphand <piece> [state]: holds a piece and moves it in the hand with the keys, to find its hand offsets.
-- Debug only. Enter copies the config line for Config.Pieces, Backspace ends.
if not Config.Debug then return end

local KEY = { left = 174, right = 175, up = 172, down = 173, zup = 10, zdown = 11, rotate = 21, fine = 19, copy = 191, done = 177 }
local AXES = { { KEY.left, KEY.right, 'x' }, { KEY.down, KEY.up, 'y' }, { KEY.zdown, KEY.zup, 'z' } }

local function line(h)
    local anim = h.anim and (", anim = { dict = '%s', clip = '%s' }"):format(h.anim.dict, h.anim.clip) or ''
    return ('hand = { bone = %d, pos = vec3(%.3f, %.3f, %.3f), rot = vec3(%.1f, %.1f, %.1f)%s }'):format(h.bone, h.pos.x, h.pos.y, h.pos.z, h.rot.x, h.rot.y, h.rot.z, anim)
end

local function attach(prop, ped, h)
    AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, h.bone), h.pos.x, h.pos.y, h.pos.z, h.rot.x, h.rot.y, h.rot.z, true, true, false, true, 1, true)
end

RegisterCommand('camphand', function(_, args)
    local key = args[1]
    local def = key and Config.Pieces[key]
    if not def or not def.hand then
        local names = {}
        for k, d in pairs(Config.Pieces) do if d.hand then names[#names + 1] = k end end
        return print('camphand <' .. table.concat(names, '|') .. '> [state]')
    end
    local ped = PlayerPedId()
    local h = { bone = def.hand.bone, pos = def.hand.pos, rot = def.hand.rot, anim = def.hand.anim }
    Hand.tune[key] = h
    local prop = Hand.attach(ped, key, args[2] or (def.states and def.states[1]) or 'default')
    if not prop then return end
    -- seen in the pose it is used in: the roasting stick at the fire, a light in its carrying pose
    local anim = key == 'roast_stick' and Config.Cook.Roast.Anim or def.hand.anim
    if anim then
        lib.requestAnimDict(anim.dict)
        TaskPlayAnim(ped, anim.dict, anim.clip, 4.0, -4.0, -1, 49, 0, false, false, false)
    end
    lib.showTextUI('Arrows / PgUp PgDn: move  ·  Shift: rotate  ·  Alt: fine  ·  Enter: copy  ·  Backspace: done')
    while true do
        local rotate, fine = IsControlPressed(0, KEY.rotate), IsControlPressed(0, KEY.fine)
        local step = rotate and (fine and 1.0 or 5.0) or (fine and 0.002 or 0.01)
        for _, a in ipairs(AXES) do
            local d = (IsControlJustPressed(0, a[2]) and step or 0) - (IsControlJustPressed(0, a[1]) and step or 0)
            if d ~= 0 then
                local v = rotate and h.rot or h.pos
                local next = vec3(v.x + (a[3] == 'x' and d or 0), v.y + (a[3] == 'y' and d or 0), v.z + (a[3] == 'z' and d or 0))
                if rotate then h.rot = next else h.pos = next end
                attach(prop, ped, h)
            end
        end
        if IsControlJustPressed(0, KEY.copy) then
            lib.setClipboard(line(h))
            print(key .. ': ' .. line(h))
            lib.notify({ description = key .. ': ' .. line(h), type = 'success' })
        end
        if IsControlJustPressed(0, KEY.done) then break end
        Wait(0)
    end
    lib.hideTextUI()
    if DoesEntityExist(prop) then DeleteEntity(prop) end
    ClearPedSecondaryTask(ped)
end, false)
