if not lib then return end

-----------------------------------------------------------------------------------------------
-- Avatar Configuration
-- Set your Discord Bot Token or Steam API Key below to enable player avatars
-- The bot must be in your Discord server (guild) and have the Server Members Intent enabled [Discord]
-- Steam: Get your API key at https://steamcommunity.com/dev/apikey
-----------------------------------------------------------------------------------------------
server.discordBotToken = ''
server.discordGuildId = '' -- Your Discord server/guild ID (right-click server → Copy Server ID)
server.steamApiKey = ''

require 'modules.bridge.server'
require 'modules.crafting.server'
require 'modules.shops.server'
require 'modules.pefcl.server'
require 'modules.backpack.server'
require 'modules.favorites.server'
require 'modules.equipment.server'

if GetConvar('inventory:versioncheck', 'true') == 'true' then
	lib.versionCheck('communityox/ox_inventory')
end

local TriggerEventHooks = require 'modules.hooks.server'
local db = require 'modules.mysql.server'
local Items = require 'modules.items.server'
local Inventory = require 'modules.inventory.server'
local Utils = require 'modules.utils.server'

---@param player table
---@param data table?
--- player requires source, identifier, and name
--- optionally, it should contain jobs/groups, sex, and dateofbirth
function server.setPlayerInventory(player, data)
	while not shared.ready do Wait(0) end

	if not data then
		data = db.loadPlayer(player.identifier)
	end

	local inventory = {}
	local totalWeight = 0

	if type(data) == 'table' then
		local ostime = os.time()

		for _, v in pairs(data) do
			if type(v) == 'number' or not v.count or not v.slot then
				if server.convertInventory then
					inventory, totalWeight = server.convertInventory(player.source, data)
					break
				else
					return error(('Inventory for player.%s (%s) contains invalid data. Ensure you have converted inventories to the correct format.'):format(player.source, GetPlayerName(player.source)))
				end
			else
				local item = Items(v.name)

				if item then
					v.metadata = Items.CheckMetadata(v.metadata or {}, item, v.name, ostime)
					local weight = Inventory.SlotWeight(item, v)
					totalWeight = totalWeight + weight

					inventory[v.slot] = {name = item.name, label = item.label, weight = weight, slot = v.slot, count = v.count, description = item.description, metadata = v.metadata, stack = item.stack, close = item.close}
				end
			end
		end
	end

	player.source = tonumber(player.source)
	local inv = Inventory.Create(player.source, player.name, 'player', shared.playerslots, totalWeight, shared.playerweight, player.identifier, inventory)

	if inv then
		inv.player = server.setPlayerData(player)
		inv.player.ped = GetPlayerPed(player.source)

		if server.syncInventory then server.syncInventory(inv) end
		TriggerClientEvent('ox_inventory:setPlayerInventory', player.source, Inventory.Drops, inventory, totalWeight, inv.player)
	end
end
exports('setPlayerInventory', server.setPlayerInventory)
AddEventHandler('ox_inventory:setPlayerInventory', server.setPlayerInventory)

local registeredDumpsters = {}

---@param coords vector3
---@return string?
local function getDumpsterFromCoords(coords)
	local found

	for i = 1, #registeredDumpsters do
		local distance = #(coords - registeredDumpsters[i])

		if distance < 0.1 then
			found = i
			break
		end
	end

	return found
end

---@param playerPed number
---@param stash OxInventory
---@return vector3?
local function getClosestStashCoords(playerPed, stash)
	local playerCoords = GetEntityCoords(playerPed)
	local distance = stash.distance or 10
    local coordinates = stash.coords

    if not coordinates then return end

	if type(coordinates) == 'table' then
		for i = 1, #coordinates do
			local coords = coordinates[i] --[[@as vector3]]

			if #(coords - playerCoords) < distance then
				return coords
			end
		end

		return
	end

	return #(coordinates - playerCoords) < distance and coordinates or nil
end

