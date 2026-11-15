if not IsDuplicityVersion() then
  exports('OpenBank', function() SetBankingOpen(true) end)
  exports('CloseBank', function() SetBankingOpen(false) end)
  exports('ToggleBank', function() SetBankingOpen(not IsBankingOpen()) end)
  exports('IsBankOpen', function() return IsBankingOpen() end)

  exports('OpenPhone', function() SetBankingPhoneOpen(true) end)
  exports('ClosePhone', function() SetBankingPhoneOpen(false) end)
  exports('TogglePhone', function() SetBankingPhoneOpen(not IsBankingPhoneOpen()) end)
  exports('IsPhoneOpen', function() return IsBankingPhoneOpen() end)
  return
end

local function resolveAccount(src, selector)
  src = tonumber(src)
  if not src or not GetPlayerName(src) then return nil, 'Oyuncu aktif değil' end

  local account
  if selector == nil then
    account = NN.PrimaryAccount(src)
  elseif type(selector) == 'string' then
    account = NN.AccountByNumber(selector)
  else
    account = NN.AccountById(tonumber(selector))
  end

  if not account then return nil, 'Hesap bulunamadı' end
  if not NN.AccountPermission(src, account.id, 'view') then return nil, 'Hesaba erişimin yok' end
  return account
end

local function accountResult(src, account)
  local row = NN.AccountById(account.id) or account
  return NN.AccountDTORow(row, src)
end

local function pushAccount(src, account, transaction)
  NN.Push(src, 'accountUpdated', { account = accountResult(src, account), cash = NN.GetCash(src) })
  if transaction and NN.ActiveAccountId(src) == account.id then
    NN.Push(src, 'txnAdded', { transaction = transaction })
  end
end

local function getAccount(src, selector)
  local account = resolveAccount(src, selector)
  return account and accountResult(tonumber(src), account) or nil
end

local function getBalance(src, selector)
  local account = resolveAccount(src, selector)
  return account and NN.BalanceOfRow(account, tonumber(src)) or nil
end

local function addMoney(src, amount, reason, selector)
  src = tonumber(src)
  local invokingResource = GetInvokingResource() or 'External'
  local account, err = resolveAccount(src, selector)
  amount = NN.whole(amount)
  if not account then return false, err end
  if amount < 1 then return false, 'Geçersiz tutar' end

  local result = NN.Lock('acct:' .. account.accountNumber, function()
    if NN.toBool(account.isPrimary) then
      if Bridge.Framework.AddAccountBalance(src, 'bank', amount) == false then return false end
      NN.SyncBalanceCache(src)
    elseif not NN.CreditAccountLedger(account, amount) then
      return false
    end
    local transaction = NN.LogTxn(account.id, 'in', amount, 'deposit', invokingResource, tostring(reason or 'Harici yatırma'):sub(1, 128))
    pushAccount(src, account, transaction)
    return true
  end)

  if result ~= true then return false, 'Para yatırma başarısız' end
  return true, getBalance(src, account.id)
end

local function removeMoney(src, amount, reason, selector)
  src = tonumber(src)
  local invokingResource = GetInvokingResource() or 'External'
  local account, err = resolveAccount(src, selector)
  amount = NN.whole(amount)
  if not account then return false, err end
  if amount < 1 then return false, 'Geçersiz tutar' end
  if NN.toBool(account.frozen) then return false, 'Hesap dondurulmuş' end

  local result = NN.Lock('acct:' .. account.accountNumber, function()
    if NN.toBool(account.isPrimary) then
      if NN.GetBank(src) < amount then return false end
      if not NN.DebitBank(src, 'bank', amount) then return false end
      NN.SyncBalanceCache(src)
    elseif not NN.DebitAccountLedger(account, amount) then
      return false
    end
    local transaction = NN.LogTxn(account.id, 'out', amount, 'withdraw', invokingResource, tostring(reason or 'Harici çekim'):sub(1, 128))
    pushAccount(src, account, transaction)
    return true
  end)

  if result ~= true then return false, 'Yetersiz bakiye' end
  return true, getBalance(src, account.id)
end

local MAX_LEDGER_BALANCE = 9999999999999.99

local function resolveBusinessAccount(selector)
  local account
  if type(selector) == 'string' then
    if selector == '' or #selector > 20 then return nil, 'Geçersiz hesap numarası' end
    account = NN.AccountByNumber(selector)
  elseif type(selector) == 'number' then
    if selector ~= selector or selector == math.huge or selector == -math.huge
        or selector < 1 or selector > 2147483647 or selector ~= math.floor(selector) then
      return nil, 'Geçersiz hesap ID'
    end
    account = NN.AccountById(selector)
  else
    return nil, 'Hesap ID veya tam hesap numarası girilmeli'
  end

  if not account then return nil, 'Hesap bulunamadı' end
  if NN.toBool(account.isPrimary) then return nil, 'Ana hesaplar desteklenmiyor' end
  if account.accountType ~= 'business' then return nil, 'İşletme hesabı değil' end
  if NN.toBool(account.frozen) then return nil, 'Hesap dondurulmuş' end
  return account
end

