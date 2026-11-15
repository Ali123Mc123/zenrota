shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_campusgames'
author 'Daddy Studio'
description 'Daddy Campus Games: darts, truth or dare, mini golf, capture the flag, hot potato, red light green light, hide and seek, musical chairs, taboo, who am I and bingo nights played in the world'
version '1.4.0'

dependencies { 'ox_lib', 'oxmysql', 'daddy_lib' }

-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    '@ox_lib/init.lua',
    '@daddy_lib/init.lua',
    'config.lua',
    'locales/*.lua',
    'packages/kit/locales/*.lua',
    'packages/chores/shared.lua',
    'shared/rules/*.lua',
}

client_scripts {
    'packages/world/client.lua',
    'packages/world/draw.lua',
    'packages/world/shapes.lua',
    'packages/world/cursor.lua',
    'packages/world/placement.lua',
    'packages/world/editor.lua',
    'packages/world/worldedit.lua',
    'packages/world/panel.lua',
    'packages/chores/tools.lua',
    'packages/kit/nui.lua',
    'client/main.lua',
    'client/match.lua',
    'client/board.lua',
    'client/hub.lua',
    'client/portable.lua',
    'client/bots.lua',
    'client/seated.lua',
    'client/bingo/*.lua',
    'client/games/*.lua',
    'client/admin.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'packages/world/server.lua',
    'packages/world/admin.lua',
    'packages/chores/minigame.lua',
    'migrations/*.lua',
    'server/main.lua',
    'server/college.lua',
    'server/fees.lua',
    'server/match/state.lua',
    'server/match/lobby.lua',
    'server/match/turns.lua',
    'server/match/party.lua',
    'server/match/seated.lua',
    'server/bingo/*.lua',
    'server/rewards.lua',
    'server/stats.lua',
    'server/tournament.lua',
    'server/hub.lua',
    'server/portable.lua',
    'server/bots.lua',
    'server/data/*.lua',
    'server/games/*.lua',
    'server/admin.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
}

escrow_ignore {
    'config.lua',
    'locales/*.lua',
    'server/data/*.lua',
    'packages/kit/locales/*.lua',
}
