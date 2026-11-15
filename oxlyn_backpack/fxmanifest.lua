shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'

author 'Oxlyn Software'
description 'Oxlyn Backpack V3 - ESX / QBCore / QBox'
version '3.2.6'

lua54 'yes'

ui_page 'ui/index.html'

dependencies {
    'ox_lib',
    'oxmysql',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua',            -- main configuration (open source)
}

client_scripts {
    'editable/bridge_client.lua',   -- custom inventory bridge    (open source)
    'editable/vanguard_index.lua',  -- vanguard çanta drawable numarası (open source)
    'client/bridge.lua',            -- bridge loader              (encrypted)
    'editable/zones.lua',           -- zone / targeting system    (open source)
    'editable/context_menu.lua',    -- backpack context menu       (open source)
    'client/client.lua',            -- main client logic          (encrypted)
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'editable/bridge_server.lua',   -- custom inventory bridge    (open source)
    'server/bridge.lua',            -- bridge loader              (encrypted)
    'editable/logging.lua',         -- Discord / logging handler  (open source)
    'server/server.lua',            -- main server logic          (encrypted)
}

files {
    'ui/index.html',
    'mp_m_freemode_01_mp_m_vanguardbackpacks_shop.meta',
    'mp_f_freemode_01_mp_f_vanguardbackpacks_shop.meta',
}

data_file 'SHOP_PED_APPAREL_META_FILE' 'mp_m_freemode_01_mp_m_vanguardbackpacks_shop.meta'
data_file 'SHOP_PED_APPAREL_META_FILE' 'mp_f_freemode_01_mp_f_vanguardbackpacks_shop.meta'

client_exports {
    'openBackpack',
    'openBackpack1',
    'openBackpack2',
    'openBackpack3',
    'searchPlayerBackpack',
    'openLockerMenu',
    'openPasscodeReset',
    'toggleBackpackVisual',
    'GetInventoryBridge',
}

escrow_ignore {
    'config/config.lua',
    'editable/*.lua',
}

dependency '/assetpacks'