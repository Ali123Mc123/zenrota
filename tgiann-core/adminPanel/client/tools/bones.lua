-- tgiann-core admin lib: every ped bone a prop or a player can sit on, and a picker that shows them on the
-- character as dots (click one). Ids are ped bone tags (GetPedBoneIndex).
local Tools = AdminPanel.Tools

---@type { id: integer, label: string }[]
Tools.PED_BONES = {
    { id = 0,     label = "SKEL_ROOT" },
    { id = 11816, label = "SKEL_Pelvis" },
    { id = 57597, label = "SKEL_Spine_Root" },
    { id = 23553, label = "SKEL_Spine0" },
    { id = 24816, label = "SKEL_Spine1" },
    { id = 24817, label = "SKEL_Spine2" },
    { id = 24818, label = "SKEL_Spine3" },
    { id = 39317, label = "SKEL_Neck_1" },
    { id = 35731, label = "RB_Neck_1" },
    { id = 31086, label = "SKEL_Head" },
    { id = 12844, label = "IK_Head" },
    { id = 65068, label = "FACIAL_facialRoot" },
    { id = 46240, label = "FB_Jaw_000" },
    { id = 47495, label = "FB_Tongue_000" },
    { id = 20178, label = "FB_UpperLipRoot_000" },
    { id = 61839, label = "FB_UpperLip_000" },
    { id = 17188, label = "FB_LowerLipRoot_000" },
    { id = 20623, label = "FB_LowerLip_000" },
    { id = 17719, label = "FB_R_Lip_Top_000" },
    { id = 20279, label = "FB_L_Lip_Top_000" },
    { id = 49979, label = "FB_R_Lip_Bot_000" },
    { id = 47419, label = "FB_L_Lip_Bot_000" },
    { id = 11174, label = "FB_R_Lip_Corner_000" },
    { id = 29868, label = "FB_L_Lip_Corner_000" },
    { id = 19336, label = "FB_R_CheekBone_000" },
    { id = 21550, label = "FB_L_CheekBone_000" },
    { id = 27474, label = "FB_R_Eye_000" },
    { id = 25260, label = "FB_L_Eye_000" },
    { id = 43536, label = "FB_R_Lid_Upper_000" },
    { id = 45750, label = "FB_L_Lid_Upper_000" },
    { id = 1356,  label = "FB_R_Brow_Out_000" },
    { id = 58331, label = "FB_L_Brow_Out_000" },
    { id = 37193, label = "FB_Brow_Centre_000" },
    { id = 10706, label = "SKEL_R_Clavicle" },
    { id = 64729, label = "SKEL_L_Clavicle" },
    { id = 40269, label = "SKEL_R_UpperArm" },
    { id = 45509, label = "SKEL_L_UpperArm" },
    { id = 37119, label = "RB_R_ArmRoll" },
    { id = 5232,  label = "RB_L_ArmRoll" },
    { id = 2992,  label = "MH_R_Elbow" },
    { id = 22711, label = "MH_L_Elbow" },
    { id = 28252, label = "SKEL_R_Forearm" },
    { id = 61163, label = "SKEL_L_Forearm" },
    { id = 43810, label = "RB_R_ForeArmRoll" },
    { id = 61007, label = "RB_L_ForeArmRoll" },
    { id = 57005, label = "SKEL_R_Hand" },
    { id = 18905, label = "SKEL_L_Hand" },
    { id = 28422, label = "PH_R_Hand" },
    { id = 60309, label = "PH_L_Hand" },
    { id = 6286,  label = "IK_R_Hand" },
    { id = 36029, label = "IK_L_Hand" },
    { id = 58866, label = "SKEL_R_Finger00" },
    { id = 64016, label = "SKEL_R_Finger01" },
    { id = 64017, label = "SKEL_R_Finger02" },
    { id = 58867, label = "SKEL_R_Finger10" },
    { id = 64096, label = "SKEL_R_Finger11" },
    { id = 64097, label = "SKEL_R_Finger12" },
    { id = 58868, label = "SKEL_R_Finger20" },
    { id = 64112, label = "SKEL_R_Finger21" },
    { id = 64113, label = "SKEL_R_Finger22" },
    { id = 58869, label = "SKEL_R_Finger30" },
    { id = 64064, label = "SKEL_R_Finger31" },
    { id = 64065, label = "SKEL_R_Finger32" },
    { id = 58870, label = "SKEL_R_Finger40" },
    { id = 64080, label = "SKEL_R_Finger41" },
    { id = 64081, label = "SKEL_R_Finger42" },
    { id = 26610, label = "SKEL_L_Finger00" },
    { id = 4089,  label = "SKEL_L_Finger01" },
    { id = 4090,  label = "SKEL_L_Finger02" },
    { id = 26611, label = "SKEL_L_Finger10" },
    { id = 4169,  label = "SKEL_L_Finger11" },
    { id = 4170,  label = "SKEL_L_Finger12" },
    { id = 26612, label = "SKEL_L_Finger20" },
    { id = 4185,  label = "SKEL_L_Finger21" },
    { id = 4186,  label = "SKEL_L_Finger22" },
    { id = 26613, label = "SKEL_L_Finger30" },
    { id = 4137,  label = "SKEL_L_Finger31" },
    { id = 4138,  label = "SKEL_L_Finger32" },
    { id = 26614, label = "SKEL_L_Finger40" },
    { id = 4153,  label = "SKEL_L_Finger41" },
    { id = 4154,  label = "SKEL_L_Finger42" },
    { id = 51826, label = "SKEL_R_Thigh" },
    { id = 58271, label = "SKEL_L_Thigh" },
    { id = 6442,  label = "RB_R_ThighRoll" },
    { id = 23639, label = "RB_L_ThighRoll" },
    { id = 16335, label = "MH_R_Knee" },
    { id = 46078, label = "MH_L_Knee" },
    { id = 36864, label = "SKEL_R_Calf" },
    { id = 63931, label = "SKEL_L_Calf" },
    { id = 52301, label = "SKEL_R_Foot" },
    { id = 14201, label = "SKEL_L_Foot" },
    { id = 24806, label = "PH_R_Foot" },
    { id = 57717, label = "PH_L_Foot" },
    { id = 35502, label = "IK_R_Foot" },
    { id = 65245, label = "IK_L_Foot" },
    { id = 20781, label = "SKEL_R_Toe0" },
    { id = 2108,  label = "SKEL_L_Toe0" },
    { id = 56604, label = "IK_Root" },
}

