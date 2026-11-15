-- The phone's flashlight: a spot light where the player looks, drawn every frame only while it is on and the phone
-- is out; putting the phone away turns it off. Others see it too: the state bag 'phoneLight' tells the other clients,
-- which draw it ahead of that player while they are within 60 m (no loop while no light is on).
local on = false
local others = {} -- server id -> when their light came on, near or out of scope
local drawing = false
local REACH = 60.0

local function ahead()
    local rot = GetGameplayCamRot(2)
    local x, z = math.rad(rot.x), math.rad(rot.z)
    local c = math.abs(math.cos(x))
    return vector3(-math.sin(z) * c, math.cos(z) * c, math.sin(x))
end

local function light(from, dir)
    DrawSpotLight(from.x, from.y, from.z, dir.x, dir.y, dir.z, 255, 250, 235, 30.0, 8.0, 0.0, 26.0, 30.0)
end

local function setOn(value)
    on = value
    LocalPlayer.state:set('phoneLight', value, true)
end

local function shine()
    CreateThread(function()
        while on and PhoneUI.open do
            light(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.25, 0.35), ahead())
            Wait(0)
        end
        if on then
            setOn(false)
            SendNUIMessage({ action = 'flashlight', on = false })
        end
    end)
end

RegisterNUICallback('phone:flashlight', function(data, cb)
    local want = data.on == true
    if want and not on then
        setOn(true)
        shine()
    elseif not want and on then
        setOn(false)
    end
    cb({ ok = true, on = on })
end)

-- Other players' lights, ahead of them and a little down: every frame while one is within reach, else a look every
-- half second for one coming closer. A player who left (no state any more, a second after it came on) drops off.
local function watchOthers()
    if drawing then return end
    drawing = true
    CreateThread(function()
        while next(others) do
            local here, near, now = GetEntityCoords(PlayerPedId()), false, GetGameTimer()
            for id, since in pairs(others) do
                local player = GetPlayerFromServerId(id)
                local ped = player ~= -1 and NetworkIsPlayerActive(player) and GetPlayerPed(player) or 0
                if now - since > 1000 and Player(id).state.phoneLight ~= true then
                    others[id] = nil
                elseif ped ~= 0 and #(GetEntityCoords(ped) - here) < REACH then
                    near = true
                    local fwd = GetEntityForwardVector(ped)
                    light(GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.25, 0.35), vector3(fwd.x, fwd.y, -0.15))
                end
            end
            Wait(near and 0 or 500)
        end
        drawing = false
    end)
end

AddStateBagChangeHandler('phoneLight', nil, function(bagName, _, value)
    local id = tonumber(bagName:match('^player:(%d+)$'))
    if not id or id == GetPlayerServerId(PlayerId()) then return end
    others[id] = value == true and (others[id] or GetGameTimer()) or nil
    if value then watchOthers() end
end)