---@param source number
---@param invType string
---@param data? string|number|table
---@param ignoreSecurityChecks boolean?
---@return table | false | nil, table | false | nil, string?
local function openInventory(source, invType, data, ignoreSecurityChecks)
	if Inventory.Lock then return false end

	local left = Inventory(source)
	local right, closestCoords

    if not left then return end

    left:closeInventory(true)
	Inventory.CloseAll(left, source)

    if invType == 'player' and data == source then
        data = nil
    end

    local playerPed = left.player.ped

	if data then
        local isDataTable = type(data) == 'table'

		if invType == 'stash' then
			right = Inventory(data, left, ignoreSecurityChecks)
			if right == false then return false end
		elseif isDataTable then
			if data.netid then
                local entity = NetworkGetEntityFromNetworkId(data.netid)

                if not entity then return end

                if not ignoreSecurityChecks then
                    if #(GetEntityCoords(playerPed) - GetEntityCoords(entity)) > 16 then return end
                end

                if invType == 'glovebox' then
                    if not ignoreSecurityChecks and GetVehiclePedIsIn(playerPed, false) ~= entity then
                        return
                    end
                end

                if invType == 'trunk' then
                    local lockStatus = ignoreSecurityChecks and 0 or GetVehicleDoorLockStatus(entity)

                    -- 0: no lock; 1: unlocked; 8: boot unlocked
                    if lockStatus > 1 and lockStatus ~= 8 then
                        return false, false, 'vehicle_locked'
                    end
                end

                local plate = (invType == 'glovebox' or invType == 'trunk') and GetVehicleNumberPlateText(entity)

                if plate then
                    if server.trimplate then plate = string.strtrim(plate) end

                    if GetResourceState('daddy-fakeplate') == 'started' then
                        local originalPlate = exports['daddy-fakeplate']:GetOriginalPlate(plate)
                        if originalPlate then
                            plate = originalPlate
                        end
                    end

                    if not data.id  then
                        data.id = (invType == 'glovebox' and 'glove' or 'trunk') .. plate
                    end
                end

				data.type = invType
				right = Inventory(data)

				if right and data.netid ~= right.netid then
					local invEntity = NetworkGetEntityFromNetworkId(right.netid)

					if not (invEntity > 0 and DoesEntityExist(invEntity)) or (plate and not string.match(GetVehicleNumberPlateText(invEntity) or '', plate)) then
						Inventory.Remove(right)
						right = Inventory(data)
					end
				end
			elseif invType == 'drop' then
				right = Inventory(data.id)
			else
				return
			end
		elseif invType == 'policeevidence' then
			if ignoreSecurityChecks or server.hasGroup(left, shared.police) then
				right = Inventory(('evidence-%s'):format(data))
			end
		elseif invType == 'dumpster' then
			if shared.networkdumpsters then
				local dumpsterId = getDumpsterFromCoords(data)
				right = dumpsterId and Inventory(('dumpster-%s'):format(dumpsterId))

				if not right then
					dumpsterId = #registeredDumpsters + 1
					right = Inventory.Create(('dumpster-%s'):format(dumpsterId), locale('dumpster'), invType, 15, 0, 100000, false)
					registeredDumpsters[dumpsterId] = data
				end
			else
				---@cast data string
				right = Inventory(data)

				if not right then
					local netid = tonumber(data:sub(9))

					if netid and NetworkGetEntityFromNetworkId(netid) > 0 then
						right = Inventory.Create(data, locale('dumpster'), invType, 15, 0, 100000, false)
					end
				end
			end
		elseif invType == 'container' then
			left.containerSlot = data --[[@as number]]
			data = left.items[data]

			if data then
				right = Inventory(data.metadata.container)

				if not right then
					right = Inventory.Create(data.metadata.container, data.label, invType, data.metadata.size[1], 0, data.metadata.size[2], false)
				end
			else left.containerSlot = nil end
		else right = Inventory(data) end

		if not right then return end

        -- Security check to make sure the requested inventory type is the same as the found inventory
        -- Only case where a missmatch is tolerated is for temporary stashes
        if right.type ~= invType and not (right.type == 'temp' and invType == 'stash') then
            DropPlayer(source, 'sussy')
            return
        end

		if not ignoreSecurityChecks and right.groups and not server.hasGroup(left, right.groups) then return end

		local hookPayload = {
			source = source,
			inventoryId = right.id,
			inventoryType = right.type,
		}

		if invType == 'container' then hookPayload.slot = left.containerSlot end
		if isDataTable and data.netid then hookPayload.netId = data.netid end

		if not TriggerEventHooks('openInventory', hookPayload) then return end

        if left == right then return end

		if right.player then
			if right.open then return end

			right.coords = not ignoreSecurityChecks and GetEntityCoords(right.player.ped) or nil
		end

		if not ignoreSecurityChecks and right.coords then
			closestCoords = getClosestStashCoords(playerPed, right)

			if not closestCoords then return end
		end

		if not ignoreSecurityChecks and right.groups and not server.hasGroup(left, right.groups) then
			return false, false, 'cannot_access'
		end

		left:openInventory(right)
	else
		left:openInventory(left)
	end

	local playerInfo = left.player and {
		name = left.player.name,
		id = left.player.id or left.id,
		cash = Inventory.GetItemCount(left, 'money') or 0,
		bank = server.getPlayerBank and server.getPlayerBank(left.id) or 0,
		avatar = left.player.avatar
	} or nil

	return {
		id = left.id,
		label = left.label,
		type = left.type,
		slots = left.slots,
		weight = left.weight,
		maxWeight = left.maxWeight,
		playerInfo = playerInfo
	}, right and {
		id = right.id,
		label = right.player and '' or right.label,
		type = right.player and 'otherplayer' or right.type,
		slots = right.slots,
		weight = right.weight,
		maxWeight = right.maxWeight,
		items = right.items,
		coords = closestCoords or right.coords,
		distance = right.distance
	}
