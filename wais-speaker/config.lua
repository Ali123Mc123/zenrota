Config = {}
Config.Framework = {
    ["Framework"] = "auto", -- [[LEAVE AUTO]] auto, esx, qbcore or qbox
    ["ResourceName"] = "auto", -- [[LEAVE AUTO]] auto, es_extended or qb-core or your resource name. If you using qbx you should write qb-core
    ["SharedEvent"] = "" -- Event name for old cores.
}

Config.Language = "tr" -- ar, cz, ro, it, fr, de, tr
Config.ShowDebug = false -- Show debug messages
Config.Reverb = true -- Enable reverb/echo effects based on ceiling height. If `true`, it will increase the use of resmon. While there is a more pronounced reverb in low ceilings, there is no reverb in open areas, resulting in a cleaner sound.
Config.RateLimit = 2.5 -- Time (in seconds) a player must wait before playing another sound.
Config.ActionCooldown = 0.25 -- Time (in seconds) a player must wait before performing another action (like change seek, distance, volume etc.)
Config.DisableGTARadio = true -- It prevents the GTA5 radio menu from opening in vehicles. This way, you cannot turn on your car radio while the speaker is working, preventing sound confusion.
Config.SpatialUpdateRate = 200 -- How often (in ms) to update spatial audio positions and volumes (lower values may increase CPU usage but provide smoother audio transitions)
Config.MaxCeilingDistance = 25.0 -- The maximum ceiling height to be checked in the area where the speaker or car is located. This allows echo/reverb sounds to be added.
Config.DeleteBoomboxWhenOwnerQuit = false --[[
    ⚠️⚠️⚠️
    If you set it to `true`, boomboxes placed by a user will be automatically deleted when they leave the server. 
    If you set it to `false`, boomboxes will remain even if the player who placed them leaves.
]]
Config.StopMusicWhenVehicleIsEmpty = false --[[
    ⚠️⚠️⚠️
    If you set it to `true`, the music will stop when there are no players in the vehicle. 
    If you set it to `false`, the music will continue to play even if there are no players in the vehicle.
]]
Config.SyncCheck = true --[[
    ⚠️⚠️⚠️
    This variable belongs to the code structure that checks whether the song is progressing as it should, in sync with other people.
    The reasons I use this are as follows:
        - When the game is minimized, the CPU freezes all game-related processes for a certain number of seconds or minutes. 
            > This suspends the game's processes. When the player returns to the game, they will hear the songs behind schedule by the duration of the freeze compared to other players. 
        - Players experiencing occasional freezes or lag will hear the song delayed by the duration of the game's lag. 
    This way, the remaining users will move back to the current second.
    
    
    💢💢💢
    If you set it to `false`, when these conditions occur, the user's song will lag behind the others (by the amount of time it freezes or stutters). 
    Therefore, it will not be synchronized, and when the song ends at the expected second, it will suddenly cut off. 
]]