local function businessAmount(value)
  local amount = tonumber(value)
  if not amount or amount ~= amount or amount == math.huge or amount == -math.huge or amount <= 0 then
    return nil, 'Geçersiz tutar'
  end
  amount = NN.money(amount)
  if amount <= 0 or amount > MAX_LEDGER_BALANCE then return nil, 'Geçersiz tutar' end
  return amount
end

local function businessReason(reason, fallback)
  local description = tostring(reason or ''):sub(1, 128)
  return description ~= '' and description or fallback
end

local function getBusinessAccount(selector)
  local account, err = resolveBusinessAccount(selector)
  if not account then return nil, err end
  return NN.AccountDTORow(account, nil)
end

local function getBusinessBalance(selector)
  local account, err = resolveBusinessAccount(selector)
  if not account then return nil, err end
  return NN.money(account.balance)
end

local function updateBusinessMoney(selector, value, reason, direction)
  local account, err = resolveBusinessAccount(selector)
  if not account then return false, err end

  local amount
  amount, err = businessAmount(value)
  if not amount then return false, err end

  local invokingResource = tostring(GetInvokingResource() or 'External'):sub(1, 64)
  local result = NN.Lock('acct:' .. account.accountNumber, function()
    local current, currentErr = resolveBusinessAccount(account.id)
    if not current then return { ok = false, error = currentErr } end
    local balance = NN.money(current.balance)

    if direction == 'out' then
      if balance < amount or not NN.DebitAccountLedger(current, amount) then
        return { ok = false, error = 'Yetersiz bakiye' }
      end
    else
      if balance > MAX_LEDGER_BALANCE - amount then
        return { ok = false, error = 'Bakiye limiti aşıldı' }
      end
      if not NN.CreditAccountLedger(current, amount) then
        return { ok = false, error = 'Para ekleme başarısız' }
      end
    end

    NN.LogTxn(
      current.id,
      direction,
      amount,
      direction == 'out' and 'withdraw' or 'deposit',
      invokingResource,
      businessReason(reason, direction == 'out' and 'Harici işletme çıkışı' or 'Harici işletme girişi')
    )
    local updated = NN.AccountById(current.id)
    local fallbackBalance = NN.money(balance + (direction == 'out' and -amount or amount))
    return { ok = true, balance = updated and NN.money(updated.balance) or fallbackBalance }
  end)

  if not result or result.ok ~= true then
    return false, result and result.error or (direction == 'out' and 'Para çekme başarısız' or 'Para ekleme başarısız')
  end
  return true, result.balance
end

local function addBusinessMoney(selector, amount, reason)
  return updateBusinessMoney(selector, amount, reason, 'in')
end

local function removeBusinessMoney(selector, amount, reason)
  return updateBusinessMoney(selector, amount, reason, 'out')
end

local function getAccountBalance(accountId)
  if type(accountId) ~= 'number' then return nil, 'Hesap ID sayı olmalı' end
  return getBusinessBalance(accountId)
end

local function addAccountMoney(accountId, amount, reason)
  if type(accountId) ~= 'number' then return false, 'Hesap ID sayı olmalı' end
  return addBusinessMoney(accountId, amount, reason)
end

local function removeAccountMoney(accountId, amount, reason)
  if type(accountId) ~= 'number' then return false, 'Hesap ID sayı olmalı' end
  return removeBusinessMoney(accountId, amount, reason)
end

local function getAccounts(src)
  src = tonumber(src)
  if not src or not GetPlayerName(src) then return {} end
  return NN.MyAccounts(src)
end

local function getTransactions(src, selector, limit)
  local account = resolveAccount(src, selector)
  if not account then return {} end
  return NN.RecentTxns(account.id, math.max(1, math.min(100, tonumber(limit) or 50)))
end

local function getAccountNumber(src)
  src = tonumber(src)
  if not src or not GetPlayerName(src) then return nil end
  local account = NN.PrimaryAccount(src)
  return account and account.accountNumber or nil
end

local function addTransaction(src, direction, amount, category, counterparty, description, selector)
  src = tonumber(src)
  local account, err = resolveAccount(src, selector)
  direction = tostring(direction or ''):lower()
  if not account then return false, err end
  local rawAmount = tonumber(amount)
  if not rawAmount or rawAmount ~= rawAmount or rawAmount == math.huge or rawAmount == -math.huge then
    return false, 'Geçersiz tutar'
  end
  amount = NN.money(rawAmount)
  if direction == 'deposit' then direction = 'in' end
  if direction == 'withdraw' then direction = 'out' end
  if direction ~= 'in' and direction ~= 'out' then return false, 'Direction must be "in" or "out"' end
  if amount <= 0 then return false, 'Geçersiz tutar' end

  category = tostring(category or 'shopping'):lower()
  local categories = {
    transfer = true, atm = true, loan = true, savings = true, deposit = true,
    withdraw = true, paycheck = true, shopping = true, bills = true, fee = true,
    invoice = true, stocks = true,
  }
  if not categories[category] then return false, 'Geçersiz işlem kategorisi' end

  local invokingResource = GetInvokingResource() or 'External'
  local transaction = NN.Lock('acct:' .. account.accountNumber, function()
    return NN.LogTxn(
      account.id,
      direction,
      amount,
      category,
      tostring(counterparty or invokingResource):sub(1, 64),
      tostring(description or 'Harici işlem'):sub(1, 128)
    )
  end)
  if not transaction or not transaction.id then return false, 'İşlem kaydı başarısız' end
  if NN.ActiveAccountId(src) == account.id then
    NN.Push(src, 'txnAdded', { transaction = transaction })
  end
  return true, transaction
