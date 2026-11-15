-- Debug only (Config.Debug, anyone while it is on): /daddyfx shows the props, particles, sounds and clips a coming feature
-- may use, one by one in front of the player, and prints which of them the game has. Nothing is networked.
if Config.Debug ~= true then return end

local HOLD = 3000

local PROPS = {
    'v_serv_wetfloorsn', 'v_34_puddle', 'ng_proc_sodacan_01a', 'ng_proc_litter_plasbot1', 'ng_proc_paper_02a',
    'ng_proc_food_bag01a', 'm23_2_prop_m32_puddle_01a', 'm23_2_prop_m32_bucket_mop_01a',
    'ch_prop_ch_metal_detector_01a', 'ch_prop_baggage_scanner_01a', 'ch_prop_ch_fuse_box_01a',
    'prop_tree_birch_05', 'h4_prop_tree_umbrella_sml_01', 'prop_plant_int_03a', 'prop_cork_board', 'xs_prop_arena_stickynote_01a',
    'prop_shelves_01', 'prop_ff_counter_01', 'prop_till_01', 'prop_cs_shopping_bag', 'prop_table_03', 'm24_1_prop_m41_nameplate_01a',
    'gr_prop_bunker_bed_01', 'm25_1_prop_m51_wardrobe_01a', 'm25_2_prop_m52_plaque_01a', 'apa_mp_h_floorlamp_c',
}
local PEDS, VEHICLES = { 'a_c_rat' }, { 'mower' }
local PARTICLES = {
    { 'core', 'ent_sht_water' }, { 'core', 'ent_amb_waterfall_splash_p' }, { 'core', 'ent_brk_sparking_wires' },
    { 'core', 'ent_dst_elec_fire_sp' }, { 'core', 'ent_dst_dust' }, { 'core', 'ent_dst_gen_grass' },
}
local SOUNDS = {
    { 'Beep_Green', 'DLC_HEIST_HACKING_SNAKE_SOUNDS' }, { 'Beep_Red', 'DLC_HEIST_HACKING_SNAKE_SOUNDS' },
    { 'Power_Down', 'DLC_HEIST_HACKING_SNAKE_SOUNDS' }, { 'Text_Arrive_Tone', 'Phone_SoundSet_Default' },
}
local CLIPS = {
    { 'anim@scripted@freemode@ig13_mop_floor@male@', 'action' }, { 'amb@world_human_janitor@male@base', 'base' },
    { 'pickup_object', 'pickup_low' }, { 'anim@heists@box_carry@', 'idle' },
    { 'anim@scripted@freemode@ig11_valve_turn@male@', 'action' }, { 'anim@scripted@bty3@ig3_hand_fusebox@male@', 'shock_a' },
    { 'anim@gangops@facility@servers@bodysearch@', 'player_search' }, { 'missfinale_c2ig_11', 'pushcar_offcliff_m' },
    { 'missheistfbisetup1', 'unlock_loop_janitor' }, { 'amb@prop_human_parking_meter@male@base', 'base' },
    { 'mp_common', 'givetake1_a' }, { 'oddjobs@shop_robbery@rob_till', 'loop' }, { 'anim@heists@keycard@', 'exit' },
}
-- The school newspaper: copies, stacks, racks and desk props, then reading and writing clips.
local PAPER = {
    props = {
        'prop_cs_newspaper', 'prop_cs_rolled_paper', 'prop_cs_magazine', 'p_cs_paper_disp_1', 'p_cs_paper_disp_02',
        'm25_1_prop_m51_paper_news_quik', 'sum_prop_ac_papers_01a', 'bkr_prop_prtmachine_paperream', 'h4_prop_h4_pile_letters_01a',
        'prop_news_disp_01a', 'prop_news_disp_02a', 'prop_news_disp_03a', 'prop_news_disp_05a', 'prop_news_disp_06a',
        'p_cs_clipboard', 'prop_notepad_01',
    },
    clips = { { 'amb@world_human_tourist_map@male@base', 'base' }, { 'amb@world_human_clipboard@male@base', 'base' } },
}

