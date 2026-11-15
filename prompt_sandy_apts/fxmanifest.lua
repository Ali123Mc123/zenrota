shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
lua54 'yes'
fx_version 'cerulean'
game 'gta5'
this_is_a_map 'yes'

author 'Prompt Studio'
description 'Sandy Shores Apartments'
version '1.0.8'

client_scripts {
    'config.lua',
    'proximity_loader.lua',
    'interior_manager.lua',
    'debug_commands.lua'
}


data_file 'DLC_ITYP_REQUEST' 'stream/shells/prompt_sandy_apts_shells.ytyp'

escrow_ignore {
    'config.lua',
    'debug_commands.lua',
    'stream/map/unlocked/**'
}


server_scripts{
	'sv_loader.lua'
}

dependency '/assetpacks'