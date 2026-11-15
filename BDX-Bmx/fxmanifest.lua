shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
name 'BDX-Bmx'
description 'BMX Stunts - Shred the streets with customizable bikes, tricks and stunts'
author 'Bodhix'
version '3.0.0'
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
}

files {
    'data/*.meta',
    'audio/*.wav',
    'stream/anims/*.ycd',
    'server/version.json',
    'stream/freestyle/*.yft',
    'stream/freestyle/*.ytd',
    'stream/freestyle/*.ycd',
    'stream/freestyle/*.ypt',
    'stream/freestyle/*.ytyp',
}

data_file 'VEHICLE_LAYOUTS_FILE' 'data/vehiclelayouts_bmxbdx.meta'
data_file 'HANDLING_FILE' 'data/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/vehicles.meta'
data_file 'CARCOLS_FILE' 'data/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/carvariations.meta'
data_file 'DLC_ITYP_REQUEST' 'stream/freestyle/bmx_extras.ytyp'

escrow_ignore {
    'config.lua',
    'whitelist.lua',
    'locales/*.lua'
}

dependencies {
  'BDX-Sport-Hub'
}

dependency '/assetpacks'



