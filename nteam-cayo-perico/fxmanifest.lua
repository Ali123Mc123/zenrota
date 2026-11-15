shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'

name 'nteam_cayo_perico'
author 'NTeam'
description 'Cayo Perico loader and configuration for Cayo Porto'
version '1.0.0'
this_is_a_map 'yes'

dependency '/gameBuild:2189'

client_scripts {
    'config.lua',
    'ipls.lua',
    'client.lua'
}

escrow_ignore {
    
    'config.lua',

}

dependency '/assetpacks'