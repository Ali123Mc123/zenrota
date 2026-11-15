shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Prompt Studio'
description 'Prompt Arcade — playable arcade cabinets (config-driven framework + games)'
version '0.6.0'

-- Escrow: keep config.lua (buyer-editable — game registry, rewards, controls, volume,
-- anti-cheat, Nazar's fortune texts) AND the locales/ translations open. All game logic
-- (client/server/shared/legacy Lua), HTML games, and stream props stay encrypted.
escrow_ignore {
    'config.lua',
    'locales/*.lua',   -- translations MUST stay readable/editable (buyers copy en.lua to add a language)
}

-- NO hard dependencies: interaction falls back to the built-in Text UI (client/lib/textui.lua)
-- and notifications to the native feed, so this runs on a bare server. ox_lib / ox_target /
-- qb-target are all used automatically IF present.
shared_scripts {
    'config.lua',
    'shared/log.lua',
    'shared/util.lua',
}

client_scripts {
    -- framework libraries (dependency order: libs -> core/lobby -> boot)
    'client/lib/models.lua',
    'client/lib/scene.lua',
    'client/lib/dui.lua',
    'client/lib/glass.lua',
    'client/lib/cabinet.lua',
    'client/lib/input.lua',
    'client/lib/camera.lua',
    'client/lib/target.lua',
    'client/lib/peer.lua',
    'client/lib/notify.lua',
    'client/lib/textui.lua',
    'client/core.lua',
    'client/lobby.lua',
    'client/menu.lua',
    'client/boot.lua',
    'client/physical.lua',  -- physical-game dispatch (legacy files register their play fn here)

    -- legacy per-game scripts (own their game logic; framework adds ox_target via fw=true + register):
    'client.lua',        -- claw machine
    'love.lua',          -- love tester (2P occupancy)
    'strength.lua',      -- physical
    'fortune.lua',       -- physical (Nazar)
    -- space.lua + wizard.lua MIGRATED to the framework (config fw=true); gun.lua + race.lua retired (-> Badlands + 3 racers)
}

server_scripts {
    'server/framework.lua',
    'server/pay.lua',          -- pay-per-play: the only file that takes money (after framework)
    'server/session.lua',      -- anti-cheat: session tracking + result validation (before server.lua)
    'server/leaderboard.lua',  -- KVP leaderboards + read exports (before server.lua)
    'server/lobby.lua',
    'server.lua',
}

files {
    'html/love.html',
    'html/space.html',
    'html/wizard.html',
    'html/badlands.html',
    'html/race_rockets.html',
    'html/race_truckin.html',
    'html/race_street.html',
    'locales/*.lua',           -- read at runtime with LoadResourceFile (see config.lua)
}

-- Custom clean-screen arcade cabinet props (moved here from prompt_sandy_corner so this resource
-- is self-contained). The YDRs live in stream/ (auto-streamed); this registers their archetypes.
data_file 'DLC_ITYP_REQUEST' 'stream/prompt_corner_arcade_props.ytyp'

-- NO dependencies. ox_target / qb-target are auto-detected at runtime; without either, the
-- built-in Text UI ([E] prompt) handles interaction. ox_lib is not required at all.

dependency '/assetpacks'