local HOVER_RADIUS = 0.0012

---@param x number
---@param y number
---@param text string
local function drawText2d(x, y, text)
    SetTextFont(4)
    SetTextScale(0.32, 0.32)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    SetTextCentre(true)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

---Every bone of the ped is a dot on screen; the admin looks around with the free camera and clicks one.
---The ped should hold still (a frozen pose). Returns the bone id, nil when cancelled.
---@param ped number
---@param current integer|nil the bone in use now (drawn green)
---@return integer|nil
function Tools.PickBone(ped, current)
    local lang = Tools.Lang()
    local center = GetEntityCoords(ped)
    local camPos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.8, 0.2)
    tgiCoreExports:CreateFreeCam({
        coords = camPos,
        pitch = -5.0,
        heading = GetEntityHeading(ped) + 180.0,
        fov = 50.0,
        maxFov = 90.0,
        speed = Tools.FREECAM_FINE.speed,
        shiftMultiplier = Tools.FREECAM_FINE.shiftMultiplier,
        slowMultiplier = Tools.FREECAM_FINE.slowMultiplier,
        scroll = "zoom",
        lookButton = "right",
        freezePlayer = true,
        transitionTime = 300,
        origin = center,
        maxDistance = 5.0,
    })
    tgiCoreExports:OpenKeyHelpMenu({
        { icon = "mouseLeftClick", label = lang.ADMIN_TOOL_BONE_PICK },
        { icon = "mouseRightClick", label = lang.ADMIN_TOOL_CAMERA_LOOK },
        { icon = { "wKey", "aKey", "sKey", "dKey" }, label = lang.ADMIN_TOOL_CAMERA_MOVE },
        { icon = { "escKey", "backspaceKey" }, label = lang.ADMIN_TOOL_CANCEL },
    })

    local aspect = GetAspectRatio(true)
    local selected = nil
    while true do
        Wait(0)
        DisableControlAction(0, 200, true)
        DisableControlAction(0, 322, true)
        SetMouseCursorActiveThisFrame()
        local looking = IsDisabledControlPressed(0, 25)
        local cursorX, cursorY = GetDisabledControlNormal(0, 239), GetDisabledControlNormal(0, 240)
        local hovered, hoveredDist, hoveredX, hoveredY
        for _, bone in ipairs(Tools.PED_BONES) do
            local index = GetPedBoneIndex(ped, bone.id)
            if index ~= -1 then
                local coord = GetWorldPositionOfEntityBone(ped, index)
                local onScreen, x, y = World3dToScreen2d(coord.x, coord.y, coord.z)
                if onScreen then
                    if bone.id == current then
                        DrawRect(x, y, 0.007, 0.007 * aspect, 54, 255, 159, 200)
                    else
                        DrawRect(x, y, 0.005, 0.005 * aspect, 255, 255, 255, 170)
                    end
                    if not looking then
                        local dx, dy = (x - cursorX) * aspect, y - cursorY
                        local dist = dx * dx + dy * dy
                        if dist < HOVER_RADIUS and (not hoveredDist or dist < hoveredDist) then
                            hovered, hoveredDist, hoveredX, hoveredY = bone, dist, x, y
                        end
                    end
                end
            end
        end
        if hovered then
            DrawRect(hoveredX, hoveredY, 0.009, 0.009 * aspect, 54, 255, 159, 240)
            drawText2d(hoveredX, hoveredY - 0.035, ("%s (%d)"):format(hovered.label, hovered.id))
            if IsDisabledControlJustPressed(0, 24) then
                selected = hovered.id
                break
            end
        end
        if Tools.JustPressed(Tools.CANCEL_KEYS) then break end
    end

    tgiCoreExports:CloseKeyHelpMenu()
    tgiCoreExports:DestroyFreeCam(0)
    return selected
end