end

---@param source number
---@param invType string
---@param data string|number|table
lib.callback.register('ox_inventory:openInventory', function(source, invType, data)
    if invType == 'player' and source ~= data then
        local serverId = type(data) == 'table' and data.id or data

        if source == serverId or type(serverId) ~= 'number' then return end

        local left = Inventory(source)
        if not left then return end

        local isPolice = server.hasGroup(left, shared.police)
        local isTargetStealable = Player(serverId).state.canSteal

        if not isPolice and not isTargetStealable then return end
    end

    return openInventory(source, invType, data)
end)

---@param netId number
lib.callback.register('ox_inventory:isVehicleATrailer', function(source, netId)
	local entity = NetworkGetEntityFromNetworkId(netId)
	local retval = GetVehicleType(entity)
	return retval == 'trailer'
end)

---@param playerId number
---@param invType string
---@param data string|number|table
function server.forceOpenInventory(playerId, invType, data)
	local left, right = openInventory(playerId, invType, data, true)

	if left and right then
		TriggerClientEvent('ox_inventory:forceOpenInventory', playerId, left, right)
		return right.id
	end
end

exports('forceOpenInventory', server.forceOpenInventory)

local Licenses = lib.load('data.licenses')

lib.callback.register('ox_inventory:buyLicense', function(source, id)
	local license = Licenses[id]
	if not license then return end

	local inventory = Inventory(source)
	if not inventory then return end

	return server.buyLicense(inventory, license)
end)

lib.callback.register('ox_inventory:getItemCount', function(source, item, metadata, target)
	local inventory = target and Inventory(target) or Inventory(source)
	return (inventory and Inventory.GetItemCount(inventory, item, metadata, true))
end)

lib.callback.register('ox_inventory:getInventory', function(source, id)
	local inventory = Inventory(id or source)
	return inventory and {
		id = inventory.id,
		label = inventory.label,
		type = inventory.type,
		slots = inventory.slots,
		weight = inventory.weight,
		maxWeight = inventory.maxWeight,
		owned = inventory.owner and true or false,
		items = inventory.items
	}
end)

RegisterNetEvent('ox_inventory:usedItemInternal', function(slot)
    local inventory = Inventory(source)

    if not inventory then return end

    local item = inventory.usingItem

    if not item or item.slot ~= slot then
        ---@todo
        DropPlayer(inventory.id, 'sussy')

        return
    end

    TriggerEvent('ox_inventory:usedItem', inventory.id, item.name, item.slot, next(item.metadata) and item.metadata)

    inventory.usingItem = nil
end)

