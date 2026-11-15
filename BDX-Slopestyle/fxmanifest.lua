shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
name 'BDX-Slopestyle'
description 'Slopstyle - Shred the Mountains with customizable bikes, tricks and stunts'
author 'Bodhix'
version '1.0.0'
lua54 'yes'

shared_scripts {
    'locales/*.lua',
    'config.lua',
}

client_scripts {
    'client/*.lua',
}

server_scripts {
    'server/*.lua',
    'whitelist.lua'
}

files {
    'data/*.meta',
    'data/clip_set.xml', 
    'stream/anims/*.ycd',
    'server/version.json',
    'stream/slopstyle/*.yft',
    'stream/slopstyle/*.ytd',
    'stream/slopstyle/*.ycd',
    'stream/slopstyle/*.ypt',
    'stream/slopstyle/*.ytyp',
}

data_file 'CLIP_SETS_FILE' 'data/clip_set.xml'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/vehiclelayouts_slopstyle.meta'
data_file 'HANDLING_FILE' 'data/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/vehicles.meta'
data_file 'CARCOLS_FILE' 'data/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/carvariations.meta'

escrow_ignore {
    'config.lua',
    'whitelist.lua',
    'locales/*.lua'
}

dependencies {
  'BDX-Sport-Hub'
}

dependency '/assetpacks'



