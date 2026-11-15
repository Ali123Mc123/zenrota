shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_artstudio'
author 'Daddy Studio'
description 'Art Studio: canvases players paint on together, in the world or full screen'
version '2.0.0'

dependencies { 'ox_lib', 'oxmysql', 'daddy_lib' }

shared_scripts {
    '@ox_lib/init.lua',
    '@daddy_lib/init.lua',
    'config.lua',
    'locales/*.lua',
    'packages/ink/stamp.lua',
    'packages/ink/shared/codec.lua',
    'packages/ink/shared/rules.lua',
    'shared/room.lua',
}

client_scripts {
    'packages/ink/client/surface.lua',
    'packages/ink/client/outbox.lua',
    'packages/ink/client/mount.lua',
    'packages/ink/client/editor.lua',
    'packages/ink/client/statics.lua',
    'packages/ink/client/bake.lua',
    'client/paper.lua',
    'client/main.lua',
    'client/admin.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'packages/ink/server/schema.lua', -- before the migrations: 002 and 003 use it
    'migrations/*.lua',
    'packages/ink/server/persist.lua',
    'packages/ink/server/store.lua',
    'packages/ink/server/push.lua',
    'packages/ink/server/ops.lua',
    'packages/ink/server/blob.lua',
    'packages/ink/server/history.lua',
    'packages/ink/server/bake.lua',
    'packages/ink/server/engine.lua',
    'server/canvases.lua',
    'server/ink.lua',
    'server/studio.lua',
    'server/admin.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*',
    'packages/ink/dui/*',
}

escrow_ignore {
    'config.lua',
    'locales/*.lua',
}