Config.Carplay = {
    ["enabled"] = true, -- You determine whether music can be played in the car. `true` allows this. `false` prevents the music menu from opening in the vehicle.
    ["keymapping"] = {
        ["key"] = "G", -- Key to open car speaker menu.
        ["command"] = "carplay", -- Command to open car speaker menu. Only used if `disableKey` is `true`.
        ["disableKey"] = false, -- If you set it to `true`, you can open the car speaker menu with the specified key. If you set it to `false`, you can only open the menu by using the command.
        ["description"] = "Müzik Sistemini Aç/Kapa", -- Description for the command in chat. Only used if `disableKey` is `true`.
    },
    ["only_driver"] = false, --[[
        🚗🚗🚗
        If you set it to `true`, only the driver of the vehicle can open the car speaker menu and play music. 
        If you set it to `false`, passengers can also open the menu and play music in the vehicle.
    ]]
    ["keep_input"] = false, --[[
        🔆🔆🔆
        Whether you can control the car while the CarPlay menu is open.
        If it is `true`, you can continue driving when CarPlay is activated. You will not be able to control the vehicle when you click on Input. 
        If it is `false`, vehicle controls will not return until the menu closes when CarPlay is activated.
    ]]
    ["install"] = {
        --[[
            💢💢💢
            Caution if you are going to use this system:
                !-> You need to make some changes to your garage script for this system. 
                !-> If you can't do it or your script doesn't allow it (those parts are rescrow), please don't use it.

            🔧🔧🔧
            Trigger the following events/exports on the server or client side of your garage script when a new vehicle is spawned:
                - Trigger this to send it to the server in a client-side operation:
                    - vehicleNetId: You can get the network ID of the vehicle using `NetworkGetNetworkIdFromEntity(vehicleEntity)`
                        > TriggerServerEvent('wais:speaker:server:CheckCarPlay', vehicleNetId)
                
                - Trigger this export in server-side spawn operations:
                    - vehicleNetId: You can get the network ID of the vehicle using `NetworkGetNetworkIdFromEntity(vehicleEntity)`
                        > exports["wais-speaker"]:CheckCarPlay(vehicleNetId)
        ]]

        ["use"] = true, -- DaddyRP: G menüsü sadece mekanikten car_play takılmış araçta açılır
        --[[
            To play music in the car, a “car_play” or the specified item must be installed in that vehicle. This item can be purchased and installed by mechanics or other individuals. 
            The `true` value does not allow playing songs without installing the item in the car. 
            The `false` value allows you to use it via the menu without needing to install the item in the car.
        ]]
        ["item"] = "car_play", -- The item name that needs to be installed in the car to play music. (Only if `use` is `true`)
        ["remove_key"] = "H", -- The button used to remove the car radio installed in the vehicle. Only the actual owner of the vehicle can remove this item from the vehicle.
        ["only_owner_can_remove"] = true, -- DaddyRP: true KALMALI. car_play ömürlük, kimse sökemez (bridge/editable/server.lua getVehicleOwner hep false). If set to `true`, only the actual owner of the vehicle can remove the car radio item from the vehicle. If set to `false`, anyone can remove it.
        ["progresses"] = {
            ["install"] = {
                ["anim"] = {
                    ["dict"] = "mini@repair",
                    ["clip"] = "fixing_a_ped",
                    ["flag"] = 16,
                },
                ["duration"] = 5 * 1000, -- Time (in ms default is 10 sec) to install the car radio item in the vehicle
            },
            ["remove"] = {
                ["anim"] = {
                    ["dict"] = "mini@repair",
                    ["clip"] = "fixing_a_ped",
                    ["flag"] = 16,
                },
                ["duration"] = 10 * 1000, -- Time (in ms default is 10 sec) to remove the car radio item from the vehicle
            }
        },
    }
}

Config.InteractionDistances = {
    --[[
        🔉🔉🔉🎶🎶
        These distances are selectable by users.
        Even if a user renders a vehicle or speaker, they will not be able to hear the sound unless they approach within the selected distance.
        When it enters within the selected distance, the sound will play at 0.0 volume. The level will increase as it approaches.
    ]]

    ["vehicles"] = 20.0, -- Maximum distance to hear speaker from vehicle
    ["speakers"] = 15.0, -- Maximum distance to hear speaker from ground speaker
}

Config.BoomBoxes = {
    --[[
        📻📻📻
        Add your boombox items and models here.
        Example: ["boombox_item_name"] = { ["model"] = "model_name", ["attach"] = { ... }  }
    ]]
    
    ["boombox_a"] = {
        ["model"] = "qua_b_speaker_a",
    },
    ["boombox_b"] = {
        ["model"] = "qua_b_speaker_b",
        ["attach"] = {
            ["bone"] =  4154, -- Bone index to attach to
            ["offsets"] = vector3(0.0065000279928427, 0.014985923761626, 0.03601949922086), -- Offsets from the bone (x, y, z)
            ["rotation"] = vector3(0.0, 0.0, 0.0), -- Rotation offsets (x, y, z)
            ["animation"] = {
                ["dict"] = "anim@heists@humane_labs@finale@keycards",
                ["clip"] = "ped_a_enter_loop",
                ["flag"] = 49,
            }
        },
    },
    ["boombox_c"] = {
        ["model"] = "qua_b_speaker_c",
        ["attach"] = {
            ["bone"] =  4154, -- Bone index to attach to
            ["offsets"] = vector3(0.0065000279928427, 0.014985923761626, 0.03601949922086), -- Offsets from the bone (x, y, z)
            ["rotation"] = vector3(0.0, 0.0, 0.0), -- Rotation offsets (x, y, z)
            ["animation"] = {
                ["dict"] = "anim@heists@humane_labs@finale@keycards",
                ["clip"] = "ped_a_enter_loop",
                ["flag"] = 49,
            }
        },
    },
    ["boombox_d"] = {
        ["model"] = "qua_b_speaker_d",
        ["attach"] = {
            ["bone"] =  60309, -- Bone index to attach to
            ["offsets"] = vector3(0.076437357549594, 0.0067159641248784, 0.074606438615931), -- Offsets from the bone (x, y, z)
            ["rotation"] = vector3(-97.361141027512, 0.61234434151617, 1.8357067867561), -- Rotation offsets (x, y, z)
            ["animation"] = {
                ["dict"] = "impexp_int-0",
                ["clip"] = "mp_m_waremech_01_dual-0",
                ["flag"] = 51,
            }
        },
    },
    ["boombox_e"] = {
        ["model"] = "qua_b_speaker_e",
        ["attach"] = {
            ["bone"] =  57005, -- Bone index to attach to
            ["offsets"] = vector3(0.21548992346879, 0, -0.031528220090249), -- Offsets from the bone (x, y, z)
            ["rotation"] = vector3(1.0652214653109, -81.414172039437, -19.730610318178), -- Rotation offsets (x, y, z)
            ["animation"] = {
                ["dict"] = "move_weapon@jerrycan@generic",
                ["clip"] = "idle",
                ["flag"] = 51,
            }
        },
    },
    ["boombox_f"] = {
        ["model"] = "qua_b_speaker_f",
    },
}

