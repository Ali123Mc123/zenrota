shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
this_is_a_map 'yes'
lua54 'yes' 
-- Download Door Audio and Door Tuning at https://github.com/Heleniust/helnius-map-data
author 'helnius' -- Discord: https://discord.gg/RGgqnsxvMv, Tebex: https://helnius.com/
description 'Alta station, Los Santos Police Department' 
version '1.1.9-release'

server_script 'version-check.lua' 

escrow_ignore {
    'config.lua',
    'client.lua',
    'version-check.lua',
    'stream/INT/Non-Escrowed/*.ydr',
    'stream/EXT_hw1_27/Non-Escrowed/*.ydr'
}

client_scripts {
    'config.lua',
    'client.lua'
}


files {
    'timecycle_policestation_helnius.xml'
}

data_file 'TIMECYCLEMOD_FILE'  'timecycle_policestation_helnius.xml'

dependency '/assetpacks'