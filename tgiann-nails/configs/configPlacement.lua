-- How the nails sit on each fingertip bone (bone-local, rotation order 2). Order: left thumb..pinky, right thumb..pinky
-- shift slides every nail along its finger in metres (- = towards the hand), lift moves it off the skin

---@type table<string, NailsPedPlacement>
config.placement = {
    mp_f_freemode_01 = {
        shift = -0.008,
        lift = 0.0,
        fingers = {
            { bone = 4090, size = "l", pos = vec3(0.02286, 0.00405, 0.00021), rot = vec3(-1.48, -89.98, -89.19), axis = vec3(0.9996, 0.0142, -0.0258), normal = vec3(-0.0142, 0.9999, 0.0004) }, -- SKEL_L_Finger02
            { bone = 4170, size = "m", pos = vec3(0.02026, 0.00421, 0.00157), rot = vec3(1.42, -90.22, -81.36), axis = vec3(0.9884, 0.1501, 0.0248), normal = vec3(-0.1501, 0.9887, -0.0038) }, -- SKEL_L_Finger12
            { bone = 4186, size = "m", pos = vec3(0.02052, 0.00866, -0.00158), rot = vec3(-5.03, -88.62, -74.67), axis = vec3(0.9607, 0.2634, -0.0877), normal = vec3(-0.2623, 0.9647, 0.0239) }, -- SKEL_L_Finger22
            { bone = 4138, size = "m", pos = vec3(0.01896, 0.00771, -0.00019), rot = vec3(-1.63, -89.62, -77.02), axis = vec3(0.9741, 0.2245, -0.0285), normal = vec3(-0.2244, 0.9745, 0.0066) }, -- SKEL_L_Finger32
            { bone = 4154, size = "s", pos = vec3(0.02059, 0.00590, 0.00078), rot = vec3(2.90, -90.30, -84.11), axis = vec3(0.9934, 0.1026, 0.0505), normal = vec3(-0.1024, 0.9947, -0.0052) }, -- SKEL_L_Finger42
            { bone = 64017, size = "l", pos = vec3(0.02286, 0.00406, -0.00021), rot = vec3(1.48, -90.02, -89.19), axis = vec3(0.9996, 0.0142, 0.0259), normal = vec3(-0.0142, 0.9999, -0.0004) }, -- SKEL_R_Finger02
            { bone = 64097, size = "m", pos = vec3(0.02025, -0.00422, 0.00157), rot = vec3(1.42, 90.22, -98.64), axis = vec3(0.9884, -0.1501, 0.0248), normal = vec3(-0.1501, -0.9887, -0.0038) }, -- SKEL_R_Finger12
            { bone = 64113, size = "m", pos = vec3(0.02051, -0.00866, -0.00158), rot = vec3(-5.03, 88.62, -105.33), axis = vec3(0.9607, -0.2634, -0.0877), normal = vec3(-0.2623, -0.9647, 0.0239) }, -- SKEL_R_Finger22
            { bone = 64065, size = "m", pos = vec3(0.01895, -0.00771, -0.00019), rot = vec3(-1.63, 89.62, -102.98), axis = vec3(0.9741, -0.2245, -0.0285), normal = vec3(-0.2244, -0.9745, 0.0066) }, -- SKEL_R_Finger32
            { bone = 64081, size = "s", pos = vec3(0.02059, -0.00591, 0.00078), rot = vec3(2.90, 90.30, -95.90), axis = vec3(0.9934, -0.1026, 0.0505), normal = vec3(-0.1024, -0.9947, -0.0052) }, -- SKEL_R_Finger42
        },
    },
}

-- Male freemode hands use the female placement with their own shift and lift until tuned
config.placement.mp_m_freemode_01 = { shift = -0.008, lift = 0.0, fingers = config.placement.mp_f_freemode_01.fingers }
