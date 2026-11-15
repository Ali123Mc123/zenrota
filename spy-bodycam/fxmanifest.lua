shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientNative,clientEntity,serverEvent'
fx_version 'cerulean'
game "gta5"
author "Spy-Script"
version '2.5.6'
lua54 'yes'
ui_page 'web/index.html'
shared_script {
  "config.lua",
  '@ox_lib/init.lua',
}
server_script {
  "server/**",
  '@oxmysql/lib/MySQL.lua',
}
client_script {
  'client/**',
}
files {
  'web/**',
  "node_modules/fivem-game-view/**/*",
}








