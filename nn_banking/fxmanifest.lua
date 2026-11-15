shared_script '@FeloxAC/modules/include/shared.lua'
client_script '@FeloxAC/modules/include/client.lua'
server_script '@FeloxAC/modules/include/server.lua'
shared_script '@FeloxAC/modules/include/guard_runtime.lua'
client_script '@FeloxAC/modules/include/weaponGuard.lua'
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'nn_banking'
author 'nn'
description 'Premium multi-framework banking (ESX / QBCore / Qbox via community_bridge)'
version '0.2.38'

dependencies {
  'community_bridge',
  'oxmysql',
  'ox_lib',
  'object_gizmo', -- 3-axis placement gizmo for business ATMs (/placeatm)
}

-- Pause menu haritasi blip isimlerini bu dosya uzerinden ogrenir (daddy_pausemenu README)
client_script '@daddy_pausemenu/shim/blipnames.lua'

shared_scripts {
  '@ox_lib/init.lua',
  'config.lua',
  'shared/bridge.lua', -- Bridge handle + NN constants/helpers (both realms)
  'shared/locale.lua', -- runtime locale JSON loader (server + client)
  'shared/export.lua', -- public client + server integration API
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/sv_db.lua',           -- schema bootstrap + query helpers
  'server/sv_main.lua',         -- session cache, identity, NN.Push/Lock
  'server/sv_pin.lua',          -- account PIN (set/verify/change)
  'server/sv_accounts.lua',     -- register, account numbers, snapshot, bootstrap, multi-account
  'server/sv_members.lua',      -- account members + permissions + ledger primitives
  'server/sv_transactions.lua', -- ledger (log / recent / series)
  'server/sv_privileged.lua',   -- allowlisted DOJ/admin account integration API
  'server/sv_money.lua',        -- deposit / withdraw (cash <-> bank)
  'server/sv_transfer.lua',     -- transfer by account number (online/offline)
  'server/sv_cards.lua',        -- create / freeze / delete cards (+ card item)
  'server/sv_savings.lua',      -- savings accounts + deposit/withdraw
  'server/sv_loans.lua',        -- loan plans, take/pay
  'server/sv_bills.lua',        -- pay bill / pay all
  'server/sv_daddy_bills.lua',  -- DaddyRP: bills of daddy_bills in the Bills tab
  'server/sv_atm.lua',          -- ATM access gate (registered + optional card item)
  'server/sv_atms.lua',         -- business-placed ATMs (place / remove / persist)
  'server/sv_invoices.lua',     -- player-to-player invoices (create / pay / decline)
  'server/sv_finance.lua',
  'server/sv_finance_schema.lua',
  'server/sv_cheques.lua',
  'server/sv_investigations.lua',
  'server/sv_stocks.lua',       -- stock market (simulated prices, black-card gated)
}

client_scripts {
  'client/main.lua',            -- SendReactMessage / debugPrint + /bank command + keybind
  'client/nui.lua',             -- NUI <-> server router + push handler + open/close
  'client/cl_target.lua',       -- ox_target / qb-target / proximity provider selection
  'client/cl_world.lua',        -- bank blips + targets + ATM targets
  'client/cl_atm.lua',          -- in-world DUI ATM (screen-on-prop + camera + keypad)
  'client/cl_atmplace.lua',     -- business ATM placement (object_gizmo) + spawn manager
  'client/phone/bridge.lua',    -- registers the phone app with LB/QB/Quasar/etc. phones
  'client/cl_players.lua',      -- nearby-player picker (for send money / invoices)
}

-- Desktop banking UI.
ui_page 'web/build/index.html'

files {
  'web/build/index.html',
  'web/build/**/*', -- includes phone.html (and atm.html once built)
  'web/icon.png',
  'locales/*.json',
  'sql/financial-investigations.sql',
}
-- Files left UNencrypted (editable). Only client/main.lua + server/sv_main.lua (and
-- shared/bridge.lua) stay encrypted by CFX escrow; everything else here is open.
escrow_ignore {
  'config.lua',
  'locales/*.json',
  'web/build/**/*',
  'web/icon.png',
  'client/nui.lua',
  'client/cl_target.lua',
  'client/cl_world.lua',
  'client/cl_atm.lua',
  'client/cl_atmplace.lua',
  'client/cl_players.lua',
  'client/phone/bridge.lua',
  'server/sv_db.lua',
  'server/sv_pin.lua',
  'server/sv_accounts.lua',
  'server/sv_members.lua',
  'server/sv_transactions.lua',
  'server/sv_money.lua',
  'server/sv_transfer.lua',
  'server/sv_cards.lua',
  'server/sv_savings.lua',
  'server/sv_loans.lua',
  'server/sv_bills.lua',
  'server/sv_atm.lua',
  'server/sv_atms.lua',
  'server/sv_invoices.lua',
  'server/sv_stocks.lua',
  'shared/export.lua',
  'shared/locale.lua'
}

dependency '/assetpacks'