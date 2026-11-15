shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'bodacious'
game 'gta5'
lua54 'yes'
version "1.11.1"

dependencies {
  'tgiann-core',
}

escrow_ignore {
  'config.lua',
  'client/editable.lua',
  'server/editable.lua',
  'server/webhooks.lua',
  'languages/*.lua'
}

ui_page 'ui/build/index.html'

files {
  'micClickSounds/*.wav',
  'ui/build/**.*',
}

shared_script {
  '@ox_lib/init.lua',
  'config.lua',
  'languages/*.lua',
  'shared/*.lua'
}

client_script {
  'client/*.lua',
}

server_script {
  "@oxmysql/lib/MySQL.lua",
  "@tgiann-core/server/databaseCreator/main.lua",
  'server/*.lua',
}

dependency '/assetpacks'