---@param source number
---@param itemName string
---@param slot number?
---@param metadata { [string]: any }?
---@return table | boolean | nil
lib.callback.register('ox_inventory:useItem', function(source, itemName, slot, metadata, noAnim)
	local inventory = Inventory(source)

	if inventory and inventory.player then
		local item = Items(itemName)

		if item and item.groups and not server.hasGroup(inventory, item.groups) then
			return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Bu eşyayı / silahı kullanmak için meslek yetkiniz yok.' })
		end

		local data = item and (slot and inventory.items[slot] or Inventory.GetSlotWithItem(inventory, item.name, metadata, true))

		if not data then return end

		slot = data.slot
		local durability = data.metadata.durability --[[@as number|boolean|nil]]
		local consume = item.consume
		local label = data.metadata.label or item.label

		if durability and consume then
			if durability > 100 then
				local ostime = os.time()

				if ostime > durability then
                    Items.UpdateDurability(inventory, data, item, 0)
					return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('no_durability', label) })
				elseif consume ~= 0 and consume < 1 then
					local degrade = (data.metadata.degrade or item.degrade) * 60
					local percentage = ((durability - ostime) * 100) / degrade

					if percentage < consume * 100 then
						return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('not_enough_durability', label) })
					end
				end
			elseif durability <= 0 then
				return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('no_durability', label) })
			elseif consume ~= 0 and consume < 1 and durability < consume * 100 then
				return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('not_enough_durability', label) })
			end

			if data.count > 1 and consume < 1 and consume > 0 and not Inventory.GetEmptySlot(inventory) then
				return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('cannot_use', label) })
			end
		end

		if item and data and data.count > 0 and data.name == item.name then
			data = {name=data.name, label=label, count=data.count, slot=slot, metadata=data.metadata, weight=data.weight}

			if item.ammo then
				if inventory.weapon then
					local weapon = inventory.items[inventory.weapon]

					if weapon and weapon?.metadata.durability > 0 then
						consume = nil
					end
				else return false end
			elseif item.component or item.tint then
				consume = 1
				data.component = true
			elseif consume then
				if data.count >= consume then
					local result = item.cb and item.cb('usingItem', item, inventory, slot)

					if result == false then return end

					if result ~= nil then
						data.server = result
					end
				else
					return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = locale('item_not_enough', item.name) })
				end
			elseif not item.weapon and server.UseItem then
                inventory.usingItem = data
				-- This is used to call an external useItem function, i.e. ESX.UseItem
				-- If an error is being thrown on item use there is no internal solution. We previously kept a list
				-- of usable items which led to issues when restarting resources (for obvious reasons), but config
				-- developers complained the inventory broke their items. Safely invoking registered item callbacks
				-- should resolve issues, i.e. https://github.com/esx-framework/esx-legacy/commit/9fc382bbe0f5b96ff102dace73c424a53458c96e
				return pcall(server.UseItem, source, data.name, data)
			end

			data.consume = consume

            if not TriggerEventHooks('usingItem', {
				source = source,
                inventoryId = inventory and inventory.id,
                item = inventory.items[slot],
                consume = consume
			}) then return false end

            ---@type boolean
			local success = lib.callback.await('ox_inventory:usingItem', source, data, noAnim)

			if item.weapon then
				inventory.weapon = success and slot or nil
			end

			if not success then return end

            inventory.usingItem = data

			if consume and consume ~= 0 and not data.component then
				data = inventory.items[data.slot]

				if not data then return end

				durability = consume ~= 0 and consume < 1 and data.metadata.durability --[[@as number | false]]

				if durability then
					if durability > 100 then
						local degrade = (data.metadata.degrade or item.degrade) * 60
						durability -= degrade * consume
					else
						durability -= consume * 100
					end

					if data.count > 1 then
						local emptySlot = Inventory.GetEmptySlot(inventory)

						if emptySlot then
							local newItem = Inventory.SetSlot(inventory, item, 1, table.deepclone(data.metadata), emptySlot)

							if newItem then
                                Items.UpdateDurability(inventory, newItem, item, durability)
							end
						end

						durability = 0
					else
                        Items.UpdateDurability(inventory, data, item, durability)
					end

					if durability <= 0 then
						durability = false
					end
				end

				if not durability then
					Inventory.RemoveItem(inventory.id, data.name, consume < 1 and 1 or consume, nil, data.slot)
				else
					inventory.changed = true

					if server.syncInventory then server.syncInventory(inventory) end
				end

				TriggerEvent('ox_inventory:usedItem', source, data.name, data.slot, data.metadata)
				TriggerClientEvent('ox_inventory:usedItem', source, data.name, data.slot, data.metadata)

				if item?.cb then
					item.cb('usedItem', item, inventory, data.slot)
				end
			end

			return true
		end
	end
end)

