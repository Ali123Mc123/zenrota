--[[
  PROMPT ARCADE — MASTER CABINET REGISTRY
  ---------------------------------------------------------------------------------------
  One entry per game. The framework reads ONLY this file to know what exists, how to
  interact with it (target), how to render it (glass), how to animate the player (ped),
  and how it plays (controls / players / sync). Add a game = add an entry here.

  Shared between client & server (loaded as a shared_script), so the server can validate
  results and broker 2-player sessions from the same source of truth.

  Field reference: see docs/ARCHITECTURE.md.
]]

Arc = Arc or {}

Arc.Config = {
  resource        = 'prompt_arcade_games',

  -- adapters (auto-detect, or pin explicitly)
  framework       = 'auto',     -- 'auto' | 'esx' | 'qb' | 'standalone'
  targetSystem    = 'auto',     -- 'auto' | 'ox_target' | 'qb-target'

  -- defaults applied when a cabinet omits the field
  defaults = {
    targetDistance = 1.8,
    targetIcon     = 'fa-solid fa-gamepad',
    findRange      = 12.0,       -- how far to look for a placed cabinet
    spawnForward   = 0.9,        -- test-spawn distance in front of player when none placed
    headingFix     = 180.0,      -- test-spawn heading offset so the screen faces the player
    cooldown       = 1500,       -- ms after a game before the same cabinet re-triggers
    duiTimeout     = 10000,      -- ms to wait for the DUI to become available
    duiIdleMs      = 60000,      -- destroy a game's cached browser after this long unused
                                 -- (frees RAM; next play recreates it seamlessly). 0 = keep forever
  },

  debug = false,                 -- enables /<game>dbg fullscreen test commands + verbose logs
                                -- >>> SET TO false FOR PRODUCTION RELEASE <<<

  -- ---- LANGUAGE ----------------------------------------------------------------------------
  -- Ships with: en, de, es, fr, pt, ru  (locales/<code>.lua).
  -- Add your own: copy locales/en.lua -> locales/<code>.lua, translate the values, set it here.
  -- Any string a translation is missing automatically falls back to English, so a partial
  -- translation never shows a blank or a raw key.
  language = 'tr',

  -- Override individual strings WITHOUT touching the locale files (applied on top of the
  -- chosen language). Handy for renaming one cabinet or re-wording a single prompt:
  --   Locale = { menu_play = '[E] START', target_claw = 'Try the claw' },
  Locale = {},

  -- ---- TEXT UI -----------------------------------------------------------------------------
  -- The built-in interaction prompt, used ONLY when neither ox_target nor qb-target is
  -- installed (with a target system the cabinets use that instead). No ox_lib required.
  textUI = {
    enabled = 'auto',   -- 'auto' (only without a target system) | true (always) | false (never)
    key     = 38,       -- interaction control (38 = [E])
    style   = 'help',   -- 'help' = native GTA help box (top-left) | 'text' = centred bottom text
    range   = 2.0,      -- (m) how close the prompt appears
    -- Route the prompt to YOUR TextUI instead (ox_lib, qbcore, jg, custom HUD...).
    -- Called as custom(true, 'Play Space Monkey') to show and custom(false) to hide.
    -- custom = function(show, label)
    --   if show then exports.ox_lib:showTextUI(label) else exports.ox_lib:hideTextUI() end
    -- end,
    custom = nil,
  },

  -- ---- NOTIFICATIONS -----------------------------------------------------------------------
  -- Every player-facing message goes through ONE function. By default it uses the native GTA
  -- feed ticker. To match YOUR server's HUD, set `custom` to a function that shows the message
  -- your way — colour codes are stripped before it's called. Examples (uncomment ONE):
  notification = {
    custom = nil,
    -- ox_lib:
    -- custom = function(msg) exports.ox_lib:notify({ description = msg, type = 'inform' }) end,
    -- QBCore:
    -- custom = function(msg) exports['qb-core']:GetCoreObject().Functions.Notify(msg, 'primary') end,
    -- ESX:
    -- custom = function(msg) exports.esx:ShowNotification(msg) end,
    -- your custom HUD (use your resource name + export):
    -- custom = function(msg) exports['my_hud']:AddNotification(msg) end,
  },

  -- ---- LEADERBOARDS ------------------------------------------------------------------------
  -- Per-game high-score / win tables, persisted to FiveM KVP (survives restarts, no DB needed).
  -- A game gets a board only if its cabinet entry below has a `score = { track=true, ... }`.
  -- Read them from YOUR resource via exports — see server/leaderboard.lua header for the list.
  leaderboard = {
    enabled  = true,
    keep     = 25,        -- how many top entries to retain per game
    resetKvp = false,     -- set true + restart ONCE to WIPE every stored board, then set back to false
    -- Custom NAME on the board (e.g. from a statebag or your own character format). Return a
    -- non-empty string to use it; return nil to keep the default (QB/ESX character name).
    -- resolveName = function(src) return Player(src).state.charName end,
    resolveName = nil,
  },

  -- ---- PAY-PER-PLAY ------------------------------------------------------------------------
  -- Charge players to start a game. ONE price for every cabinet (override a single cabinet by
  -- adding `price = 50` to its entry below). 2-player games: each player pays their own fee;
  -- the Love Tester charges both players when the test pairs. Money is taken SERVER-side and a
  -- start that wasn't paid gets no anti-cheat session, so it can never earn a reward or a board
  -- entry. With no framework and no `custom` hook (standalone) play is free.
  payment = {
    enabled = false,
    price   = 20,
    account = 'cash',     -- QBCore: 'cash' | 'bank'    ESX: 'cash' (= money) | 'bank'
    -- Take the money YOUR way (any framework / currency / item) — return true if paid.
    -- Called on the SERVER as custom(src, amount, gameId, account).
    -- custom = function(src, amount, gameId, account)
    --   return exports.ox_inventory:RemoveItem(src, 'money', amount)
    -- end,
    custom = nil,
  },
  -- Server event on every successful charge (route arcade income to a business, log it, ...):
  --   AddEventHandler('prompt_arcade_games:onPaid', function(src, amount, gameId, account) end)

  -- ---- SERVER-SIDE RESULT VALIDATION (anti-cheat) -----------------------------------------
  -- A score / claw win is accepted (rewarded + put on the board) ONLY if it passes these gates.
  -- Without this, any client can inject any score from anywhere. Turn off only for debugging.
  security = {
    validate       = true,   -- master switch for all checks below
    requireSession = true,   -- result counts only if the server saw the player START at a cabinet
    maxStartDist   = 6.0,    -- (m) player must be this close to the claimed cabinet when starting
    minPlayMs      = 2000,   -- reject "runs" that finish faster than this (instant-win injection)
    resultCooldown = 2500,   -- (ms) minimum gap between accepted results from one player
    maxScore       = 10000000, -- absolute sanity ceiling; per-game override via cabinet.score.max
  },
}