-- The CPR and chemistry stations (docs/yeni-sistemler/10-cpr-deney.md section 7): every effect and clip their config
-- uses, the effects still to come, and the GTA sound they use for now. Effects start the way the stations start them.
local STATION_FX = {
    { 'core', 'liquid_splash_water' }, { 'core', 'ent_amb_candle_flame' }, { 'core', 'ent_amb_sparking_wires' },
    { 'scr_fbi5a', 'scr_fbi5_dry_ice' },
}
local function stations()
    local fx, clips, seen = {}, {}, {}
    local function add(list, a, b)
        if not a or not b or seen[a .. '/' .. b] then return end
        seen[a .. '/' .. b] = true
        list[#list + 1] = { a, b }
    end
    for _, kind in pairs((Config.Practicals or {}).Kinds or {}) do
        for _, def in pairs(kind.Fx or {}) do
            add(fx, def.asset, def.name)
            add(fx, def.asset, def.fallback)
        end
        for _, def in pairs(kind.Anims or {}) do
            add(clips, def.dict, def.clip)
            add(clips, def.female, def.clip)
        end
    end
    for _, p in ipairs(STATION_FX) do add(fx, p[1], p[2]) end
    return fx, clips
end

local results, current = {}, nil

local function note(kind, name, ok)
    current = ('%s %s: %s'):format(kind, name, ok and '~g~ok' or '~r~missing')
    results[#results + 1] = ('%s %s %s'):format(ok and '[ok]     ' or '[missing]', kind, name)
    print(('^%d[daddyfx] %s %s: %s^7'):format(ok and 2 or 1, kind, name, ok and 'ok' or 'missing'))
end

-- A spot two metres ahead on the ground.
local function ahead()
    local ped = cache.ped
    local at = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0)
    local found, z = GetGroundZFor_3dCoord(at.x, at.y, at.z + 1.0, false)
    return vector3(at.x, at.y, found and z or at.z - 1.0), GetEntityHeading(ped)
end

local function loaded(hash)
    if not IsModelInCdimage(hash) then return false end
    RequestModel(hash)
    local limit = GetGameTimer() + 5000
    while not HasModelLoaded(hash) and GetGameTimer() < limit do Wait(0) end
    return HasModelLoaded(hash)
end

-- Spawns a local copy for a moment and reports whether it stood in the world.
local function show(kind, name)
    local hash = joaat(name)
    if not loaded(hash) then return note(kind, name, false) end
    local at, heading = ahead()
    pcall(function() exports['FeloxAC']:CreatePed(hash) end) --[[FeloxAC:auto]]
    local entity = kind == 'ped' and CreatePed(28, hash, at.x, at.y, at.z, heading, false, false)
        or kind == 'vehicle' and CreateVehicle(hash, at.x, at.y, at.z, heading, false, false)
        or CreateObject(hash, at.x, at.y, at.z, false, false, false)
    SetModelAsNoLongerNeeded(hash)
    local ok = DoesEntityExist(entity)
    if ok and kind == 'prop' then PlaceObjectOnGroundProperly(entity) end
    note(kind, name, ok)
    Wait(HOLD)
    if ok then DeleteEntity(entity) end
end

local function particle(asset, name)
    RequestNamedPtfxAsset(asset)
    local limit = GetGameTimer() + 5000
    while not HasNamedPtfxAssetLoaded(asset) and GetGameTimer() < limit do Wait(0) end
    local at = ahead()
    UseParticleFxAsset(asset)
    local handle = StartParticleFxLoopedAtCoord(name, at.x, at.y, at.z + 0.5, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    note('particle', asset .. '/' .. name, handle ~= 0)
    Wait(HOLD)
    if handle ~= 0 then StopParticleFxLooped(handle, false) end
end

-- Sounds cannot report themselves: each plays after its name, the listener decides.
local function sound(name, set)
    current = ('sound %s / %s: ~y~listen'):format(name, set)
    print(('^3[daddyfx] sound %s / %s: listen^7'):format(name, set))
    local id, at = GetSoundId(), ahead()
    PlaySoundFromCoord(id, name, at.x, at.y, at.z, set, false, 20, false)
    Wait(HOLD)
    StopSound(id)
    ReleaseSoundId(id)
    results[#results + 1] = ('[listen]   sound %s / %s'):format(name, set)
end

local function clip(dict, name)
    local ok = DoesAnimDictExist(dict)
    if ok then
        RequestAnimDict(dict)
        local limit = GetGameTimer() + 5000
        while not HasAnimDictLoaded(dict) and GetGameTimer() < limit do Wait(0) end
        TaskPlayAnim(cache.ped, dict, name, 4.0, 4.0, HOLD, 0, 0.0, false, false, false)
        Wait(HOLD)
        ClearPedTasks(cache.ped)
        RemoveAnimDict(dict)
    end
    note('clip', dict .. ' / ' .. name, ok)
end

local GROUPS = {
    props = function() for _, name in ipairs(PROPS) do show('prop', name) end end,
    peds = function() for _, name in ipairs(PEDS) do show('ped', name) end end,
    vehicles = function() for _, name in ipairs(VEHICLES) do show('vehicle', name) end end,
    fx = function() for _, p in ipairs(PARTICLES) do particle(p[1], p[2]) end end,
    sounds = function() for _, s in ipairs(SOUNDS) do sound(s[1], s[2]) end end,
    clips = function() for _, c in ipairs(CLIPS) do clip(c[1], c[2]) end end,
    paper = function()
        for _, name in ipairs(PAPER.props) do show('prop', name) end
        for _, c in ipairs(PAPER.clips) do clip(c[1], c[2]) end
    end,
    practicals = function()
        local fx, clips = stations()
        for _, p in ipairs(fx) do particle(p[1], p[2]) end
        for _, s in pairs((Config.Practicals or {}).Sounds or {}) do sound(s.name, s.set) end
        for _, c in ipairs(clips) do clip(c[1], c[2]) end
    end,
}
local ORDER = { 'props', 'peds', 'vehicles', 'fx', 'sounds', 'clips', 'paper', 'practicals' }

local running = false

-- /daddyfx [props|peds|vehicles|fx|sounds|clips|paper|practicals]; no group runs them all.
local function say(text, kind) lib.notify({ title = 'daddyfx', description = text, type = kind or 'inform' }) end

-- What is being tried now, on screen while it runs (the full list goes to F8).
local function caption()
    while running do
        SetTextFont(4)
        SetTextScale(0.0, 0.5)
        SetTextCentre(true)
        SetTextOutline()
        BeginTextCommandDisplayText('STRING')
        AddTextComponentSubstringPlayerName('daddyfx  ' .. (current or '...'))
        EndTextCommandDisplayText(0.5, 0.06)
        Wait(0)
    end
end

RegisterCommand('daddyfx', function(_, args)
    if running then return say('Already running.', 'error') end
    CreateThread(function()
        local group = args[1]
        if group and not GROUPS[group] then return say('Groups: ' .. table.concat(ORDER, ' '), 'error') end
        running, results, current = true, {}, nil
        say('Started: watch two metres in front of you. The summary goes to F8.')
        CreateThread(caption)
        for _, name in ipairs(group and { group } or ORDER) do GROUPS[name]() end
        print('[daddyfx] summary:')
        for _, line in ipairs(results) do print('  ' .. line) end
        running = false
        local missing = 0
        for _, line in ipairs(results) do if line:find('missing') then missing = missing + 1 end end
        say(('Done: %s checked, %s missing. Details in F8.'):format(#results, missing), missing > 0 and 'warning' or 'success')
    end)
end, false)