local function conversionScript()
	shared.ready = false

	local file = 'setup/convert.lua'
	local import = LoadResourceFile(shared.resource, file)
	local func = load(import, ('@@%s/%s'):format(shared.resource, file)) --[[@as function]]

	conversionScript = func()
end

RegisterCommand('convertinventory', function(source, args)
	if source ~= 0 then return warn('This command can only be executed with the server console.') end
	if type(conversionScript) == 'function' then conversionScript() end
	local arg = args[1]

	local convert = arg and conversionScript[arg]

	if not convert then
		return warn('Invalid conversion argument. Valid options: esx, esxproperty')
	end

	CreateThread(convert)
end, true)


lib.addCommand({'additem', 'giveitem'}, {
	help = 'Gives an item to a player with the given id',
	params = {
		{ name = 'target', type = 'playerId', help = 'The player to receive the item' },
		{ name = 'item', type = 'string', help = 'The name of the item' },
		{ name = 'count', type = 'number', help = 'The amount of the item to give', optional = true },
		{ name = 'type', help = 'Sets the "type" metadata to the value', optional = true },
	},
	restricted = 'group.admin',
}, function(source, args)
	local item = Items(args.item)

	if item then
		local inventory = Inventory(args.target) --[[@as OxInventory]]
		local count = args.count and math.max(args.count, 1) or 1

		local success, response = Inventory.AddItem(inventory, item.name, count, args.type and { type = tonumber(args.type) or args.type })

		if not success then
			return Citizen.Trace(('Failed to give %sx %s to player %s (%s)'):format(count, item.name, args.target, response))
		end

		source = Inventory(source) or { label = 'console', owner = 'console' }

		if server.loglevel > 0 then
			lib.logger(source.owner, 'admin', ('"%s" gave %sx %s to "%s"'):format(source.label, count, item.name, inventory.label))
		end
	end
end)

lib.addCommand('removeitem', {
	help = 'Removes an item to a player with the given id',
	params = {
		{ name = 'target', type = 'playerId', help = 'The player to remove the item from' },
		{ name = 'item', type = 'string', help = 'The name of the item' },
		{ name = 'count', type = 'number', help = 'The amount of the item to take', optional = true },
		{ name = 'type', help = 'Only remove items with a matching metadata "type"', optional = true },
	},
	restricted = 'group.admin',
}, function(source, args)
	local item = Items(args.item)

	if item then
		local inventory = Inventory(args.target) --[[@as OxInventory]]
		local count = args.count and math.max(args.count, 1) or 1

		local success, response = Inventory.RemoveItem(inventory, item.name, count, args.type and { type = tonumber(args.type) or args.type }, nil, true)

		if not success then
			return Citizen.Trace(('Failed to remove %sx %s from player %s (%s)'):format(count, item.name, args.target, response))
		end

		source = Inventory(source) or {label = 'console', owner = 'console'}

		if server.loglevel > 0 then
			lib.logger(source.owner, 'admin', ('"%s" removed %sx %s from "%s"'):format(source.label, count, item.name, inventory.label))
		end
	end
end)

lib.addCommand('setitem', {
	help = 'Sets the item count for a player, removing or adding as needed',
	params = {
		{ name = 'target', type = 'playerId', help = 'The player to set the items for' },
		{ name = 'item', type = 'string', help = 'The name of the item' },
		{ name = 'count', type = 'number', help = 'The amount of items to set', optional = true },
		{ name = 'type', help = 'Add or remove items with the metadata "type"', optional = true },
	},
	restricted = 'group.admin',
}, function(source, args)
	local item = Items(args.item)

	if item then
		local inventory = Inventory(args.target) --[[@as OxInventory]]
		local count = args.count and math.max(args.count, 0) or 0

		local success, response = Inventory.SetItem(inventory, item.name, count or 0, args.type and { type = tonumber(args.type) or args.type })

		if not success then
			return Citizen.Trace(('Failed to set %s count to %sx for player %s (%s)'):format(item.name, count, args.target, response))
		end

		source = Inventory(source) or {label = 'console', owner = 'console'}

		if server.loglevel > 0 then
			lib.logger(source.owner, 'admin', ('"%s" set "%s" %s count to %sx'):format(source.label, inventory.label, item.name, count))
		end
	end
end)

