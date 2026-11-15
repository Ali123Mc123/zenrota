shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
version "1.4.1"

lua54 'yes'

dependencies {
	'tgiann-core',
}

escrow_ignore {
	'config.lua',
	'languages/*.lua',
	'client/editable.lua',
	'server/webhooks.lua',
	'server/editable.lua',
	'server/ox.lua',
}

ui_page {
	'ui/build/index.html',
}

files {
	'ui/build/**.*',
}

shared_script {
	'@ox_lib/init.lua',
	"config.lua",
	"languages/*.lua",
	"shared/shared.lua"
}

client_scripts {
	'client/*.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@tgiann-core/server/databaseCreator/main.lua',
	'server/webhooks.lua',
	'server/ox.lua',
	'server/editable.lua',
	'server/main.lua',
}

dependency '/assetpacks'