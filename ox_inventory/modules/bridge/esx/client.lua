local ESX = setmetatable({}, {
	__index = function(self, index)
		local obj = exports.es_extended:getSharedObject()
		self.SetPlayerData = obj.SetPlayerData
		self.PlayerLoaded = obj.PlayerLoaded
		return self[index]
	end
})

---@diagnostic disable-next-line: duplicate-set-field
function client.setPlayerData(key, value)
	PlayerData[key] = value
	ESX.SetPlayerData(key, value)
end

---@diagnostic disable-next-line: duplicate-set-field
function client.setPlayerStatus(values)
	for name, value in pairs(values) do
		if value > 0 then TriggerEvent('esx_status:add', name, value) else TriggerEvent('esx_status:remove', name, -value) end
	end
end

---@diagnostic disable-next-line: duplicate-set-field
function client.getPlayerInfo()
	local ESX = exports.es_extended:getSharedObject()
	local xPlayer = ESX.GetPlayerData()
	local cash = 0
	local bank = 0

	if xPlayer and xPlayer.accounts then
		for _, account in pairs(xPlayer.accounts) do
			if account.name == 'money' then
				cash = account.money
			elseif account.name == 'bank' then
				bank = account.money
			end
		end
	end

	return {
		name = xPlayer and xPlayer.firstName and ('%s %s'):format(xPlayer.firstName, xPlayer.lastName) or GetPlayerName(PlayerId()),
		id = cache.serverId,
		cash = cash,
		bank = bank,
		avatar = PlayerData.avatar
	}
end

RegisterNetEvent('esx:onPlayerLogout', client.onLogout)

AddEventHandler('esx:setPlayerData', function(key, value)
	if not PlayerData.loaded or GetInvokingResource() ~= 'es_extended' then return end

	if key == 'job' then
		key = 'groups'
		value = { [value.name] = value.grade }
	end

	PlayerData[key] = value
	OnPlayerData(key, value)
end)

local Weapon = require 'modules.weapon.client'

RegisterNetEvent('esx_policejob:handcuff', function()
	PlayerData.cuffed = not PlayerData.cuffed
	LocalPlayer.state:set('invBusy', PlayerData.cuffed, true)

	if not PlayerData.cuffed then return end

	Weapon.Disarm()
end)

RegisterNetEvent('esx_policejob:unrestrain', function()
	PlayerData.cuffed = false
	LocalPlayer.state:set('invBusy', PlayerData.cuffed, true)
end)
