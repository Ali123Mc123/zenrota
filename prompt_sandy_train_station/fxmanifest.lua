shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
author 'Prompt' 
version '1.0.1' 
this_is_a_map 'yes'

-- audio merged into shared prompt_audio (dat151) 2026-06-10; zip backup in
-- C:\Scripts\_backups\prompt_audio\train_station_audio_2026-06-10_night_pre-merge.zip


escrow_ignore {
    'stream/unlocked/**'
}

-- scripts --
lua54 'yes'


server_scripts{
	'sv_loader.lua'
}



dependency '/assetpacks'