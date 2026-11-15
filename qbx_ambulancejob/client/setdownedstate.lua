local config = require 'config.client'
local sharedConfig = require 'config.shared'
local doctorCount = 0

local useDeathscreen = GetResourceState('krypton-deathscreen') == 'started'

local function getDoctorCount()
    return lib.callback.await('qbx_ambulancejob:server:getNumDoctors')
end

local function getStreetName()
    local coords = GetEntityCoords(cache.ped)
    return GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
end

local function displayRespawnText()
    if useDeathscreen then return end
    local deathTime = exports.qbx_medical:GetDeathTime()
    if deathTime > 0 and doctorCount > 0 then
        qbx.drawText2d({ text = locale('info.respawn_txt', math.ceil(deathTime)), coords = vec2(1.0, 1.44), scale = 0.6 })
    else
        qbx.drawText2d({
            text = locale('info.respawn_revive', exports.qbx_medical:GetRespawnHoldTimeDeprecated(),
                sharedConfig.checkInCost),
            coords = vec2(1.0, 1.44),
            scale = 0.6
        })
    end
end

local function playDeadAnimation(ped)
    if IsInHospitalBed then
        if not IsEntityPlayingAnim(ped, InBedDict, InBedAnim, 3) then
            lib.playAnim(ped, InBedDict, InBedAnim, 1.0, 1.0, -1, 1, 0, false, false, false)
        end
    else
        exports.qbx_medical:PlayDeadAnimation()
    end
end

local function handleDead(ped)
    if not IsInHospitalBed then
        displayRespawnText()
    end
    playDeadAnimation(ped)
end

local function handleRequestingEms()
    if not EmsNotified then
        if not useDeathscreen then
            qbx.drawText2d({ text = locale('info.request_help'), coords = vec2(1.0, 1.40), scale = 0.6 })
        end
        if IsControlJustPressed(0, 47) then
            local street = getStreetName()
            lib.callback.await('hospital:server:ambulanceAlert', false, locale('info.civ_down'), street)
            EmsNotified = true
        end
    elseif not useDeathscreen then
        qbx.drawText2d({ text = locale('info.help_requested'), coords = vec2(1.0, 1.40), scale = 0.6 })
    end
end

-- DaddyRP: the paintball check is an export call into BakiTelli_paintballv2 (its time shows on that resource in
-- resmon); it was made every frame while dead. A match does not start or end within a second, so ask once a second.
local paintballAt, inPaintball = 0, false

local function playingPaintball()
    local now = GetGameTimer()
    if now >= paintballAt then
        paintballAt = now + 1000
        inPaintball = GetResourceState('BakiTelli_paintballv2') == 'started' and exports['BakiTelli_paintballv2']:inGameStatus() or false
    end
    return inPaintball
end

CreateThread(function()
    local lastUpdate = GetGameTimer()
    while true do
        local isDead = exports.qbx_medical:IsDead()
        if isDead and not playingPaintball() then
            handleDead(cache.ped)
            handleRequestingEms()

            local currentTime = GetGameTimer()
            if (currentTime - lastUpdate) > 60000 then
                doctorCount = getDoctorCount()
                lastUpdate = currentTime
            end

            Wait(0)
        else
            Wait(1000)
        end
    end
end)