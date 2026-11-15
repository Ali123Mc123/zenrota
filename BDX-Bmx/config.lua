--------------------------------------
-- <!>--    BODHIX | STUDIO     --<!>--
--------------------------------------
--------------------------------------
-- <!>--      BMX | CAREER     --<!>--
--------------------------------------
-- Support & Feedback: https://discord.com/invite/bodhix

Config = {}

Config.Debug                            = false         -- Whether debug information is printed in your console or above radar
Config.Target                           = 'ox'          -- 'ox' | 'qb' | 'none' (floating 3D text + E key)

-- How to jump — Ollie vs Nollie:

-- 1. Press SPACE to jump. The default jump is an OLLIE — the BMX pivots from
--    the REAR wheel (front wheel pops up first).
-- 2. Hold CTRL at the moment of the jump to turn it into a NOLLIE — the BMX
--    pivots from the FRONT wheel instead (rear wheel pops up first).

--  How to perform tricks (while in air):
--  1. Hold Left Click, Right Click, or Both to select trick variation
--  2. Flick mouse in a direction (left/right/up/down) while holding click
--  3. Mantain for doubles or hold for longer tricks (e.g. Turndown)

--  BMX TRICK TABLE
--  ---------------------------------
--  Flick Direction   | LEFT Click       | RIGHT Click       | BOTH Clicks
--  ------------------|------------------|-------------------|----------------
--  left              | Tailwhip Left    | Invert            | HD Flip
--  right             | Eurotable        | Tailwhip Right    | Bri Flip
--  up                | Barspin          | Superman          | No Hander
--  down              | Turndown         | Crankflip         | Bike Flip

-- How to perform flips & combo spins (while airborne):

-- 1. Hold SHIFT before leaving the ground, then press W, S, or a two-key combo
-- 2. Release the direction key(s) to stop rotating and auto-align for landing
-- 3. Key ORDER matters for combos — the key held LONGEST is the "last" key

--  FLIP / COMBO TABLE
--  ---------------------------------------------
--  Input        | Trick
--  -------------|-------------------------------
--  W            | Frontflip
--  S            | Backflip
--  S then A     | Left Rodeo
--  S then D     | Right Rodeo
--  A then S     | Left Cashroll 540
--  D then S     | Right Cashroll 540
--  W then A     | Left Cork 720
--  W then D     | Right Cork 720
--  A then W     | Left Twister 720
--  D then W     | Right Twister 720

Config.InvertReverseSteering            = true
-- Reverse Ride: when riding backwards, invert left/right steering so the
-- bike behaves naturally from the rider's POV.

-- Grinding
Config.GrindKey                         = 38                                    -- Control ID used to initiate a grind (default 38 = E / INPUT_PICKUP). List: https://docs.fivem.net/docs/game-references/controls/
Config.GrindDetectDistance              = 1.0                                   -- Distance (meters) at which grindable rails/ledges are detected
Config.GrindZBump                       = 0.075                                 -- Extra meters added to the bike's Z while grinding. Positive raises it off the rail (visual fine-tune), 0 keeps the legacy -0.125 offset.

-- Grind sound per surface material. Keys are GTA material hashes (as
-- signed 32-bit integers — GTA hashes can be negative in Lua). Values are
-- "concrete", "metal", or "none" (no sound). The material determines which
-- WAV file is played via NUI (GrindConcrete.wav or GrindMetal.wav).
Config.GrindSounds = {
    [282940568]     = "concrete",   -- Tarmac
    [1187676648]    = "concrete",   -- Concrete
    [-426118011]    = "metal",      -- Metal Rail
    [-1775485061]   = "metal",      -- Rusty Metal Rail
    [1639053622]    = "concrete",   -- Brick (no grind sound)
    [581794674]     = "concrete",   -- Grass (shouldn't grind here anyway)
}
Config.GrindSoundDefault                = "concrete"                            -- Fallback when the surface material isn't in the table above

-- Wheelie (hold the key while rolling forward to pitch the BMX up)
Config.WheelieKey                       = 36                                    -- Control ID to hold for wheelie (default 36 = LEFT CTRL / INPUT_DUCK). List: https://docs.fivem.net/docs/game-references/controls/
Config.WheelieTargetPitch               = 45.0                                  -- Degrees the bike pitches to at full wheelie
Config.WheelieSmoothing                 = 0.05                                  -- Lerp factor toward target pitch (lower = slower ramp)
Config.WheelieMinSpeedKmh               = 3.5                                   -- Minimum speed (km/h) required to engage / sustain the wheelie

-- Passenger (ride along on someone else's BMX pegs)
Config.PassengerKey                     = 23                                    -- Control ID to mount/dismount (default 23 = F / INPUT_ENTER)
Config.PassengerRadius                  = 5.0                                   -- Search radius (meters) for nearby ridden BMX
Config.PassengerOffset                  = vector3(0.0, -0.50, 0.80)             -- Attachment offset relative to rider's BMX (behind + above pegs)

Config.HUD                              = true                                  -- Whether the BMX HUD (score, trick names, input visualizer) is shown
Config.Language                         = 'tr'                                  -- Available: en, es, de, fr, it, pt, ru, tr, ar, zh, ja, ko, hi, pl, nl
