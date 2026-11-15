shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
author "Debux Workshop"
description 'debux.tebex.io'
version('2.2.7')

fx_version 'cerulean'

game 'gta5'

ui_page 'html/index.html'

files {
	'html/index.html',
	'html/css/*.css',
	'html/js/*.js',
	'html/img/*.png',
	'html/img/*.svg',
	'html/fonts/*.ttf',
	'html/fonts/*.woff2',
	'**/weaponcomponents.meta',
	'**/weaponarchetypes.meta',
	'**/weaponanimations.meta',
	'**/pedpersonality.meta',
	'**/weapons.meta',
}

client_scripts {
	'functions/client_functions.lua',
	'client.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'functions/server_functions.lua',
	'server.lua',
}
shared_script {
	'@ox_lib/init.lua',
	'config/config.lua',
	'config/locales.lua',
	'functions/shared_functions.lua',
}

data_file 'WEAPONCOMPONENTSINFO_FILE' '**/weaponcomponents.meta'
data_file 'WEAPON_METADATA_FILE' '**/weaponarchetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' '**/weaponanimations.meta'
data_file 'PED_PERSONALITY_FILE' '**/pedpersonality.meta'
data_file 'WEAPONINFO_FILE' '**/weapons.meta'

lua54 'yes'

this_is_a_map 'yes'

lua54 'yes'

escrow_ignore {
	'config/*.lua',
	'functions/*.lua',
	-- 'stream/**/*',
	-- 'meta/**/*',
	-- 'client.lua',
	-- 'server.lua',
}
dependency '/assetpacks'