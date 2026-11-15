shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'bodacious'
game 'gta5'
this_is_a_map 'yes'

-- map by---:
author 'prompt'
scriptdeveloper 'Cas.vdv'
description 'Sandy Shores Marina'
version '1.0.4'

escrow_ignore {
    'stream/unlocked/**'

}

server_scripts {
    'weather_prop_controllers.lua',
	'sv_loader.lua'
}

data_file "DLC_ITYP_REQUEST" "stream/prompt_sandy_dynamic_weather_props.ytyp"

shared_scripts {
    'config.lua'
}

client_scripts {
    'weather_prop_controller.lua',
    'client.lua'
}

lua54 'yes'



dependency '/assetpacks'
dependency '/assetpacks'