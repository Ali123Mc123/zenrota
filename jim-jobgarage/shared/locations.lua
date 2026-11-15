--[[	LIST OF POSSIBLE VEHICLE MODIFIERS   ]] --
-- Using these will change how each vehicle spawns
-- This can be used for making sure the vehicles comes out exactly how you want it to

-- CustomName = "Police Car", this will show a custom override name for your vehicles so you don't need to add them to your vehicles.lua
-- rank = { 2, 4 }, -- This specifes which grades can see it, and only these grades
-- grade = 4, -- This specifies the lowest grade and above that can see the vehicle
-- colors = { 136, 137 }, -- This is the colour index id of the vehicle, Primary and Secondary in that order
-- bulletproof = true, -- This determines if the tyres are bullet proof (don't ask me why, I was asked to add this)
-- livery = 1, -- This sets the livery id of the vehicle, (most mod menus would number them or have them in number order) 0 = stock
-- extras = { 1, 5 }, -- This enables the selected extras on the vehicle
-- performance = "max", this sets the stats to max if available
-- performance = { 2, 3, 3, 2, 4, true }, -- This allows more specific settings for each upgrade level, in order: engine, brakes, suspension, transmission, armour, turbo
-- trunkItems = { }, -- Use this to add items to the trunk of the vehicle when it is spawned

-- ANY VEHICLE, BOATS, POLICE CARS, EMS VEHICLES OR EVEN PLANES CAN BE ADDED.

Locations = {
    --- lspd
    {
        zoneEnable = true,
        job = "police",
        garage = {
            -- Alta PD (eski): spawn = vector4(61.6272, -354.1505, 38.2307, 67.9220), out = vector4(69.8192, -350.1074, 38.8378, 251.2676)
            spawn = vector4(425.68, -981.55, 25.31, 269.33), -- MRPD bodrum garajı, aracın çıktığı yer
            out = vector4(441.39, -974.78, 25.7, 178.49),    -- MRPD bodrum garajı, stand
            list = {
                ["onx_polbuff"] = {},
                ["onx_polbuffhf"] = {},
                ["onx_polmonar"] = {},
                ["onx_poltavros"] = {},
                ["onx_polkandra"] = {},
                ["onx_poldom"] = {},
                ["onx_polgaunt"] = {},
                ["onx_polbison3"] = {},
                ["onx_polmerit3"] = {},
                ["onx_polsem"] = {},
                ["onx_polscout"] = {},
                ["onx_polalamo"] = {},
                ["onx_polgrang2"] = {},
                ["onx_polverus"] = {},
                ["onx_poldorado"] = {},
                ["onx_polterm"] = {},
                ["onx_polcava"] = {},
                ["onx_poljog"] = {},
            }
        }
    },
    {
        zoneEnable = true,
        job = "police",
        garage = {
            -- Alta PD (eski): spawn = vector3(134.7569, -354.9612, 57.5743), out = vector4(123.4213, -373.6842, 57.5743, 340.3665)
            spawn = vector4(449.168, -981.325, 43.691, 87.234),   -- MRPD çatı helipedi (AIR mekanik yan pedde)
            out = vector4(455.5308, -989.1479, 43.6913, 2.0677), -- MRPD çatı, stand
            list = {
                ["onx_polcon"] = {
                    livery = 1
                },
                ["onx_polmav"] = {
                    livery = 1
                },
                ["onx_polmav2"] = {
                    livery = 1
                }
            }
        }
    },

    --sasp

    {
        zoneEnable = true,
        job = "sasp",
        garage = {
            spawn = vec4(-3134.90, 1414.11, 20.20, 319.91), -- Where the car will spawn
            out = vec4(-3139.09, 1391.26, 20.85, 323.43),   -- Where the parking stand is
            list = {
                ["onx_polbuff"] = {},
                ["onx_polbuffhf"] = {},
                ["onx_polmonar"] = {},
                ["onx_poltavros"] = {},
                ["onx_polkandra"] = {},
                ["onx_poldom"] = {},
                ["onx_polgaunt"] = {},
                ["onx_polbison3"] = {},
                ["onx_polmerit3"] = {},
                ["onx_polsem"] = {},
                ["onx_polscout"] = {},
                ["onx_polalamo"] = {},
                ["onx_polgrang2"] = {},
                ["onx_polverus"] = {},
                ["onx_poldorado"] = {},
                ["onx_polterm"] = {},
                ["onx_polcava"] = {},
                ["onx_poljog"] = {},
            }
        }
    },
    {
        zoneEnable = true,
        job = "sasp",
        garage = {
            spawn = vec4(-3113.83, 1471.95, 20.63, 215.11), -- Where the car will spawn
            out = vec4(-3095.18, 1470.87, 20.63, 127.72),   -- Where the parking stand is
            list = {
                ["onx_polcon"] = {
                    livery = 3
                },
                ["onx_polmav"] = {
                    livery = 3
                },
                ["onx_polmav2"] = {
                    livery = 3
                }
            }
        }
    },

    ----park ranger

    {
        zoneEnable = true,
        job = "sapr",
        garage = {
            -- old: spawn vec4(-804.67, 5407.57, 33.66, 177.97), out vec4(-794.18, 5403.72, 34.09, 358.64)
            -- prev Park Ranger: spawn vec4(371.8294, 789.2136, 187.2009, 150.6205), out vec4(377.6249, 792.4697, 187.6787, 171.8794)
            spawn = vector4(61.6272, -354.1505, 38.2307, 67.9220), -- Alta PD garajı, aracın çıktığı yer
            out = vector4(69.8192, -350.1074, 38.8378, 251.2676),  -- Alta PD garajı, stand
            list = {
                ["onx_polbuff"] = {},
                ["onx_polbuffhf"] = {},
                ["onx_polmonar"] = {},
                ["onx_poltavros"] = {},
                ["onx_polkandra"] = {},
                ["onx_poldom"] = {},
                ["onx_polgaunt"] = {},
                ["onx_polbison3"] = {},
                ["onx_polmerit3"] = {},
                ["onx_polsem"] = {},
                ["onx_polscout"] = {},
                ["onx_polalamo"] = {},
                ["onx_polgrang2"] = {},
                ["onx_polverus"] = {},
                ["onx_poldorado"] = {},
                ["onx_polterm"] = {},
                ["onx_polcava"] = {},
                ["onx_poljog"] = {},
            }
        }
    },

    {
        zoneEnable = true,
        job = "sapr",
        garage = {
            -- old: spawn vec4(-825.56, 5426.28, 34.06, 270.44), out vec(-789.95, 5403.59, 34.09, 353.49)
            -- prev Park Ranger: spawn vec4(408.3664, 762.7616, 188.4680, 52.2330), out vec(379.6859, 792.4615, 187.7348, 174.2680)
            spawn = vector3(134.7569, -354.9612, 57.5743),         -- Alta PD çatı helipedi
            out = vector4(123.4213, -373.6842, 57.5743, 340.3665), -- Alta PD çatı, stand
            list = {
                ["onx_polcon"] = {
                    livery = 3
                },
                ["onx_polmav"] = {
                    livery = 3
                },
                ["onx_polmav2"] = {
                    livery = 3
                }
            }
        }
    },

    ----orta kasaba

    {
        zoneEnable = true,
        job = "bcso",
        garage = {
            spawn = vec4(1855.05, 3697.96, 33.26, 30.02), -- Where the car will spawn
            out = vec4(1838.96, 3692.45, 34.03, 303.32),  -- Where the parking stand is
            list = {
                ["onx_polbuff"] = {},
                ["onx_polbuffhf"] = {},
                ["onx_polmonar"] = {},
                ["onx_poltavros"] = {},
                ["onx_polkandra"] = {},
                ["onx_poldom"] = {},
                ["onx_polgaunt"] = {},
                ["onx_polbison3"] = {},
                ["onx_polmerit3"] = {},
                ["onx_polsem"] = {},
                ["onx_polscout"] = {},
                ["onx_polalamo"] = {},
                ["onx_polgrang2"] = {},
                ["onx_polverus"] = {},
                ["onx_poldorado"] = {},
                ["onx_polterm"] = {},
                ["onx_polcava"] = {},
                ["onx_poljog"] = {},
            }
        }
    },


    {
        zoneEnable = true,
        job = "bcso",
        garage = {
            spawn = vec4(1824.44, 3685.75, 42.58, 8.52), -- Where the car will spawn
            out = vec4(1823.52, 3676.16, 42.98, 302.37), -- Where the parking stand is
            list = {
                ["onx_polcon"] = {
                    livery = 1
                },
                ["onx_polmav"] = {
                    livery = 1
                },
                ["onx_polmav2"] = {
                    livery = 1
                }
            }
        }
    },

    -- ambulance
    {
        zoneEnable = true,
        job = "ambulance",
        garage = {
            spawn = vec4(1166.67, -1549.68, 34.27, 272.27),
            out = vec4(1161.89, -1542.3, 34.79, 270.61),
            list = {
                ["onx_gurney"] = {},
                ["onx_ambkee"] = {},
                ["onx_ambjog3"] = {},
                ["onx_ambjog"] = {},
                ["ambulance"] = {},
                ["onx_polbuffhf"] = {},
            }
        }
    },

    {
        zoneEnable = true,
        job = "ambulance",
        garage = {
            spawn = vector4(623.1025, 2717.5396, 41.9369, 4.8931),
            out = vec4(609.4165, 2730.2854, 41.9367, 186.1279),
            list = {
                ["onx_gurney"] = {},
                ["onx_ambkee"] = {},
                ["onx_ambjog3"] = {},
                ["onx_ambjog"] = {},
                ["ambulance"] = {},
                ["onx_polbuffhf"] = {},
            }
        }
    },

    -- ambulance helicopters
    {
        zoneEnable = true,
        job = "ambulance",
        garage = {
            spawn = vec4(1186.13, -1552.94, 39.4, 3.91), -- Where the car will spawn
            out = vec4(1170.48, -1572.03, 39.4, 358.88), -- Where the parking stand is
            list = {
                ["onx_polcon"] = {
                    livery = 1
                },
                ["onx_polmav"] = {
                    livery = 1
                },
                ["onx_polmav2"] = {
                    livery = 1
                }
            }
        }
    },

        {
        zoneEnable = true,
        job = "ambulance",
        garage = {
            spawn = vector4(606.7944, 2772.8330, 61.7345, 192.6889), -- Where the car will spawn
            out = vec4(601.8027, 2778.3518, 61.7344, 282.3730), -- Where the parking stand is
            list = {
                ["onx_polcon"] = {
                    livery = 1
                },
                ["onx_polmav"] = {
                    livery = 1
                },
                ["onx_polmav2"] = {
                    livery = 1
                }
            }
        }
    },

    {
        zoneEnable = true,
        job = "doj",
        garage = {
            spawn = vec4(-521.59, -265.78, 34.72, 290.68), -- Where the car will spawn
            out = vec4(-527.03, -262.43, 35.48, 119.81),   -- Where the parking stand is
            list = {
                ["onx_polbuff"] = {},
                ["onx_polbuffhf"] = {},
                ["onx_polmonar"] = {},
                ["onx_poltavros"] = {},
                ["onx_polkandra"] = {},
                ["onx_poldom"] = {},
                ["onx_polgaunt"] = {},
                ["onx_polbison3"] = {},
                ["onx_polmerit3"] = {},
                ["onx_polsem"] = {},
                ["onx_polscout"] = {},
                ["onx_polalamo"] = {},
                ["onx_polgrang2"] = {},
                ["onx_polverus"] = {},
                ["onx_poldorado"] = {},
                ["onx_polterm"] = {},
                ["onx_polcava"] = {},
                ["onx_poljog"] = {},
            }
        }
    },


    {
        zoneEnable = true,
        job = "pbsd",
        garage = {
            spawn = vector4(2797.5972, 4760.2671, 46.4510, 12.5793), -- Where the car will spawn
            out = vector4(2797.6340, 4754.2173, 46.9930, 13.1587),
            list = {
                ["onx_polbuff"] = {},
                ["onx_polbuffhf"] = {},
                ["onx_polmonar"] = {},
                ["onx_poltavros"] = {},
                ["onx_polkandra"] = {},
                ["onx_poldom"] = {},
                ["onx_polgaunt"] = {},
                ["onx_polbison3"] = {},
                ["onx_polmerit3"] = {},
                ["onx_polsem"] = {},
                ["onx_polscout"] = {},
                ["onx_polalamo"] = {},
                ["onx_polgrang2"] = {},
                ["onx_polverus"] = {},
                ["onx_poldorado"] = {},
                ["onx_polterm"] = {},
                ["onx_polcava"] = {},
                ["onx_poljog"] = {},
            }
        }
    },

    {
        zoneEnable = true,
        job = "cppd", -- Cayo Perico
        garage = {
            spawn = vector4(4377.3700, -4252.6400, 3.1782, 359.2821), -- Where the car will spawn
            out = vector4(4377.4487, -4258.6411, 3.1782, 359.2821),
            list = {
                ["onx_polbuff"] = {},
                ["onx_polbuffhf"] = {},
                ["onx_polmonar"] = {},
                ["onx_poltavros"] = {},
                ["onx_polkandra"] = {},
                ["onx_poldom"] = {},
                ["onx_polgaunt"] = {},
                ["onx_polbison3"] = {},
                ["onx_polmerit3"] = {},
                ["onx_polsem"] = {},
                ["onx_polscout"] = {},
                ["onx_polalamo"] = {},
                ["onx_polgrang2"] = {},
                ["onx_polverus"] = {},
                ["onx_poldorado"] = {},
                ["onx_polterm"] = {},
                ["onx_polcava"] = {},
                ["onx_poljog"] = {},
            }
        }
    },

    {
        zoneEnable = true,
        job = "pbsd",
        garage = {
            spawn = vector4(2782.3552, 4794.6489, 46.7042, 101.4833), -- Where the car will spawn
            out = vector4(2791.7922, 4793.5166, 46.8313, 102.0282),   -- Where the parking stand is
            list = {
                ["onx_polcon"] = {
                    livery = 1
                },
                ["onx_polmav"] = {
                    livery = 1
                },
                ["onx_polmav2"] = {
                    livery = 1
                }
            }
        }
    },

        {
        zoneEnable = true,
        job = "pbsd", -- Paleto (was dp)
        garage = {
            spawn = vector4(-475.1978, 5988.5469, 31.3365, 314.7441), -- Where the car will spawn
            out = vector4(-489.9164, 6002.5063, 31.2992, 226.4289),   -- Where the parking stand is
            list = {
                ["onx_polcon"] = {
                    livery = 1
                },
                ["onx_polmav"] = {
                    livery = 1
                },
                ["onx_polmav2"] = {
                    livery = 1
                }
            }
        }
    },

    {
        zoneEnable = true,
        job = "pbsd", -- Paleto (was dp)
        garage = {
            spawn = vector4(-472.3603, 6035.2275, 31.3404, 225.6508), -- Where the car will spawn
            out = vector4(-463.2220, 6028.1997, 31.3404, 45.8209),
            list = {
                ["onx_polbuff"] = {},
                ["onx_polbuffhf"] = {},
                ["onx_polmonar"] = {},
                ["onx_poltavros"] = {},
                ["onx_polkandra"] = {},
                ["onx_poldom"] = {},
                ["onx_polgaunt"] = {},
                ["onx_polbison3"] = {},
                ["onx_polmerit3"] = {},
                ["onx_polsem"] = {},
                ["onx_polscout"] = {},
                ["onx_polalamo"] = {},
                ["onx_polgrang2"] = {},
                ["onx_polverus"] = {},
                ["onx_poldorado"] = {},
                ["onx_polterm"] = {},
                ["onx_polcava"] = {},
                ["onx_poljog"] = {},
            }
        }
    },
}
