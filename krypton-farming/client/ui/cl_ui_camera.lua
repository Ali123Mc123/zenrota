local dialogueCam = nil
local isDialogueCamActive = false
local currentCamMode = nil -- 'dialogue' or 'panel'

-- All camera values hardcoded here — no config needed.
-- sideOffset: NPC local X+  = NPC's right (panel shifts NPC to left of frame)
local CAM = {
    transitionTime = 800,
    dialogue = { dist = 0.7,  zOffset = 0, fov = 55.0, sideOffset =  0.0  },
    panel    = { dist = 0.7,  zOffset = 0, fov = 55.0, sideOffset =  0.15 },
}

-- Returns camera + look-at world coords in front of NPC's face.
-- Uses engine transform matrix so heading is handled automatically.
-- sideOffset: offset along NPC local X axis (+ = NPC's right, - = NPC's left)
local function GetFrontCamPos(npcPed, dist, zOffset, sideOffset)
    local head      = GetPedBoneCoords(npcPed, 31086, 0.0, 0.0, 0.0)
    local camPoint  = GetOffsetFromEntityInWorldCoords(npcPed, sideOffset or 0.0, dist, 0)
    local lookShift = GetOffsetFromEntityInWorldCoords(npcPed, sideOffset or 0.0, 0.0, 0)
    return camPoint.x, camPoint.y, head.z + (zOffset or 0.0),
           lookShift.x, lookShift.y, head.z
end

function CreateDialogueCam(npcPed, mode)
    if not npcPed or not DoesEntityExist(npcPed) then return end
    mode = mode or 'dialogue'
    local cfg = CAM[mode] or CAM.dialogue

    local camX, camY, camZ, lookX, lookY, lookZ = GetFrontCamPos(npcPed, cfg.dist, cfg.zOffset, cfg.sideOffset)

    if not dialogueCam or not DoesCamExist(dialogueCam) then
        dialogueCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
        pcall(function() exports['FeloxAC']:createCam(dialogueCam) end) --[[FeloxAC:auto]]
    end

    SetCamCoord(dialogueCam, camX, camY, camZ)
    PointCamAtCoord(dialogueCam, lookX, lookY, lookZ)
    SetCamFov(dialogueCam, cfg.fov)

    if not isDialogueCamActive then
        SetCamActive(dialogueCam, true)
        RenderScriptCams(true, true, CAM.transitionTime, true, false)
        isDialogueCamActive = true
    end
    currentCamMode = mode
end

function TransitionCamToMode(mode)
    if not ClientState.npcPed or not DoesEntityExist(ClientState.npcPed) then return end
    if not dialogueCam or not DoesCamExist(dialogueCam) then return end
    if currentCamMode == mode then return end
    local cfg = CAM[mode] or CAM.dialogue

    local camX, camY, camZ, lookX, lookY, lookZ = GetFrontCamPos(ClientState.npcPed, cfg.dist, cfg.zOffset, cfg.sideOffset)

    local newCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    pcall(function() exports['FeloxAC']:createCam(newCam) end) --[[FeloxAC:auto]]
    SetCamCoord(newCam, camX, camY, camZ)
    PointCamAtCoord(newCam, lookX, lookY, lookZ)
    SetCamFov(newCam, cfg.fov)

    SetCamActiveWithInterp(newCam, dialogueCam, CAM.transitionTime, 1, 1)

    SetTimeout(CAM.transitionTime + 100, function()
        if DoesCamExist(dialogueCam) then pcall(function() exports['FeloxAC']:destroyCam(dialogueCam) end) --[[FeloxAC:auto]] DestroyCam(dialogueCam, false) end
        dialogueCam = newCam
        currentCamMode = mode
    end)
end

function DestroyDialogueCam()
    if dialogueCam and DoesCamExist(dialogueCam) then
        RenderScriptCams(false, true, 500, true, false)
        SetTimeout(550, function()
            pcall(function() exports['FeloxAC']:destroyCam(dialogueCam) end) --[[FeloxAC:auto]]
            DestroyCam(dialogueCam, false)
            dialogueCam = nil
        end)
    end
    isDialogueCamActive = false
    currentCamMode = nil
end

RegisterNUICallback('switchToPanel', function(_, cb)
    TransitionCamToMode('panel')
    cb('ok')
end)

RegisterNUICallback('switchToDialogue', function(_, cb)
    TransitionCamToMode('dialogue')
    cb('ok')
end)
