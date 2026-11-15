shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version "cerulean"
game "gta5"
lua54 "yes"
version '1.3.0'

dependencies {
	"ox_lib",
	"tgiann-core",
	"tgiann-game-lib",
}

ui_page "ui/build/index.html"

files {
	"ui/build/**.*",
}

escrow_ignore {
	"client/editable.lua",
	"configs/*.lua",
	"languages/*.lua",
	"languages/howtoplay/**/*.lua",
	"server/editable.lua",
}

shared_scripts {
	"@ox_lib/init.lua",
	"configs/*.lua",
	"languages/*.lua",
	"languages/howtoplay/**/*.lua",
	"shared/*.lua",
	"gameLib.lua",
}

client_scripts {
	"client/class/*.lua",
	"client/utilty/*.lua",
	"client/*.lua",
}

server_scripts {
	"server/class/*.lua",
	"server/utilty/*.lua",
	"server/*.lua",
}

data_file 'DLC_ITYP_REQUEST' 'stream/lumi_okey_masa.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/lumi_okey.ytyp'

dependency '/assetpacks'