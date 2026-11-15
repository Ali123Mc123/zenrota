shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
author 'E-Action.dev'
description 'EAdmin Panel'
version '1.4.3'
-- UI (production default)
ui_page 'web/build/index.html'
-- Local development override:
-- ui_page 'http://localhost:3000'
-- Escrow ignore - these files remain unencrypted so users can customize them
escrow_ignore {
    'config/config.lua',
    'config/server.lua',
    'config/player_actions.lua',
    'bridge/**/*.lua',
    'client/freecam/*.lua',
    'client/noclip.lua',
    'client/nametags.lua',
    'client/blips.lua',
    'locales/*.json',
}
-- Shared Scripts (config → locale → ox_lib → log utility → resource detection → other shared)
shared_scripts {
    'config/config.lua',     -- Global Config table (must load first)
    'shared/locale.lua',     -- L() locale function (depends on Config)
    '@ox_lib/init.lua',
    'bridge/_log.lua',       -- Log utility (must load first after libs)
    'bridge/_resource.lua',  -- Framework & resource auto-detection
}
-- Client Scripts
client_scripts {
    'bridge/client.lua',     -- Client bridge (fuel, clothing, revive anim)
    -- Freecam module (load order: utils → config → camera → main, before noclip)
    'client/freecam/utils.lua',
    'client/freecam/config.lua',
    'client/freecam/camera.lua',
    'client/freecam/main.lua',
    'client/*.lua',
}
-- Server Scripts (order matters: utilities first, then features)
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/server.lua',            -- Server-only secrets/config (TURN, etc.)
    'server/utils.lua',             -- Shared helpers (GetPrimaryIdentifier, CreateActionRateLimiter)
    'server/cache.lua',             -- Cache utilities (GetCached, InvalidateCache)
    'server/schema.lua',            -- Schema detection (depends on MySQL)
    'server/dashboard.lua',         -- Dashboard stats (depends on cache, schema)
    'server/server.lua',            -- Main server logic
    -- Bridge layer (public, framework-specific, customizable) ──
    'bridge/server/_utils.lua',             -- Shared utilities + getPlayer + isQb/isEsx flags
    'bridge/server/discord_logs.lua',       -- Discord Webhook Audit Logs
    'bridge/server/player_data.lua',        -- Player data accessors (GetCitizenid, buildPlayerRecord, resolvePlayerSource)
    'bridge/server/player_management.lua',  -- Player management actions (ban, revive, heal, jail, money, job, gang, etc.)
    'bridge/server/quick_actions.lua',      -- Quick actions (food/water, stress, weather, time)
    'bridge/server/jobs.lua',               -- Job catalog (unified jobs/grades/pay/boss)
    'bridge/server/players.lua',            -- Player data queries (paginated, aggregate stats, filter options)
    'bridge/server/vehicles.lua',           -- Vehicle data queries (paginated, aggregate stats, filter options)
    'bridge/server/inventory.lua',          -- Inventory queries (container listing, item search, management)
    'bridge/server/vehicle_actions.lua',    -- Vehicle mutations (keys, store, impound, spawn, props)
    'bridge/server/bans.lua',              -- Ban management queries (paginated, CRUD)
    'bridge/server/lifecycle.lua',          -- Framework lifecycle → Activity + LivePlayers + ActivityFeed
    -- Panel layer (private, panel-specific logic) ──
    'server/players.lua',           -- Live players core (cache, streaming, position tracking)
    'server/settings.lua',          -- Panel settings (key-value cache + UI management)
    'server/audit_logs.lua',        -- Audit log recording, query, retention
    'server/permissions.lua',       -- RBAC engine (roles, bootstrap, permission cache)
    'server/noclip.lua',            -- NoClip permission validation + revocation
    'config/player_actions.lua',    -- Custom player actions config (server-only, may contain functions)
    'server/player_actions.lua',    -- Player management action dispatch
    'server/vehicle_actions.lua',   -- Vehicle impound/store action dispatch
    'server/players_data.lua',      -- NUI callbacks: players data queries → Bridge
    'server/vehicles_data.lua',     -- NUI callbacks: vehicles data queries → Bridge
    'server/bans_data.lua',         -- NUI callbacks: bans data queries → Bridge
    'server/jobs_data.lua',         -- NUI callbacks: jobs/employees data queries → Bridge
    'server/inventories.lua',       -- NUI callbacks + exports: inventory → Bridge
    'server/world.lua',             -- World management (weather, time)
    'server/activityFeed.lua',      -- Activity Feed (in-memory FIFO event stream)
    'server/activity.lua',          -- Activity tracking & analytics
    'server/tickets.lua',           -- Ticket system & staff chat
    'server/nametags.lua',          -- Nametag permission validation + character data
    'server/blips.lua',             -- Blip permission validation + position data
    'server/money_logs.lua',        -- Money logs (export + batch write + query endpoints)
    'server/devtools.lua',          -- Developer tools (code execution console)
    'server/resources.lua',         -- Resources management (list, start/stop/restart)
    'server/entity_inspector.lua',  -- Entity inspector (StateBag enumeration + modification)
}
-- Additional UI Assets
files {
    'web/build/index.html',
    'web/build/**/*',
    'locales/*.json',
}
dependency '/assetpacks'

-- Entegrasyonlar bridge/_resource.lua'da yukleme aninda 'started' durumuna bakilarak algilaniyor.
-- ensure [scripts] eadmin'i bunlardan once baslattigi icin hepsi "Not detected" kaliyordu; once baslamalari icin bagimlilik.
-- Biri sunucudan kaldirilirsa buradan da cikarilmali, yoksa eadmin_panel baslamaz.
dependencies {
    'savana-fuel',
    'illenium-appearance',
    'qbx_medical',
    'qbx_police',
    'wais-vehiclekey',
}

