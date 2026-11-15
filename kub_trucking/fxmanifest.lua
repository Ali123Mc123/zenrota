shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version "cerulean"

description "Trucking system for FiveM"
author "notkuubik"
version '1.2.2'

lua54 'yes'

games {
  "gta5"
}

dependencies {
  'oxmysql',
  'ox_lib'
}

client_exports {
  'truckingtablet',
  'closetruckingtablet',
}

server_exports {
  'getPlayerOwnedVehicles',
}

ui_page 'web/index.html'

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua',
}
client_scripts {
  "client/**/*",
  'events/client/**/*'
}

server_scripts {
  'server/config/svconfig.lua',
  '@oxmysql/lib/MySQL.lua',
  'server/**/*',
  'events/server/**/*'
}

files {
        'web/index.html',
        'web/**/*',
  'locales/*.json'
}

escrow_ignore {
  'client/api/clientfunctions.lua',
  'web/**/*.html',
  'web/**/*.js',
  'web/**/*.ttf',
  'web/**/*.woff2',
  'web/**/*.png',
  'web/**/*.webp',
  'web/**/*.css',
  'locales/en.json',
  'config.lua',
  'fxmanifest.lua',
  'initDB.sql',
  'server/api/serverfunctions.lua',
  'server/api/server.lua',
  'server/config/jobconfig.lua',
  'server/config/svconfig.lua',
  'events/**/*'
}
dependency '/assetpacks'