lib.addCommand('clearevidence', {
	help = 'Clears a police evidence locker with the given id',
	params = {
		{ name = 'locker', type = 'number', help = 'The locker id to clear' },
	},
}, function(source, args)
	if not server.isPlayerBoss then return end

	local inventory = Inventory(source)
	if not inventory then return end

	local group, grade = server.hasGroup(inventory, shared.police)
	local hasPermission = group and server.isPlayerBoss(source, group, grade)

	if hasPermission then
		MySQL.query('DELETE FROM ox_inventory WHERE name = ?', {('evidence-%s'):format(args.locker)})
	end
end)

lib.addCommand('takeinv', {
	help = 'Confiscates the target inventory, to restore with /restoreinv',
	params = {
		{ name = 'target', type = 'playerId', help = 'The player to confiscate items from' },
	},
	restricted = 'group.admin',
}, function(source, args)
	Inventory.Confiscate(args.target)
end)

lib.addCommand({'restoreinv', 'returninv'}, {
	help = 'Restores a previously confiscated inventory for the target',
	params = {
		{ name = 'target', type = 'playerId', help = 'The player to restore items to' },
	},
	restricted = 'group.admin',
}, function(source, args)
	Inventory.Return(args.target)
end)

lib.addCommand('clearinv', {
	help = 'Wipes all items from the target inventory',
	params = {
		{ name = 'invId', help = 'The inventory to wipe items from' },
	},
	restricted = 'group.admin',
}, function(source, args)
	Inventory.Clear(tonumber(args.invId) or args.invId == 'me' and source or args.invId)
end)

lib.addCommand('saveinv', {
	help = 'Save all pending inventory changes to the database',
	params = {
		{ name = 'lock', help = 'Lock inventory access, until restart or saved without a lock', optional = true },
	},
	restricted = 'group.admin',
}, function(source, args)
	Inventory.SaveInventories(args.lock == 'true', false)
end)

lib.addCommand('viewinv', {
	help = 'Inspect the target inventory without allowing interactions',
	params = {
		{ name = 'invId', help = 'The inventory to inspect' },
	},
	restricted = 'group.admin',
}, function(source, args)
	Inventory.InspectInventory(source, tonumber(args.invId) or args.invId)
end)

-- Test command to add carbine rifle with attachments for testing attachment removal feature
-- lib.addCommand('testcarbine', {
-- 	help = '[TEST] Add carbine rifle with 2 attachments for testing',
-- 	params = {
-- 		{ name = 'target', type = 'playerId', help = 'The player to give the carbine to', optional = true },
-- 	},
-- }, function(source, args)
-- 	local targetSource = args.target or source
-- 	local inventory = Inventory(targetSource)

-- 	if not inventory then return end

-- 	-- Add carbine rifle with 2 test attachments (flashlight and suppressor)
-- 	local testMetadata = {
-- 		components = { 'at_flashlight', 'at_suppressor_heavy' },
-- 		ammo = 120
-- 	}

-- 	print('^2[DEBUG] Adding Carbine Rifle with metadata: ^7' .. json.encode(testMetadata))

-- 	local success = Inventory.AddItem(inventory, 'WEAPON_CARBINERIFLE', 1, testMetadata)

-- 	-- Check what was actually stored
-- 	local storedItem = Inventory.GetSlotWithItem(inventory, 'WEAPON_CARBINERIFLE')
-- 	if storedItem then
-- 		print('^2[DEBUG] Stored item metadata: ^7' .. json.encode(storedItem.metadata or {}))
-- 	end

-- 	shared.print('Added Carbine Rifle with attachments (Flashlight, Tactical Suppressor) to ' .. inventory.label)
-- end)

-----------------------------------------------------------------------------------------------
-- PD Kiti (Paketi) Kullanım İşleyişi
-----------------------------------------------------------------------------------------------
local kitItems = {
	{ name = 'phone', count = 1 },
	{ name = 'pd_radio', count = 1 },
	{ name = 'gps', count = 1 },
	{ name = 'WEAPON_SMOK2GRENADE', count = 2 },
	{ name = 'WEAPON_FLASHBANG', count = 2 },
	{ name = 'pd_medikit', count = 24 },
	{
		name = 'WEAPON_JNP_COMBAT_PISTOL',
		count = 1,
		metadata = {
			components = { 'at_clip_extended_pistol' },
			registered = true
		}
	},
	{ name = 'pdmermisi', count = 28 },
	{ name = 'pd_redbull', count = 13 },
	{ name = 'pd_armour', count = 20 },
	{ name = 'ifaks', count = 12 }
}

