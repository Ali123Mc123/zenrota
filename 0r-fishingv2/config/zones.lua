return {
   ---@type FishingZones[]
   FishingZones = { -- These zones are used for fishing locations
      {
         id = 1,
         coords = vec3(-1833.0, -1216.99, 13.02),
         radius = 100.0,
      },
      {
         id = 2,
         coords = vec3(-3336.9844, 6981.0464, 5.8383),
         radius = 200.0,
      },
   },

   ---@type BoatZones[]
   BoatZones = {                                   -- These zones are used for boat rental locations
      {
         coords = vec3(-1963.13, -1701.83, -0.32), -- Center coordinates of the zone
         radius = 200.0,                           -- Radius of the zone
         zones = {                                 -- IDs of fishing zones that can be accessed from this boat zone
            1,
            2,
         }
      },
      {
         coords = vec3(-2476.36, -1117.74, 1.06),
         radius = 150.0,
         zones = {
            1,
            2,
         }
      },
      {
         coords = vec3(-3258.19, -600.78, 0.65),
         radius = 200.0,
         zones = {
            2,
            3,
         }
      },
      {
         coords = vec3(-3617.81, -2.92, 1.26),
         radius = 200.0,
         zones = {
            2,
            3,
         }
      },
      {
         coords = vec3(-3744.3, 832.87, 0.45),
         radius = 200.0,
         zones = {
            3,
            4,
         }
      },
      {
         coords = vec3(-3686.5, 1134.05, 1.13),
         radius = 200.0,
         zones = {
            3,
            4,
         }
      },
      {
         coords = vec3(-2999.04, 4275.53, 1.16),
         radius = 200.0,
         zones = {
            3,
            4,
         }
      },
      {
         coords = vec3(-1569.75, 5748.67, 2.38),
         radius = 200.0,
         zones = {
            5,
         }
      },
      {
         coords = vec3(3376.71, -945.74, 1.54),
         radius = 200.0,
         zones = {
            6,
         }
      },
      {
         coords = vec3(-3328.3860, 6964.3062, 1.2057),
         radius = 250.0,
         zones = {
            2,
         }
      },
   },

   UnderwaterZones = {                           -- These zones are used for underwater fishing locations
      {
         coords = vec3(-929.52, 6666.6, -27.55), -- Center coordinates of the zone
         radius = 75.0,                          -- Radius of the zone
         zones = {                               -- IDs of fishing zones that can be accessed from this underwater zones
            3,
            4,
            5,
         }
      },
      {
         coords = vec3(-2797.48, -503.8, -55.4),
         radius = 75.0,
         zones = {
            1,
            2,
            3,
         }
      },
      {
         coords = vec3(3004.77, -75.68, -17.23),
         radius = 75.0,
         zones = {
            6,
         }
      },
   }
}
