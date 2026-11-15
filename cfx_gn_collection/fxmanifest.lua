shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

author 'G&N_s Studio'
description 'G&N_s Base Ressource'
version '4.4.0'

this_is_a_map 'yes'

data_file 'DLC_ITYP_REQUEST' 'stream/nels_medical_props.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/gn_medical_assets.ytyp'
data_file 'INTERIOR_PROXY_ORDER_FILE' 'interiorproxies.meta'

files {
    'interiorproxies.meta'
}

server_script 'server.lua'

escrow_ignore {
    'stream/**/*.ytd',
    'server.lua' -- Please keep this file to stay tuned about all our updates!
}
dependency '/assetpacks'








