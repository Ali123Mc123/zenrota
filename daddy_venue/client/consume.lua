RegisterNetEvent('daddy_venue:consume', function(kind, label)
    local ok = lib.progressBar({
        duration = kind.time, label = label, useWhileDead = false, canCancel = true,
        disable = { car = false, combat = true },
        anim = kind.anim, prop = kind.prop,
    })
    TriggerServerEvent('daddy_venue:consumed', ok == true)
end)

-- arrows move the prop, page up/down lift it, hold shift to rotate instead, enter copies the values, backspace quits
local tuning = false
local fromAdmin = false

-- DaddyRP: the prop tool of /venueadmin (Places > Prop tuning); the window has closed, it comes back when tuning ends
AddEventHandler('daddy_venue:adminMap', function(body)
    if type(body) ~= 'table' or body.tool ~= 'prop' or tuning then return end
    fromAdmin = true
    CreateThread(function()
        local ok, res = pcall(lib.callback.await, 'daddy_venue:admin', false, 'propTune', { kind = body.kind })
        if not (ok and type(res) == 'table' and res.ok) then
            fromAdmin = false
            lib.notify({ type = 'error', description = L('failed') })
            TriggerEvent('daddy_venue:adminBack', 'adminPlaces')
        end
    end)
end)

local keys = {
    { 172, 2, 1 }, { 173, 2, -1 }, { 174, 1, -1 }, { 175, 1, 1 }, { 10, 3, 1 }, { 11, 3, -1 },
}

RegisterNetEvent('daddy_venue:propTune', function(name, kind)
    if tuning then return end
    tuning = true
    local ped = cache.ped
    lib.requestAnimDict(kind.anim.dict)
    lib.requestModel(kind.prop.model)
    pcall(function() exports['FeloxAC']:CreateObject(joaat(kind.prop.model)) end) --[[FeloxAC:auto]]
    local prop = CreateObject(joaat(kind.prop.model), 0.0, 0.0, 0.0, false, false, false)
    SetModelAsNoLongerNeeded(joaat(kind.prop.model))
    local pos = { kind.prop.pos.x, kind.prop.pos.y, kind.prop.pos.z }
    local rot = { kind.prop.rot.x, kind.prop.rot.y, kind.prop.rot.z }

    local function text()
        return ('pos = vec3(%.3f, %.3f, %.3f), rot = vec3(%.1f, %.1f, %.1f)'):format(pos[1], pos[2], pos[3], rot[1], rot[2], rot[3])
    end
    local function attach()
        AttachEntityToEntity(prop, ped, GetPedBoneIndex(ped, kind.prop.bone), pos[1], pos[2], pos[3], rot[1], rot[2], rot[3], true, true, false, true, 1, true)
        lib.showTextUI(name .. '\n' .. text() .. '\n[←↑→↓ PgUp PgDn] [Shift] [Enter] [Backspace]')
    end
    attach()

    CreateThread(function()
        while tuning do
            if not IsEntityPlayingAnim(ped, kind.anim.dict, kind.anim.clip, 3) then
                TaskPlayAnim(ped, kind.anim.dict, kind.anim.clip, 8.0, 8.0, -1, kind.anim.flag | 1, 0.0, false, false, false)
            end
            for _, key in ipairs({ 172, 173, 174, 175, 10, 11 }) do DisableControlAction(0, key, true) end
            local shift = IsControlPressed(0, 21)
            for _, key in ipairs(keys) do
                if IsDisabledControlJustPressed(0, key[1]) then
                    if shift then rot[key[2]] = rot[key[2]] + key[3] * 5.0 else pos[key[2]] = pos[key[2]] + key[3] * 0.005 end
                    attach()
                end
            end
            if IsControlJustPressed(0, 191) then
                lib.setClipboard(text())
                print(('[daddy_venue] %s: %s'):format(name, text()))
                lib.notify({ type = 'success', description = text() })
                tuning = false
            elseif IsControlJustPressed(0, 177) then
                tuning = false
            end
            Wait(0)
        end
        lib.hideTextUI()
        DeleteEntity(prop)
        StopAnimTask(ped, kind.anim.dict, kind.anim.clip, 1.0)
        RemoveAnimDict(kind.anim.dict)
        if fromAdmin then
            fromAdmin = false
            TriggerEvent('daddy_venue:adminBack', 'adminPlaces')
        end
    end)
end)