local pendingPDKit = {}

exports.ox_inventory:registerHook('usingItem', function(payload)
	local itemName = payload.item.name
	if itemName ~= 'pd_kit' then return end

	local source = payload.source
	local inventory = Inventory(source)
	if not inventory then return false end

	-- Araç içerisindeyken paketin açılmasını engelle
	local ped = GetPlayerPed(source)
	if ped and GetVehiclePedIsIn(ped, false) ~= 0 then
		TriggerClientEvent('ox_lib:notify', source, {
			type = 'error',
			description = 'Araç içerisindeyken bu paketi açamazsınız!'
		})
		return false
	end

	-- Sadece polisler açabilsin (leo / police kontrolü)
	if not server.hasGroup(inventory, { ['leo'] = 0 }) and not server.hasGroup(inventory, shared.police) then
		TriggerClientEvent('ox_lib:notify', source, {
			type = 'error',
			description = 'Bu kiti sadece polis memurları açabilir!'
		})
		return false
	end

	-- 1. Net ağırlık hesabı (pd_kit silineceği için onun ağırlığı hesaptan düşülür)
	local kitItemWeight = payload.item.weight or 32110
	local totalContentWeight = 0
	for _, it in ipairs(kitItems) do
		local itemDef = Items(it.name)
		if itemDef then
			totalContentWeight = totalContentWeight + Inventory.SlotWeight(itemDef, it)
		end
	end

	local netWeightAfterRemoval = inventory.weight - kitItemWeight
	if (netWeightAfterRemoval + totalContentWeight) > inventory.maxWeight then
		TriggerClientEvent('ox_lib:notify', source, {
			type = 'error',
			description = 'Envanteriniz bu paketteki teçhizatların toplam ağırlığını taşıyamaz!'
		})
		return false
	end

	-- 2. Boş slot kontrolü (pd_kit silineceği için +1 slot açılacak)
	local occupiedSlots = 0
	for _, itemData in pairs(inventory.items) do
		if itemData then occupiedSlots = occupiedSlots + 1 end
	end
	local freeSlots = inventory.slots - occupiedSlots
	local availableSlots = freeSlots + 1

	local requiredSlots = 0
	for _, it in ipairs(kitItems) do
		local itemDef = Items(it.name)
		local canStack = itemDef and itemDef.stack and not it.metadata
		local existingSlot = canStack and Inventory.GetSlotWithItem(inventory, it.name)
		if not existingSlot then
			requiredSlots = requiredSlots + 1
		end
	end

	if availableSlots < requiredSlots then
		TriggerClientEvent('ox_lib:notify', source, {
			type = 'error',
			description = ('Envanterinizde yeterli boş alan yok! (En az %d boş slot gerekli)'):format(requiredSlots)
		})
		return false
	end

	-- Ön kontroller başarıyla tamamlandı. Progress bar'ın başlaması için pending işaretle ve devam et.
	pendingPDKit[source] = {
		slot = payload.item and payload.item.slot or payload.slot,
		time = GetGameTimer()
	}

	-- ox_inventory'nin client progress bar'ı çalıştırması ve ardından consume etmesi için onay ver
	return true
end)

AddEventHandler('ox_inventory:usedItem', function(source, itemName, slot, metadata)
	if itemName ~= 'pd_kit' then return end

	-- Mükerrer çağrı veya yetkisiz tetikleme koruması
	local pending = pendingPDKit[source]
	if not pending then return end
	pendingPDKit[source] = nil

	-- Zaman aşımı kontrolü (progress bar 5sn, 15sn üzeri bayat istekleri reddet)
	if (GetGameTimer() - pending.time) > 15000 then
		return
	end

	local inventory = Inventory(source)
	if not inventory then return end

	-- Teçhizatları oyuncunun envanterine aktar
	for _, it in ipairs(kitItems) do
		local itemMeta = it.metadata and table.deepclone(it.metadata) or nil
		Inventory.AddItem(inventory, it.name, it.count, itemMeta)
	end

	TriggerClientEvent('ox_lib:notify', source, {
		type = 'success',
		description = 'PD Kiti başarıyla açıldı, tüm teçhizatlar envanterinize eklendi.'
	})
end)

AddEventHandler('playerDropped', function()
	pendingPDKit[source] = nil
end)