-- ===========================================================================================
--  CABINETS
--  kind     : 'screen' (DUI on glass) | 'physical' (synced-scene, no screen)
--  players  : 1 | 2          sync: 'split' (host-auth split-screen) | 'occupancy' (love)
--  glass    : { mode = 'replace' | 'rendertarget' | 'fullscreen', ... }
--    replace      -> activeModel (custom clean-screen prop) + txd/tex to AddReplaceTexture
--    rendertarget -> rtName (engine script_rt name, prefix stripped)
--  dui      : { html, w, h }  ped: { dict, enter, idle, enterMs }
--  controls : map of logical key -> { control ids } forwarded to the DUI each frame
-- ===========================================================================================
Arc.Cabinets = {

  -- ---- SCREEN GAMES (custom-prop on-glass) -------------------------------------------------

  space = {
    title='Space Monkey', kind='screen', players=1, enabled=true, fw=true,
    models = { `ch_prop_arcade_space_01a` },
    glass  = { mode='replace', activeModel=`prompt_corenr_ch_prop_arcade_space_01a`,
               txd='prompt_corenr_ch_prop_arcade_space_01a', tex='gamestarts_512', split=false },
    dui    = { html='html/space.html', w=1024, h=768 },
    ped    = { dict='anim_heist@arcade@shared@male@left@', enter='enter', idle='playidle', enterMs=1100 },
    controls = { left={174,34}, right={175,35}, fire={38,22}, bomb={21} },
    target = { label='Play Space Monkey', icon='fa-solid fa-meteor' },
    score  = { track=true, kind='high', max=1000000 },   -- high-score leaderboard
  },

  wizard = {
    title="The Wizard's Ruin", kind='screen', players=1, enabled=true, fw=true,
    models = { `ch_prop_arcade_wizard_01a` },
    glass  = { mode='replace', activeModel=`prompt_corenr_ch_prop_arcade_wizard_01a`,
               txd='prompt_corenr_ch_prop_arcade_wizard_01a', tex='gamestarts_512', split=false },
    dui    = { html='html/wizard.html', w=1280, h=720 },
    ped    = { dict='anim_heist@arcade@shared@male@left@', enter='enter', idle='playidle', enterMs=1100 },
    controls = { left={174,34}, right={175,35}, up={172,32,22}, attack={38} },
    target = { label="Play The Wizard's Ruin", icon='fa-solid fa-hat-wizard' },
    score  = { track=true, kind='high', max=1000000 },   -- high-score leaderboard
  },

  -- ---- SCREEN GAMES, 2-PLAYER SPLIT (new finalized props: prompt_corner_ + half/half UV) ----

  badlands = {
    title='Badlands Revenge', kind='screen', players=2, sync='split', enabled=true, fw=true,
    models = { `ch_prop_arcade_gun_01a` },
    glass  = { mode='replace', activeModel=`prompt_corner_ch_prop_arcade_gun_01a`,
               txd='prompt_corner_ch_prop_arcade_gun_01a', tex='badlandrevenge_1024',
               split='shared' },  -- gallery shooter: both halves show the same scene + both crosshairs
    dui    = { html='html/badlands.html', w=1024, h=768 },
    -- 2-seat light-gun: player 1 uses the left@ dict, player 2 the right@ dict. Each dict's baked
    -- root places the ped on its own slot (same as Love Tester's dictL/dictR) — no offset needed.
    ped    = { dict='anim_heist@arcade@light_gun@male@left@', dictR='anim_heist@arcade@light_gun@male@right@', enter='enter', idle='aimidle', enterMs=1100 },
    input  = 'cursor',           -- aim via NUI cursor -> normalized aim, fire/reload/special buttons
    controls = { fire={24,38}, reload={45,73}, special={22,21} },
    target = { label='Play Badlands Revenge', icon='fa-solid fa-gun' },
    -- per-player cabinet-LOCAL camera (authored with /arccam badlands p1|p2). rot = pitch, roll,
    -- yawDelta (yaw RELATIVE to the cabinet heading). solo/host -> p1, guest -> p2.
    cam = {
      p1 = { pos = vector3(-0.5262, -0.0870, 1.3708), rot = vector3(-0.61, 0.0, -1.58), fov = 48.0 },
      p2 = { pos = vector3( 0.5055, -0.0964, 1.3396), rot = vector3( 1.23, 0.0,  0.27), fov = 50.0 },
    },
    score = { track=true, kind='high', max=1000000 },    -- co-op: each player's run is recorded
  },

  rockets = {
    title='Race and Chase: Crotch Rockets', kind='screen', players=2, sync='split', enabled=true, fw=true,
    models = { `ch_prop_arcade_race_02a` },
    glass  = { mode='replace', activeModel=`prompt_corner_ch_prop_arcade_race_02a`,
               txd='prompt_corner_ch_prop_arcade_race_02a', tex='raceandchace_1024', split='vertical' },
    dui    = { html='html/race_rockets.html', w=1280, h=720 },
    -- 2-SEAT double cabinet (verified in-game: race_01a/01b/02a are ~2.6m X-centred linked pairs).
    -- P1 sits on the LEFT unit at the clip's authored root; P2 is offset to the RIGHT unit by `seat`
    -- (= 2x P1's measured lateral root). rockets = standup BIKE dict; street/truckin = sit-down CAR dict.
    ped    = { dict='anim_heist@arcade@driving@bike@male@', enter='idle_to_race', idle='racing', enterMs=900, seat=1.242 },
    controls = { accel={71,172,32}, brake={72,173,33}, left={174,34}, right={175,35}, special={22,21} },
    target = { label='Play Crotch Rockets', icon='fa-solid fa-motorcycle' },
    score  = { track=true, kind='high', max=1000000 },   -- high-score leaderboard
  },

  truckin = {
    title="Race and Chase: Get Truckin'", kind='screen', players=2, sync='split', enabled=true, fw=true,
    models = { `ch_prop_arcade_race_01b` },
    glass  = { mode='replace', activeModel=`prompt_corner_ch_prop_arcade_race_01b`,
               txd='prompt_corner_ch_prop_arcade_race_01b', tex='raceandchace_1024', split='vertical' },
    dui    = { html='html/race_truckin.html', w=1280, h=720 },
    ped    = { dict='anim_heist@arcade@driving@car@male@', enter='idle_to_race', idle='racing_b', enterMs=900, seat=1.276 },  -- sit-down CAR/truck cabinet (clip racing_b)
    controls = { accel={71,172,32}, brake={72,173,33}, left={174,34}, right={175,35}, special={22,21} },
    target = { label="Play Get Truckin'", icon='fa-solid fa-truck' },
    score  = { track=true, kind='high', max=1000000 },   -- high-score leaderboard
  },

  street = {
    title='Race and Chase: Street Legal', kind='screen', players=2, sync='split', enabled=true, fw=true,
    models = { `ch_prop_arcade_race_01a` },
    glass  = { mode='replace', activeModel=`prompt_corner_ch_prop_arcade_race_01a`,
               txd='prompt_corner_ch_prop_arcade_race_01a', tex='raceandchace_1024', split='vertical' },
    dui    = { html='html/race_street.html', w=1280, h=720 },
    ped    = { dict='anim_heist@arcade@driving@car@male@', enter='idle_to_race', idle='racing_a', enterMs=900, seat=1.276 },  -- sit-down CAR cabinet (clip racing_a)
    controls = { accel={71,172,32}, brake={72,173,33}, left={174,34}, right={175,35}, special={22,21} },
    target = { label='Play Street Legal', icon='fa-solid fa-car-side' },
    score  = { track=true, kind='high', max=1000000 },   -- high-score leaderboard
  },

  -- ---- SCREEN GAME, 2-PLAYER OCCUPANCY (love tester — already shipped, its own model) -------

  love = {
    title='Love Tester', kind='screen', players=2, sync='occupancy', enabled=true, fw=true,
    models = { `ch_prop_arcade_love_01a` },
    glass  = { mode='rendertarget', rtName='arc_love_01a' },
    dui    = { html='html/love.html', w=512, h=1024 },
    ped    = { dictL='anim_heist@arcade@love@male@left@', dictR='anim_heist@arcade@love@male@right@' },
    occupancy = { sideOffset=0.32, slotForward=0.55, slotRadius=0.85, scanWait=350, cooldown=5000 },
    target = { label='Test your love', icon='fa-solid fa-heart' },
  },

  -- ---- PHYSICAL GAMES (synced-scene, no screen) --------------------------------------------

  claw = {
    title='Claw Machine', kind='physical', players=1, enabled=true, fw=true,
    models = { `ch_prop_arcade_claw_01a` },
    ped    = { dict='anim_heist@arcade@claw@male@' },
    controls = { up={172,32}, down={173,33}, left={174,34}, right={175,35}, grab={22,38}, exit={177,202} },
    target = { label='Play the claw machine', icon='fa-solid fa-hand' },
    score  = { track=true, kind='wins' },                -- leaderboard = most figurines won
  },

  strength = {
    -- This is the "Axe of Fury" hammer cabinet. DISABLED for now (kept in code) — its hammer/swing
    -- still needs work and you don't have time. Flip enabled=true to bring it back later.
    title='Strength Tester', kind='physical', players=1, enabled=false, fw=true,
    models = { `sum_prop_arcade_strength_01a` },
    ped    = { dict='anim_heist@arcade@strength@male@' },
    controls = { power={38} },
    target = { label='Test your strength', icon='fa-solid fa-hammer' },
  },

  fortune = {
    title='Nazar the Fortune Teller', kind='physical', players=1, enabled=true, fw=true,
    models = { `ch_prop_arcade_fortune_01a` },
    ped    = { dict='anim_heist@arcade@fortune@male@' },
    target = { label='Ask Nazar your fortune', icon='fa-solid fa-wand-sparkles' },
    -- ---- NAZAR'S FORTUNES (edit/translate/add freely) ---------------------------------------
    -- text   : what Nazar says (shown to the player)
    -- mood   : his reaction animation — MUST be one of:
    --          'amused' | 'pondering' | 'surprised' | 'confused' | 'disgusted' | 'insulted' | 'angry'
    --          (an unknown mood safely falls back to 'pondering')
    -- rarity : 0-100 quality value (flavour only)
    -- rare   : true = golden omen — drawn very rarely, with a longer build-up flourish
    fortunes = {
      -- GOOD (lucky / uplifting)
      { text = "Talih senden yana — dolacak boş bir cebin hazır olsun.",    mood = 'amused',    rarity = 86, rare = false },
      { text = "Unuttuğun küçük bir iyilik sana on katıyla dönecek.",           mood = 'amused',    rarity = 78, rare = false },
      { text = "Sabır bu hafta borcunu ödüyor. Dayan.",                mood = 'pondering', rarity = 70, rare = false },
      { text = "Kaybettiğin bir şey geri dönüyor — hafifçe deniz kokarak.",       mood = 'surprised', rarity = 74, rare = false },
      { text = "Kapandı sandığın bir kapı sadece kapıyı çalmanı bekliyor.",         mood = 'pondering', rarity = 66, rare = false },
      -- OMINOUS (warnings / dark)
      { text = "Salı günü biraz fazla geniş gülümseyen dosttan sakın.",      mood = 'confused',  rarity = 40, rare = false },
      { text = "Eski bir kin karanlıkta kıpırdanıyor. Merhameti seç; daha çok kazandırır.",  mood = 'insulted',  rarity = 33, rare = false },
      { text = "Cam bulanıyor. Kendine güçlü bir düşman edindin.",          mood = 'angry',     rarity = 15, rare = false },
      { text = "Küçülen ay altında imzalanan hiçbir sözleşmeye güvenme.",                   mood = 'disgusted', rarity = 26, rare = false },
      { text = "Şansını bir gölge takip ediyor. Kaybetmeyi göze alamayacağın şeyle kumar oynama.", mood = 'confused',  rarity = 30, rare = false },
      -- FUNNY (cheeky / absurd)
      { text = "Arabanı Dave adında kimseye ödünç verme. Ruhlar ısrar ediyor.",  mood = 'disgusted', rarity = 22, rare = false },
      { text = "Büyük servet yakın, ama bir park cezası da öyle. Kader bu.", mood = 'amused',    rarity = 55, rare = false },
      { text = "Yakında bir atıştırmalıktan pişman olacaksın. Kartlar hangisi olduğunu söylemiyor.",   mood = 'disgusted', rarity = 38, rare = false },
      -- CRYPTIC (riddles)
      { text = "Anahtarlarını say. Biri henüz bulmadığın bir kilidi açıyor.",       mood = 'pondering', rarity = 50, rare = false },
      { text = "Üçüncü zil çaldığında sol elinle cevap ver.",          mood = 'surprised', rarity = 44, rare = false },
      -- RARE (golden omens — drawn very rarely)
      { text = "Yıldızlar hizalandı — BÜYÜK bir şans yolunu taçlandırıyor!",    mood = 'amused',    rarity = 99, rare = true  },
      { text = "Camdan altın bir el uzanıyor. Bu günü yakala!",           mood = 'surprised', rarity = 96, rare = true  },
    },
  },
}

-- Resolve a cabinet's effective field, falling back to Arc.Config.defaults.
function Arc.cabinetDefault(field)
  return Arc.Config.defaults[field]
end

-- ===========================================================================================
--  LANGUAGE LOADER  (runs on both client and server — config.lua is a shared_script)
--  English is always loaded first as the base, then the chosen language is layered on top,
--  then any Arc.Config.Locale overrides written above. Missing keys therefore fall back to
--  English instead of showing a blank or a raw key name.
-- ===========================================================================================
do
  local function loadLocale(code)
    local raw = LoadResourceFile(GetCurrentResourceName(), 'locales/' .. code .. '.lua')
    if not raw then return nil, 'not found' end
    local fn, err = load(raw, '@locales/' .. code .. '.lua')
    if not fn then return nil, 'syntax error: ' .. tostring(err) end
    local ok, tbl = pcall(fn)
    if not ok or type(tbl) ~= 'table' then return nil, 'did not return a table' end
    return tbl
  end

  local merged = loadLocale('en') or {}
  local lang   = Arc.Config.language

  if lang and lang ~= 'en' then
    local tbl, err = loadLocale(lang)
    if tbl then
      for k, v in pairs(tbl) do merged[k] = v end
    else
      print(('^3[arcade] locales/%s.lua %s — using English^0'):format(tostring(lang), tostring(err)))
    end
  end

  for k, v in pairs(Arc.Config.Locale or {}) do merged[k] = v end   -- inline overrides win
  Arc.Config.Locale = merged

  -- Cabinet titles + interaction labels come from the locale ONLY when a non-English language
  -- is selected. On 'en' the values authored in Arc.Cabinets above are kept untouched, so
  -- servers that renamed a cabinet by hand keep their wording after updating.
  if lang and lang ~= 'en' then
    for id, c in pairs(Arc.Cabinets) do
      local t = merged['title_' .. id]
      if t then c.title = t end
      local l = merged['target_' .. id]
      if l then c.target = c.target or {}; c.target.label = l end
    end
  end
end
