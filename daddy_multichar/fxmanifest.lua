shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent,serverNative'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'
node_version '22'

name 'daddy_multichar'
author 'Daddy Studio'
description 'Multichar: cinematic character selection, creation and spawn with Discord, Tebex and admin slots'
version '1.0.0'

dependencies { 'ox_lib', 'oxmysql' }

-- es_extended turns its multicharacter mode on when this name exists.
provide 'esx_multicharacter'

-- bridge/ is open source: its init, then the framework, clothing and housing adapters.
shared_scripts {
    '@ox_lib/init.lua',
    'config/cfg_main.lua',
    'config/cfg_spawn.lua',
    'shared/sh_defaults.lua',
    'locales/*.lua',
    'shared/sh_core.lua',
    'bridge/init.lua',
    'bridge/framework.lua',
    'bridge/appearance.lua',
    'bridge/housing.lua',
    'shared/sh_rules.lua',
    'shared/sh_scene.lua',
    'shared/sh_cutscenes.lua',
    'shared/sh_arrivals.lua',
    'shared/sh_scenes.lua',
}

client_scripts {
    'bridge/weather.lua',
    'client/cl_main.lua',
    'client/cl_camera.lua',
    'client/cl_scene.lua',
    'client/cl_select.lua',
    'client/cl_spawn.lua',
    'client/cl_editor.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'packages/logs/locales/*.lua',
    'packages/logs/server.lua',
    'config/sv_config.lua',
    'server/sv_main.lua',
    'bridge/inventory.lua',
    'bridge/medical.lua',
    'bridge/discord.lua',
    'bridge/permissions.lua',
    'server/sv_slots.lua',
    'server/sv_characters.lua',
    'server/sv_spawn.lua',
    'server/sv_world.lua',
    'server/sv_discord.lua',
    'server/sv_bot.js',
    'server/sv_admin.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
    'media/*',
}

-- Readable in the escrow build too: the config files, the texts, the scene data and every bridge file.
escrow_ignore {
    'config/*.lua',
    'locales/*.lua',
    'shared/sh_cutscenes.lua',
    'shared/sh_arrivals.lua',
    'shared/sh_scenes.lua',
    'bridge/init.lua',
    'bridge/framework.lua',
    'bridge/appearance.lua',
    'bridge/housing.lua',
    'bridge/weather.lua',
    'bridge/inventory.lua',
    'bridge/medical.lua',
    'bridge/discord.lua',
    'bridge/permissions.lua',
}
