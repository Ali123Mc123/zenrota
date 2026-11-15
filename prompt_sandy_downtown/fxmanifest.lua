shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
this_is_a_map 'yes'
version '1.1.2'
shared_script 'config.lua'

client_scripts {
	'client.lua',
	'interiors.lua'
}

server_scripts{
	'sv_loader.lua'
}

escrow_ignore {
	'config.lua',
	'client.lua',
	'interiors.lua',
	'noint/**',
	'stream/_manifest.ymf',
	'stream/**/*.ytyp',
	'stream/**/*.ymap',
	'stream/**/*.ybn',
	'stream/**/*.ytd',
	'stream/**/*.ydd',
	'stream/**/*.yft',
	'stream/**/*.ymf',
	'stream/**/*.ymt',
	'stream/**/*.ycd',
	'stream/**/*.xml',
	'stream/Exterior/unlocked/**',
	'stream/Interiors/*/unlocked/**'
}
dependency '/assetpacks'