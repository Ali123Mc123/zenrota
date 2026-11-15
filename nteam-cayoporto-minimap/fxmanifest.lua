shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'

name 'nteam_cayoporto_minimap'
author 'NTeam'
description 'Classic GTA map: Los Santos, the Porto connection, Cayo Porto and Cayo Perico.'
version '1.0.0'

client_scripts {
    'config.lua',
    'tiles.lua',
    'client.lua'
}

files {
    'stream/*.ytd',
    'stream/minimap_main_map.gfx'
}

escrow_ignore {
    'config.lua',

}

dependency '/assetpacks'