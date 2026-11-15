shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,clientEntity,serverEvent'
fx_version 'cerulean'
version '1.0.0'
game 'gta5'
lua54 'yes'
author 'Bostra'
description 'FiveM Poledancing'
client_scripts { "client/client.lua" }
files { 'config/config.lua' }
shared_scripts { "@ox_lib/init.lua", "config/config.lua" }
server_scripts { "server/server.lua" }
dependency 'ox_lib'








