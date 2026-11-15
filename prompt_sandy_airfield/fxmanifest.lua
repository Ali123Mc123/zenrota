shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'bodacious'
game 'gta5'
this_is_a_map 'yes'
author 'Prompt Mods'
version "1.1.2"

-- audio merged into shared prompt_audio (dat151) 2026-06-10; zip backup in
-- C:\Scripts\_backups\prompt_audio\airfield_audio_2026-06-10_night_pre-merge.zip

escrow_ignore {
  'stream/unlocked/**'
}


-- scripts --
lua54 'yes'


server_scripts{
	'sv_loader.lua'
}
dependency '/assetpacks'