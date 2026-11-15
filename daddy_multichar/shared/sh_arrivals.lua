-- What a character may be doing when the live spawn lands. Config.Spawn.Arrivals lists these by name per job, per
-- spawn kind and by default; it may also hold its own entries written the same way.
--   scenario = a GTA scenario | dict + clip (+ flag, prop = { model, bone, pos, rot }) an animation
--   walk = metres it walks into the point (angle: from how far aside; random 20-40 when left out)
--   next = what it does once there (a name or an entry), after a walk
--   ms = how long it plays (a walk adds its own time); exit = a scenario's way out (ms)
--   cam = shoulder | side | follow | wide (the framed shot); weight = how often (1)
--   sex = male | female, time = day | night, weather = rain | dry: only then
-- An entry the ped cannot play (a scenario of the other sex, a missing animation) is skipped for the next one.
Arrivals = Arrivals or {}

local PHONE = { model = 'prop_npc_phone_02', bone = 28422 }
local BOOK = { model = 'prop_novel_01', bone = 6286, pos = { 0.15, 0.03, -0.065 }, rot = { 0.0, 180.0, 90.0 } }
local UMBRELLA = { model = 'p_amb_brolly_01', bone = 57005, pos = { 0.15, 0.005, 0.0 }, rot = { 87.0, -20.0, 180.0 } }
local CLIPBOARD = { model = 'p_amb_clipboard_01', bone = 36029, pos = { 0.16, 0.08, 0.1 }, rot = { -130.0, -50.0, 0.0 } }

local TEXT = { dict = 'cellphone@', clip = 'cellphone_text_read_base' }
local CALL = { dict = 'cellphone@', clip = 'cellphone_call_listen_base' }
local SIP = { dict = 'amb@world_human_drinking@coffee@male@base', clip = 'base' }
local RADIO = { dict = 'random@arrests', clip = 'generic_radio_chatter' }
local NOTES = { dict = 'missfam4', clip = 'base' }

local function with(base, extra)
    local out = {}
    for k, v in pairs(base) do out[k] = v end
    for k, v in pairs(extra) do out[k] = v end
    return out
end

-- Everyday
Arrivals.phone = { scenario = 'WORLD_HUMAN_STAND_MOBILE', ms = 6500, cam = 'shoulder' }
Arrivals.phone_upright = { scenario = 'WORLD_HUMAN_STAND_MOBILE_UPRIGHT', ms = 6000, cam = 'shoulder' }
Arrivals.phone_walk = with(TEXT, { walk = 4.5, prop = PHONE, ms = 6000, cam = 'follow' })
Arrivals.call_walk = with(CALL, { walk = 4.5, prop = PHONE, ms = 6000, cam = 'side' })
Arrivals.walk_then_phone = { walk = 4.0, next = 'phone', ms = 0, cam = 'shoulder' }
Arrivals.coffee = { scenario = 'WORLD_HUMAN_AA_COFFEE', ms = 7500, exit = 2200, cam = 'side' }
Arrivals.smoke = { scenario = 'WORLD_HUMAN_SMOKING', ms = 5000, exit = 2000, cam = 'side', weather = 'dry' }
Arrivals.walk_then_smoke = { walk = 3.5, next = 'smoke', ms = 0, cam = 'side', weather = 'dry' }
Arrivals.map = { scenario = 'WORLD_HUMAN_TOURIST_MAP', ms = 6500, cam = 'shoulder' }
Arrivals.walk_then_map = { walk = 4.0, next = 'map', ms = 0, cam = 'shoulder' }
Arrivals.tourist_photo = { scenario = 'WORLD_HUMAN_TOURIST_MOBILE', ms = 6500, cam = 'shoulder', time = 'day' }
Arrivals.film = { scenario = 'WORLD_HUMAN_MOBILE_FILM_SHOCKING', ms = 6000, cam = 'shoulder' }
Arrivals.binoculars = { scenario = 'WORLD_HUMAN_BINOCULARS', ms = 7000, exit = 1800, cam = 'side', time = 'day', weather = 'dry' }
Arrivals.impatient = { scenario = 'WORLD_HUMAN_STAND_IMPATIENT', ms = 5500, cam = 'side' }
Arrivals.hang_out = { scenario = 'WORLD_HUMAN_HANG_OUT_STREET', ms = 6000, cam = 'wide' }
Arrivals.beer = { scenario = 'WORLD_HUMAN_DRINKING', ms = 7000, exit = 2000, cam = 'side', time = 'night' }
Arrivals.party = { scenario = 'WORLD_HUMAN_PARTYING', ms = 6000, cam = 'wide', time = 'night' }
Arrivals.walk = { walk = 5.0, ms = 5500, cam = 'follow' }
Arrivals.taxi = { taxi = { model = 'taxi', driver = 'a_m_y_stlat_01' }, ms = 14000, cam = 'wide', weight = 2 } -- full length only: a cab drops the character off
Arrivals.walk_by = { walk = 4.0, angle = 0, ms = 5000, cam = 'shoulder' }
Arrivals.umbrella_walk = with(SIP, { walk = 4.5, prop = UMBRELLA, ms = 6000, cam = 'follow', weather = 'rain', weight = 3 })
Arrivals.umbrella = with(SIP, { prop = UMBRELLA, ms = 6000, cam = 'shoulder', weather = 'rain', weight = 2 })
Arrivals.book_walk = with(TEXT, { walk = 4.5, prop = BOOK, ms = 6000, cam = 'follow' })
Arrivals.book = with(TEXT, { prop = BOOK, ms = 6000, cam = 'shoulder' })
Arrivals.musician = { scenario = 'WORLD_HUMAN_MUSICIAN', ms = 7000, exit = 1800, cam = 'side', weather = 'dry' }

