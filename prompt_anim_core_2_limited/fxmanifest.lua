shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version "cerulean"
use_fxv2_oal "yes"
lua54 'yes'
game "gta5"

author "Adaz"
version '1.2.0'
description 'prompt_anim_core - Limited (animations only, no stats/groups/membership)'

-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
    '@ox_lib/init.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

files {
    'config/client.lua',
    'config/config_c.lua',
    'config/config_s.lua',
    'web/**/*',
    'locales/*',
    'client/*.lua',
    'server/*.lua',

    'data/prompt_gym.dat54.rel',
    'audiodirectory/prompt_gym.awc',
    'stream/**/*'
}

data_file 'AUDIO_WAVEPACK'  'audiodirectory'
data_file 'AUDIO_SOUNDDATA' 'data/prompt_gym.dat'
data_file 'DLC_ITYP_REQUEST' 'stream/anim/vin_chu.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/anim/vision_gymlegpress.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/anim/vision_gymspeedbagwall.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/anim/vision_gymspeedbag_yt.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/anim/vision_gymrowpull_yt.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/anim/vision_gymlatpull_yt.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/anim/vision_gympullmachine1_yt.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/anim/vision_gymbike_yt.ytyp'

ui_page 'web/index.html'

escrow_ignore {
    'fxmanifest.lua',
    'config/client.lua',
    'config/config_c.lua',
    'config/config_s.lua',
    'config/server.lua',
    'client/main.lua',
    'client/boxing_ring.lua',
    'client/callbacks.lua',
    'client/events.lua',
    'client/keybinds.lua',
    'client/points.lua',
    'client/state.lua',
    'server/main.lua',
    'server/boxing_ring.lua',
    'server/callbacks.lua',
    'server/events.lua',
    'server/exports.lua',
    'server/state.lua',
    'server/utils.lua',
    'locales/**',
}

dependency '/assetpacks'