shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/client_guard.lua'
server_script '@FeloxAC/modules/include/server_guard.lua'
fac_guard_flags 'clientEvent,serverEvent'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'daddy_uiprobe'
description 'UI crash probe: notices a UI (CEF) crash in-game and reports what was around the player, with samples to compare'
version '1.0.0'

shared_script 'config.lua'
client_script 'client.lua'
server_scripts { 'config_sv.lua', 'server.lua' }

ui_page 'web/index.html'
files { 'web/index.html' }
