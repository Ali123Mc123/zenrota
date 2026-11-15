-- NUI <-> server router (Phase 2). Every UI action posts to a bare callback name; we forward
-- it to the matching ox_lib server callback (nn_banking:server:<action>) and return the
-- authoritative result. Server-driven UI updates arrive on nn_banking:client:push.

local isOpen = false
local phoneOpen = false

--- NUI focus reflects whichever surface is open — the desktop bank and/or the floating phone.
local function applyFocus()
  local f = isOpen or phoneOpen
  SetNuiFocus(f, f)
end

--- Open or close the banking UI; on open, push a fresh authoritative snapshot.
---@param open boolean
function SetBankingOpen(open)
  if open == isOpen then return end
  isOpen = open
  applyFocus()
  SendReactMessage('setVisible', open)
  debugPrint(open and 'Show NUI frame' or 'Hide NUI frame')

  if open then
    CreateThread(function()
      local snap = lib.callback.await('nn_banking:server:getSnapshot', false)
      if snap and snap.registered then
        SendReactMessage('bankData', snap)
      else
        SendReactMessage('setupRequired', {})
      end
    end)
  end
end

-- Generic request router: fetchNui('<action>', data) -> server callback -> cb(result) --------
local ACTIONS = {
  'financeAccess', 'chequeList', 'chequeBook', 'chequeIssue', 'chequeResume', 'chequeCancel', 'chequeDeposit', 'chequeHistory', 'chequeForge',
  'financeCases', 'financeCaseCreate', 'financeCase', 'financeCaseUpdate', 'financeSearch', 'financeAccount', 'financeTransactions',
  'financeEvidence', 'financeWarrantRequest', 'financeWarrantReview', 'financeWatch', 'financeHold', 'financeSeize',
  'financeCheque', 'financeConfiscate', 'financeReport', 'financeAlerts',
  'bootstrap', 'getSnapshot', 'register', 'lookupAccount',
  'transfer', 'transferNearby', 'deposit', 'withdraw',
  'createCard', 'toggleCardBlock', 'deleteCard',
  'createSavings', 'moveToSavings', 'moveFromSavings',
  'takeLoan', 'payLoan', 'payBill', 'payAllBills',
  'setPin', 'changePin', 'verifyPin',
  'createInvoice', 'listInvoices', 'payInvoice', 'declineInvoice',
  'stockMarket', 'buyStock', 'sellStock',
  'listAccounts', 'createAccount', 'deleteAccount', 'setActiveAccount', 'accountInfo',
  'listMembers', 'addMember', 'removeMember', 'setMemberPermissions',
}

for _, action in ipairs(ACTIONS) do
  RegisterNUICallback(action, function(data, cb)
    CreateThread(function()
      local ok, res = pcall(lib.callback.await, 'nn_banking:server:' .. action, false, data or {})
      if ok then
        cb(res)
      else
        debugPrint('callback error on ' .. action .. ': ' .. tostring(res))
        cb({ ok = false, error = 'request_failed' })
      end
    end)
  end)
end

-- Server -> UI pushes (real-time on desktop).
RegisterNetEvent('nn_banking:client:push', function(action, data)
  SendReactMessage(action, data)
end)

-- React asks to close (Escape via VisibilityProvider, or the X button).
RegisterNUICallback('hideFrame', function(_, cb)
  SetBankingOpen(false)
  cb({ ok = true })
end)

-- Standalone NN Bank phone — a floating phone (bottom-right, no backdrop) that needs no host
-- phone resource. The phone.html iframe self-bootstraps its data on open.
function SetBankingPhoneOpen(open)
  if open == phoneOpen then return end
  if open and IsPauseMenuActive() then return end
  phoneOpen = open
  applyFocus()
  SendReactMessage('setPhoneVisible', open)
end

-- The phone UI (Esc / close affordance) asks to close itself.
RegisterNUICallback('closePhone', function(_, cb)
  SetBankingPhoneOpen(false)
  cb({ ok = true })
end)

if Config.Phone and Config.Phone.Enabled then
  local cmd = Config.Phone.Command or 'bankphone'
  RegisterCommand(cmd, function() SetBankingPhoneOpen(not phoneOpen) end, false)
  TriggerEvent('chat:addSuggestion', '/' .. cmd, NN.Translate('phone.command_help', { brand = NN.BrandName() }))
  -- Keybind only when a key is configured; empty Key = command-only.
  local key = Config.Phone.Key
  if type(key) == 'string' and key ~= '' then
    RegisterKeyMapping(cmd, NN.Translate('phone.keybind_help', { brand = NN.BrandName() }), 'keyboard', key)
  end
end

function IsBankingOpen() return isOpen end
function IsBankingPhoneOpen() return phoneOpen end

-- Safety: release focus if the resource stops while either surface is open.
AddEventHandler('onResourceStop', function(res)
  if res == GetCurrentResourceName() and (isOpen or phoneOpen) then
    SetNuiFocus(false, false)
  end
end)