Config.StreamerMode = {
    --[[
        It was developed for your streamer-gamers who stream on Twitch, Kick, or similar platforms.
        Since the songs are played via YouTube, this is used to prevent copyright issues and takedown notices.
    ]]
    ["use"] = true, -- If you set it to `true`, users will be able to block music played through speakers, boomboxes, and CarPlay using the command below.
    ["command"] = "streamermode", -- Command to toggle streamer mode. You can change it to your desired command.
}


Config.Actions = {
    --[[
        You can control features such as boombox placement, removal, and attachment from here.
    ]]

    ["place"] = {
        ["select_speaker_location"] = true, -- Enable/Disable boombox placement feature
        ["timeout"] = 10 * 1000, -- Time (in ms default is 10 sec) to wait for player to place boombox
        ["offsets"] = vector4(0.75, 0.0, 0.0, 180.0), -- Offset from player position to spawn boombox (x, y, z, heading)
        ["distance"] = 8.0, -- Max distance to place boombox from player
        ["buttons"] = {
            ["accept"] = "E", -- Key to place boombox
            ["cancel"] = "G" -- Key to cancel boombox placement
        },
        ["animations"] = {
            ["dict"] = "amb@medic@standing@tendtodead@base",
            ["clip"] = "base",
            ["flag"] = 1,
            ["duration"] = 2 * 1000,
        }
    },
    ["detach"] = {
        ["key"] = "X" -- Key to detach boombox from your character and drop it on the ground
    }
}

Config.BlacklistedVehicles = {
    --[[
        ⚠️⚠️⚠️
        From here, you can disable the speaker menu for the vehicle class or specific models of your choice, 
        so that the song menu will no longer open and songs will not play in those vehicles.
    ]]

    ["class"] = {
        --[[
            You can find all other vehicle classes here:
            0: Compacts  
            1: Sedans  
            2: SUVs  
            3: Coupes  
            4: Muscle  
            5: Sports Classics  
            6: Sports  
            7: Super  
            8: Motorcycles  
            9: Off-road  
            10: Industrial  
            11: Utility  
            12: Vans  
            13: Cycles  
            14: Boats  
            15: Helicopters  
            16: Planes  
            17: Service  
            18: Emergency  
            19: Military  
            20: Commercial  
            21: Trains 
            22: Open Wheel
        ]]
        [8] = true,  -- Motorcycles
        [13] = true, -- Cycles
        [14] = true, -- Boats
        [15] = true, -- Helicopters
        [16] = true, -- Planes
    },
    ["models"] = {
        --[[
            Example: Add specific vehicle models to blacklist by their hash. You can add as many as you want.
        ]]
        [`issi2`] = true, 
    }
}

Config.BlacklistedCoords = {
    --[[
        🚫🚫🚫
        You can add blacklist coordinates so that people cannot place speakers there. 
        If someone dies in that area, the speaker is returned to the inventory. 
        Songs cannot be played in vehicles within that area.
        
        Example: { coords = vector3(x, y, z), radius = 10.0 }
    ]]

    { coords = vector3(455.5057, -994.2595, 26.9876), radius = 45.0 }, -- Mission Row Police Department [MRPD]
    { coords = vector3(320.7686, -590.9871, 45.0281), radius = 40.0 }, -- Pillbox Hill Medical Center [PHMC]
    { coords = vector3(-2048.7466, -1483.6117, 3.1551), radius = 200.0 } -- 200 m yasakli bolge (2026-11-14)
}

Config.Debug = function(...)
    if Config.ShowDebug then
        print(...)
    end
end

Config.Notification = function(title, text, type, time)
    title = title or "Speaker"
    time = time or 5000

    if lib ~= nil then
        return lib.notify({
            title = title,
            type = type,
            duration = time,
            description = text,
            iconAnimation = "beatFade",
            position = "center-right"
        })
    end

    if GetResourceState("okokNotify"):find("start") then
        return exports['okokNotify']:Alert(title, text, time, type, true)
    end
end