end

local function createInvoice(fromSrc, toSrc, amount, reason, options)
  if not NN.CreateInvoice then return false, 'Fatura hizmeti kullanılamıyor' end
  options = type(options) == 'table' and options or {}
  local result = NN.CreateInvoice(tonumber(fromSrc), {
    target = tonumber(toSrc), amount = amount, reason = reason,
  }, {
    requireNearby = options.requireNearby == true,
    recipient = options.recipient,
  })
  return result.ok == true, result.invoice or result.error
end

local function getInvoice(id)
  return NN.GetInvoice and NN.GetInvoice(id) or nil
end

local function getInvoices(src, limit)
  if not NN.ListInvoices then return { incoming = {}, outgoing = {} } end
  local result = NN.ListInvoices(tonumber(src), limit)
  return result.ok and { incoming = result.incoming, outgoing = result.outgoing } or { incoming = {}, outgoing = {} }
end

local function getPendingInvoices(src, direction, limit)
  local invoices = getInvoices(src, limit)
  local selected = direction == 'outgoing' and invoices.outgoing or invoices.incoming
  local pending = {}
  for _, invoice in ipairs(selected) do
    if invoice.status == 'pending' then pending[#pending + 1] = invoice end
  end
  return pending
end

local function getPendingInvoiceTotal(src, direction)
  local total = 0
  for _, invoice in ipairs(getPendingInvoices(src, direction, 100)) do total = total + NN.whole(invoice.amount) end
  return total
end

local function payInvoice(src, invoiceId)
  if not NN.PayInvoice then return false, 'Fatura hizmeti kullanılamıyor' end
  local result = NN.PayInvoice(tonumber(src), { id = tonumber(invoiceId) })
  return result.ok == true, result.ok and result or result.error
end

local function declineInvoice(src, invoiceId)
  if not NN.DeclineInvoice then return false, 'Fatura hizmeti kullanılamıyor' end
  local result = NN.DeclineInvoice(tonumber(src), { id = tonumber(invoiceId) })
  return result.ok == true, result.ok and result or result.error
end

local function cancelInvoice(src, invoiceId)
  if not NN.CancelInvoice then return false, 'Fatura hizmeti kullanılamıyor' end
  local result = NN.CancelInvoice(tonumber(src), tonumber(invoiceId))
  return result.ok == true, result.ok and result or result.error
end

exports('GetAccount', getAccount)
exports('GetBalance', getBalance)
exports('GetAccounts', getAccounts)
exports('GetTransactions', getTransactions)
exports('GetAccountNumber', getAccountNumber)
exports('AddTransaction', addTransaction)
exports('AddMoney', addMoney)
exports('RemoveMoney', removeMoney)
exports('GetBusinessAccount', getBusinessAccount)
exports('GetBusinessBalance', getBusinessBalance)
exports('AddBusinessMoney', addBusinessMoney)
exports('RemoveBusinessMoney', removeBusinessMoney)
exports('GetAccountBalance', getAccountBalance)
exports('AddAccountMoney', addAccountMoney)
exports('RemoveAccountMoney', removeAccountMoney)
exports('CreateInvoice', createInvoice)
exports('GetInvoice', getInvoice)
exports('GetInvoices', getInvoices)
exports('GetPendingInvoices', getPendingInvoices)
exports('GetPendingInvoiceTotal', getPendingInvoiceTotal)
exports('PayInvoice', payInvoice)
exports('DeclineInvoice', declineInvoice)
exports('CancelInvoice', cancelInvoice)

exports('getAccount', getAccount)
exports('getBalance', getBalance)
exports('getAccounts', getAccounts)
exports('getTransactions', getTransactions)
exports('getAccountNumber', getAccountNumber)
exports('addTransaction', addTransaction)
exports('addMoney', addMoney)
exports('removeMoney', removeMoney)
exports('getBusinessAccount', getBusinessAccount)
exports('getBusinessBalance', getBusinessBalance)
exports('addBusinessMoney', addBusinessMoney)
exports('removeBusinessMoney', removeBusinessMoney)
exports('getAccountBalance', getAccountBalance)
exports('addAccountMoney', addAccountMoney)
exports('removeAccountMoney', removeAccountMoney)
exports('createInvoice', createInvoice)
exports('getInvoice', getInvoice)
exports('getInvoices', getInvoices)
exports('getPendingInvoices', getPendingInvoices)
exports('getPendingInvoiceTotal', getPendingInvoiceTotal)
exports('payInvoice', payInvoice)
exports('declineInvoice', declineInvoice)
exports('cancelInvoice', cancelInvoice)
