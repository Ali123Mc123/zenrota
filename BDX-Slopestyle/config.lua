--------------------------------------
-- <!>--    BODHIX | STUDIO     --<!>--
--------------------------------------
--------------------------------------
-- <!>--   SLOPSTYLE | CAREER  --<!>--
--------------------------------------
-- Support & Feedback: https://discord.com/invite/bodhix

Config = {}

Config.Debug                            = false         -- Whether debug information is printed in your console or above radar
Config.Target                           = 'ox'          -- 'ox' | 'qb' | 'none' (floating 3D text + E key)

-- How to jump — Ollie vs Nollie:

-- 1. Press SPACE to jump. The default jump is an OLLIE — the slopstyle pivots
--    from the REAR wheel (front wheel pops up first).
-- 2. Hold CTRL at the moment of the jump to turn it into a NOLLIE — the bike
--    pivots from the FRONT wheel instead (rear wheel pops up first).

--  How to perform tricks (while in air):
--  1. Hold Left Click, Right Click, or Both to select trick variation
--  2. Flick mouse in a direction (left/right/up/down) while holding click
--  3. Maintain for doubles (e.g. Barspin x2) or hold for longer tricks
--     (e.g. Tailwhip loop while held)

--  SLOPSTYLE TRICK TABLE
--  ------------------------------------------------------------------------------------------
--  Flick Direction | LEFT Click             | RIGHT Click              | BOTH Clicks
--  ----------------|------------------------|--------------------------|------------------------
--  up              | Barspin Left  (hold)   | Barspin Right  (hold)    | No Hander      (press)
--  right           | Tobogan Left  (press)  | Tobogan Right  (press)   | Tailwhip Right (hold)
--  left            | One Hand Left (press)  | One Hand Right (press)   | Tailwhip Left  (hold)
--  down            | No Foot Can L (press)  | No Foot Can R  (press)   | Indian Air     (press)

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

-- Grinding, Wheelie, and Passenger systems were intentionally removed for
-- slopstyle — those configs no longer apply. If you ever re-enable them,
-- copy the relevant Config.* blocks from BDX-Bmx/config.lua.

Config.HUD                              = false    -- Whether the slopstyle HUD (score, trick names, input visualizer) is shown
Config.Language                         = 'tr'    -- Available: en, es, de, fr, it, pt, ru, tr, ar, zh, ja, ko, hi, pl, nl
