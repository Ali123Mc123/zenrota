Config = {}

Config.Locale = 'tr'  -- en | tr
Config.Radius = 1.6   -- size of the [target] spot around each stop, in metres
Config.FadeMs = 500   -- screen fade out / in
Config.RideMs = 1200  -- time in the dark between floors
Config.LandMs = 5000  -- the longest the player is held still while the floor loads
Config.Sound = { name = 'FAKE_ARRIVE', set = 'MP_PROPERTIES_ELEVATOR_DOORS' } -- the elevator's ding on arrival (GTA's own); false = silent
Config.GuardMs = 4000 -- after arriving: a player dropping through a floor that loaded late is put back on the stop
Config.Marker = { distance = 15.0, size = 1.1, color = { 244, 242, 241, 150 } } -- a ring on the floor at each stop, seen from this far (m); false = none

-- Each elevator lists its floors top to bottom. coords = where the player stands (x, y, z, heading).
Config.Elevators = {
    {
        id = 'college',
        label = 'Kolej Asansörü',
        floors = {
            { label = '2. Kat', coords = vec4(5321.6270, -5247.9730, 43.8140, 329.49) },
            { label = '1. Kat', coords = vec4(5317.6750, -5227.8410, 37.9100, 254.91) },
            { label = 'Zemin Kat', coords = vec4(5317.5640, -5227.9380, 31.9940, 244.95) },
            { label = '-1. Kat', coords = vec4(5317.0220, -5227.8740, 26.1700, 236.56) },
            { label = '-2. Kat', coords = vec4(5318.6670, -5226.4740, 21.6470, 239.81) },
            { label = 'Tiyatro Salonu', coords = vec4(5297.6920, -5266.6230, 15.1120, 229.73) },
        },
    },
}