-- Work
Arrivals.radio = with(RADIO, { flag = 49, ms = 5500, cam = 'shoulder' })
Arrivals.radio_walk = with(RADIO, { walk = 4.0, ms = 5500, cam = 'follow' })
Arrivals.cop_idle = { scenario = 'WORLD_HUMAN_COP_IDLES', ms = 6000, cam = 'side', sex = 'male' }
Arrivals.guard = { scenario = 'WORLD_HUMAN_GUARD_STAND', ms = 6000, cam = 'side' }
Arrivals.investigate = { scenario = 'CODE_HUMAN_POLICE_INVESTIGATE', ms = 6500, cam = 'shoulder' }
Arrivals.torch = { scenario = 'WORLD_HUMAN_SECURITY_SHINE_TORCH', ms = 6500, cam = 'side', time = 'night' }
Arrivals.clipboard = { scenario = 'WORLD_HUMAN_CLIPBOARD', ms = 6500, cam = 'shoulder' }
Arrivals.clipboard_walk = with(NOTES, { flag = 49, walk = 4.0, prop = CLIPBOARD, ms = 5500, cam = 'follow' })
Arrivals.medic_notes = { scenario = 'CODE_HUMAN_MEDIC_TIME_OF_DEATH', ms = 6500, cam = 'side' }
Arrivals.drill = { scenario = 'WORLD_HUMAN_CONST_DRILL', ms = 6000, cam = 'side', sex = 'male' }
Arrivals.leaf_blower = { scenario = 'WORLD_HUMAN_GARDENER_LEAF_BLOWER', ms = 6500, cam = 'side', time = 'day' }
Arrivals.janitor = { scenario = 'WORLD_HUMAN_JANITOR', ms = 6500, cam = 'side' }
Arrivals.valet = { scenario = 'WORLD_HUMAN_CAR_PARK_ATTENDANT', ms = 6000, cam = 'side' }
Arrivals.paparazzi = { scenario = 'WORLD_HUMAN_PAPARAZZI', ms = 6500, cam = 'shoulder' }
Arrivals.flex = { scenario = 'WORLD_HUMAN_MUSCLE_FLEX', ms = 6000, cam = 'side', sex = 'male' }
Arrivals.dealer = { scenario = 'WORLD_HUMAN_DRUG_DEALER', ms = 6000, cam = 'side', sex = 'male' }
