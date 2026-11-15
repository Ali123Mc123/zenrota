shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'

this_is_a_map 'yes'
author 'Prompt Mods | Darkvanar'
description 'Prompt Sandy Christmas Content - Conditional IPL Loading!'

-- Server script for checking owned maps
server_script 'sv_christmas_loader.lua'

-- Client script for loading IPLs
client_script 'cl_christmas_loader.lua'

escrow_ignore {
    'stream/**'
}
dependency '/assetpacks'