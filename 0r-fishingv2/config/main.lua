return {
   Debug = false,

   -- !NOTE!
   -- You can add the translation files you have created for the script to the script in the next updates by contacting the support requests/snippets channels or the authorized person named @vezironi (no.1).
   -- !NOTE!

   Locale = 'tr',                  -- You specify the primary language of your script. (Currently Supported Langs: en (english, tr (turkish))

   Target = 'auto',                -- If you don't want to use the Target system with the script and want to use TextUI, set this option to false. (Supported Target Scripts: qb-target, ox_target, sleepless_interact)
   Notify = 'ox_lib',              -- The notification system determines which script will send the notifications sent by the script. (Supported Notify Scripts: brutal_notify, lation_ui, mythic_notify, okokNotify, ox_lib, pNotify, r_notify, t-notify, wasabi_notify)
   HelpText = 'ox_lib',            -- If you are not using the target system, the TextUI system will be displayed. (Supported TextUI Scripts: cd_drawtextui, jg-textui, lab-HintUI, lation_ui, okokTextUI, ox_lib)
   VehicleKey = 'wais-vehiclekey', -- This is the vehiclekeys script you will use for boats and ships. (Supported Vehiclekeys Scripts: MrNewbVehicleKeys, Renewed-Vehiclekeys, cd_garage, mk_vehiclekeys, okokGarage, qb-vehiclekeys, qbx_vehiclekeys, qs-vehiclekeys, wasabi_carlock)
   Fuel = 'savana-fuel',           -- This is the fuel script you will use for boats and ships. (Supported Fuel Scripts: LegacyFuel, Renewed-Fuel, cdn-fuel, esx-sna-fuel, lc_fuel, okokGasStation, ox_fuel, ps-fuel, qs-fuelstations, ti-fuel, x-fuel)

   AFKMode = false,                -- If you set it to true, mini-games will not appear for players, and they can fish while AFK.
   AntiMacro = true,               -- If you set it to true, macro detection will be active.
   AntiMacroAction = 'notify',     -- 'notify' (warning), 'kick' (kick from server), 'ban' (ban via webchecker)
   AntiMacroGracePeriod = 1500,    -- Minimum time (ms) for a minigame to be valid (default 1.5s for safety)
   CraftMode = false,              -- If you want a player who is fishing for the first time to craft their fishing rod first, set it to true.

   ---@class Logs
   ---@field status boolean
   ---@field type string
   Logs = {
      status = true,    -- Enable/disable log system
      type = 'discord', -- Log type: discord, ox (datadog, loki, fivemanage)
   },

   ---@class Boat
   ---@field price number
   Boat = {
      price = 1000, -- The amount players will pay for renting a boat or dinghy
   },

   ---@class RodUpgrade
   ---@field price number
   ---@field chance number
   RodUpgrade = {
      price = 50,  -- The fee players will pay for each rod upgrade
      chance = 33, -- The probability that will be effective in each increase
   },

   ---@class LuckyHat
   ---@field status boolean
   ---@field itemName string
   ---@field multiplier number
   ---@field clothing table
   LuckyHat = {
      status = true,          -- If you set it to False, players cannot use the Lucky Hat and cannot earn more XP.
      itemName = 'lucky_hat', -- Lucky Hat's item name (Default: lucky_hat)
      multiplier = 1.5,       -- The multiplier that each earned XP will be multiplied by
      clothing = {
         [`mp_m_freemode_01`] = {
            componentId = 0, -- Do not change this.
            item = 3,        -- If you are using a different clothing package and you wear a different clothing item instead of a hat when you use the Lucky Hat item, change this to the clothing number in the Clothing Menu.
            texture = 2,     -- -- You can set the different color of the hat, if any, or its shape and appearance here.
         },
         [`mp_f_freemode_01`] = {
            componentId = 0, -- Do not change this.
            item = 3,        -- If you are using a different clothing package and you wear a different clothing item instead of a hat when you use the Lucky Hat item, change this to the clothing number in the Clothing Menu.
            texture = 2,     -- -- You can set the different color of the hat, if any, or its shape and appearance here.
         },
      }
   },

   Commands = {
      ['stop_fishing'] = {
         command = 'stop_fishing',
         description = 'Balık Tutmayı Bırak',
         key = 'Delete',
      },
   },

   Keys = {
      ['craft_mode'] = {
         key = 'G',
         index = 47,
      },
      ['start_fishing'] = {
         key = 'E',
         index = 38,
      },
   },


   ---@type FishingTimes
   FishingTimes = {
      Rod = {
         min = 5000,  -- Minimum ms (milliseconds) that players fishing with a fishing rod will wait for a fish to be caught
         max = 12000, -- Maximum ms (milliseconds) that players fishing with a fishing rod will wait for a fish to be caught
      },
      Net = {
         min = 10000, -- Minimum ms (milliseconds) that players fishing with a Fishing Net will wait for a fish to be caught on their hook
         max = 15000, -- Maximum ms (milliseconds) that players fishing with a Fishing Net will wait for a fish to be caught on their hook
      }
   },

   Minigame = {
      distance = {
         intervalTime = 5, -- You determine the speed of the distance you will throw the fishing rod in the minigame in ms (milliseconds).
         position = 1      -- Do not change this
      },
      game = {
         intervalTime = 6,   -- You set the speed of the box in the fish catching minigame in ms (milliseconds).
         position = 0.25,    -- Do not change this
         successCounter = 5, -- You determine how many correct answers a player needs to make to catch a fish. This is valid for 1 minigame.
         failCounter = 6,    -- You determine how many wrong answers a player needs to make to lose the fish. This is valid for 1 minigame.
      }
   },

   ---@class Trash
   ---@field status boolean
   ---@field chance number
   Trash = {
      status = true, -- If you set it to false, trash will not be caught on the hook.
      chance = 20,   -- You can determine the probability of catching trash instead of fish here.
   },

   ---@class LongDistance
   ---@field status boolean
   ---@field chance number
   LongDistance = {
      status = true, -- If you set it to false, the player will not be able to win special rewards when casting his fishing rod to a distant point.
      chance = 9,    -- If the player casts his fishing rod to a distant point, you determine the probability at which rare items will be caught on his fishing rod.
   },

   ---@type FishermanLocations[]
   FishermanLocations = { -- Fish market locations
      -- {
      --    model = `a_m_y_jetski_01`,
      --    coords = vec4(-1811.74, -1244.03, 13.45, 319.17), -- Del Pier
      -- },
      {
         model = `a_m_y_jetski_01`,
         coords = vec4(-3070.49, -6.05, 4.58, 148.53), -- Pacific Bluffs Pier
      },
      {
         model = `a_m_y_jetski_01`,
         coords = vec4(-3416.49, 965.92, 8.35, 0.36), -- #1 Unnamed Pier
      },
      {
         model = `a_m_y_jetski_01`,
         coords = vec4(-2607.27, 3682.62, 4.52, 79.58), -- Military Pier
      },
      {
         model = `a_m_y_jetski_01`,
         coords = vec4(-1593.08, 5202.92, 4.31, 292.69), -- #2 Unnamed Pier
      },
      {
         model = `a_m_y_jetski_01`,
         coords = vec4(2864.6, -641.11, 4.46, 263.63), -- FBI Pier
      },
      {
         model = `a_m_y_jetski_01`,
         coords = vec4(1921.25, 252.16, 164.99, 231.22), -- #3 Unnamed Pier
      },
      {
         model = `a_m_y_jetski_01`,
         coords = vec4(-1835.0009, -1404.1780, 1.9021, 230.4635), -- Yeni Ada Balıkçı
      },
      {
         model = `a_m_y_jetski_01`,
         coords = vec4(5114.0, -5096.0, 2.3, 270.0), -- Cayo kampüs iskelesi
      },
   },

   ---@type RentBoatLocations[]
   RentBoatLocations = { -- Boat rental locations
      {
         model = `a_m_y_jetski_01`,
         coords = vec4(-1841.2498, -1411.8777, 1.9021, 228.1849), -- Del Pier
         spawnCoords = vector4(-1831.0905, -1413.1256, 0.1720, 231.1024),
      },
      {
         model = `a_m_y_jetski_01`,
         coords = vec4(-3112.59, -75.97, 4.58, 327.59), -- Pacific Bluffs Pier
         spawnCoords = vec4(-3121.64, -65.44, 0.91, 149.13),
      },
      {
         model = `a_m_y_jetski_01`,
         coords = vec4(-3425.55, 951.72, 8.35, 3.68), -- #1 Unnamed Pier
         spawnCoords = vec4(-3421.74, 946.44, 0.21, 94.81),
      },
      {
         model = `a_m_y_jetski_01`,
         coords = vec4(-2688.26, 3692.17, 4.52, 261.13), -- Military Pier
         spawnCoords = vec4(-2682.44, 3704.71, 0.4, 83.51),
      },
      {
         model = `a_m_y_jetski_01`,
         coords = vec4(-1604.96, 5256.53, 2.07, 297.9), -- #2 Unnamed Pier
         spawnCoords = vec4(-1603.32, 5259.8, 0.12, 22.9),
      },
      {
         model = `a_m_y_jetski_01`,
         coords = vec4(2946.2, -644.98, 4.47, 92.14), -- FBI Pier
         spawnCoords = vec4(2941.17, -658.05, 0.5, 263.93),
      },
      {
         model = `a_m_y_jetski_01`,
         coords = vec4(1299.3315, -3325.9304, 6.0037, 87.8989), -- Cayo Perico Pier
         spawnCoords = vec4(1317.3287, -3326.3411, 0.2925, 97.4871),
      },
      {
         model = `a_m_y_jetski_01`,
         coords = vec4(3926.1113, -4689.3145, 4.1809, 295.6296), -- Cayo Perico Tekne Kiralama
         spawnCoords = vec4(3805.3506, -4676.1416, -0.3430, 81.7422),
      },
      {
         model = `a_m_y_jetski_01`,
         coords = vec4(-3328.3860, 6964.3062, 1.2057, 132.7770), -- Yeni Ada Tekne Kiralama
         spawnCoords = vec4(-3329.5020, 6961.9199, 2.4842, 224.6467),
      },
   },

   ---@type Blips
   Blips = {
      fishinger = {
         status = true,      -- If you set it to false, the fish market locations will not appear on the map.
         sprite = 68,        -- You can set how fish market locations appear on the map. - https://docs.fivem.net/docs/game-references/blips/
         color = 2,          -- You can set the color in which fish market locations will appear on the map. - https://docs.fivem.net/docs/game-references/blips/#blip-colors
         scale = 0.8,        -- You can set the size at which fish market locations will appear on the map.
         name = 'Fishinger', -- You can set the name under which fish market locations will appear on the map.
      },
      rentBoat = {
         status = false,     -- If you set it to false, rent boat locations will not appear on the map.
         sprite = 68,        -- You can set how rent boat locations appear on the map. - https://docs.fivem.net/docs/game-references/blips/
         color = 2,          -- You can set the color in which rent boat locations will appear on the map. - https://docs.fivem.net/docs/game-references/blips/#blip-colors
         scale = 0.8,        -- You can set the size at which rent boat locations will appear on the map.
         name = 'Tekne Kirala', -- You can set the name under which rent boat locations will appear on the map.
      },
   },

   ---@type CaughtRewards
   CaughtRewards = {
      status = true,
      quality = {
         common = {
            default = 100, -- Here you can set the default xp that will be given when you catch the fish according to their rarity.
            random = true, -- If you set it to false it will give players default xp.
            min = 100,     -- Here you can set the minimum xp that the fish will give when you catch them according to their rarity.
            max = 200,     -- Here you can set the maximum xp that the fish will give when you catch them according to their rarity.
         },
         eco = {
            default = 100,
            random = true,
            min = 100,
            max = 200,
         },
         rare = {
            default = 100,
            random = true,
            min = 100,
            max = 200,
         },
         epic = {
            default = 100,
            random = true,
            min = 100,
            max = 200,
         },
      },
   },

   ---@type Information[]
   Information = {
      {
         id = 1,
         new = false,
         title = 'Balık tutmaya nasıl başlanır?',
         description =
         'Balık tutmaya başlamak için önce envanterinizde olta ve yem olduğundan emin olun. Bir balık tutma alanına gidin, oltanızı kuşanın ve yemi kullanın. İp atmak için uygun tuşa basın. Balık oltaya geldiğinde, yakalamak için ekrandaki talimatları izleyin. Eğer yeminiz biterse, balık tutmaya devam etmeden önce daha fazla yem almanız gerekir.',
      },
      {
         id = 2,
         new = false,
         title = 'Balık tutma noktaları',
         description =
         'Haritada işaretlenmiş balık tutma noktalarında balık tutabilirsiniz. Bu noktaları bulmak için "Balık Alanı" simgesine bakın. Bazı bölgelerde nadir balıkları yakalama şansı daha yüksektir. Balık tutmaya başlamak için suyun yakınında ve yasak bölgede olmadığınızdan emin olun.',
      },
      {
         id = 2,
         new = true,
         title = 'Oltalar ve yükseltmeler',
         description =
         'Toplamda 5 farklı olta vardır ve her birinin seviyesi giderek artar. Daha yüksek seviyeli oltalar, daha kaliteli ve nadir balıkları yakalamanıza olanak tanır. Oltanızı menüdeki yükseltme seçeneğini kullanarak, gerekli eşyalar sizde varsa ve seviye şartlarını karşılıyorsanız geliştirebilirsiniz. Oltanızı yükseltmek, daha iyi balık yakalama şansınızı artırır.',
      },
   },

   ---@type QualityTypes
   QualityTypes = {
      common = {
         name = 'Common',
         color = '#666666',
      },
      eco = {
         name = 'Eco',
         color = '#AFDF6B',
      },
      rare = {
         name = 'Rare',
         color = '#F8474A',
      },
      epic = {
         name = 'Epic',
         color = '#FFD64E',
      },
   },
}
