shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy-games'
author 'Daddy Development'
description 'Birlesik Oyun Kutuphanesi (Zar & Sans Oyunlari, RCore Masa Spawner, Gym & Spor)'
version '2.0.0'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js',
    'web/gym/icons.js',
    'web/gym/tokens.css',
    'web/gym/hud.css',
    'web/gym/hub.css',
    'web/gym/hud.js',
    'web/gym/hub.js',
    -- Ozel display fontu kullanmak istersen buraya birak (tokens.css'te slot hazir)
    'web/gym/fonts/*.woff2',
    'web/gym/fonts/*.ttf',
}

-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'modules/gym/shared.lua',
}

client_scripts {
    'modules/dice/client.lua',
    'modules/tables/client_placement.lua',
    'modules/tables/client_streamer.lua',

    -- Gym: sira onemli (target -> workout -> nui -> npc -> duels)
    'modules/gym/client_perks.lua',
    'modules/gym/client_target.lua',
    'modules/gym/client_workout.lua',
    'modules/gym/client_nui.lua',
    'modules/gym/client_npc.lua',
    'modules/gym/client_duels.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'modules/bridge/server.lua',
    'modules/dice/server.lua',
    'modules/tables/server.lua',

    -- Gym: server_db once yuklenmeli (GymDB, server.lua tarafindan kullanilir)
    'modules/gym/server_db.lua',
    'modules/gym/server.lua',
}

dependencies {
    'ox_lib',
    'ox_target',
    'oxmysql',
}
