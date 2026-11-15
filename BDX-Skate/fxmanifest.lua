shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
name 'BDX-Skate'
description 'Skateboard - Classic street skating with fully customizable boards'
author 'Bodhix'
version '4.0.1'
lua54 'yes'
shared_scripts {
  '@ox_lib/init.lua',
  'config.lua',
}
client_scripts {
  'client/0_net_throttle.lua', -- ProSkate'ten once yuklenmeli (ag olayi freni)
  'client/bdx_optimizer.lua',
  'client/ProSkate.lua',
  'client/store-preview.lua',
}
server_scripts {
  'server/*.lua',
}
files {
  -- 'nui/sounds/*.MP3', -- kaykay sesleri kapatildi: dosyalar istemciye gonderilmiyor, NUI oynatamiyor (sessiz)
  'stream/Add-ons/*.ydr',
  'stream/Skateboards/sktboard.yft',
  'stream/Skateboards/**/*.yft',
  'stream/Skateboards/**/*.ytyp',
  'stream/Anims/**.ycd',
  'server/version.json',
  'data/*.meta',
}
ui_page '@BDX-Sport-Hub/nui/index.html'
nui_page '@BDX-Sport-Hub/nui/index.html'
data_file "DLC_ITYP_REQUEST" "stream/Skateboards/Modern/Decks/Decks.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/Skateboards/Modern/Trucks/Trucks.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/Skateboards/Modern/Wheels/Wheels.ytyp"
data_file 'HANDLING_FILE' 'data/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/vehicles.meta'
escrow_ignore {
  'config.lua',
}
dependencies {
  'BDX-Sport-Hub'
}
dependency '/assetpacks'








