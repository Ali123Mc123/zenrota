local function handleTransaction(transactionType, cartArray, currentStore)
	local success, reason = lib.callback.await("cloud-shop:processTransaction", false, transactionType, cartArray, currentStore)
	if reason then log.debug("[handleTransaction]", reason) end

	playSound(success and "purchase" or "error")
	return success
end

return handleTransaction
