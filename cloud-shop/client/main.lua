if not LoadResourceFile(cache.resource, "web/dist/index.html") then
	error(
		"UI has not been built! Download the release version from https://github.com/cloud-resources/cloud-shop/releases")
end

-- Configuration
local Config = require("config.main")
local Functions = require("config.functions")

-- Locales
local locales = lib.loadJson(("locales.%s"):format(Config.Locale))

-- Modules
local Interaction = require("client.modules.interaction")
local ShopPeds = require("client.modules.shop-ped")
local handleTransaction = require("client.modules.transaction")
local OpenOwnerMenu = require("client.modules.owner_menu")

--[[ Initialization ]]

LocalPlayer.state:set("currentShop", nil, true)
LocalPlayer.state:set("currentBusinessId", nil, true)

local function getInteractDistance(shopData)
	if shopData.Interaction.HelpText.enabled then
		return shopData.Interaction.HelpText.distance
	elseif shopData.Interaction.FloatingText.enabled then
		return shopData.Interaction.FloatingText.distance
	end
	return nil
end

local function createPoints(shopKey, shopData, shopCoords, index)
	local businessId = (shopKey == "shop" and "market_" or (shopKey:gsub("%[", ""):gsub("%]", "") .. "_")) ..
		(index or 1)
	local shopPoint = lib.points.new({
		coords = shopCoords,
		distance = shopData.PointRadius,
		interactDistance = getInteractDistance(shopData),
		ped = nil,
	})

	function shopPoint:onEnter()
		if shopData.Indicator.Ped.enabled then self.ped = ShopPeds.Spawn(shopData, shopCoords) end
		if shopData.Interaction.Target.enabled then
			self.targetId = Functions.Interact.AddTarget(shopKey, shopData, shopCoords, Interaction.Open, index)
		end
	end

	function shopPoint:onExit()
		if shopData.Indicator.Ped.enabled then ShopPeds.Delete(self.ped) end
		if self.targetId then
			exports.ox_target:removeZone(self.targetId)
			self.targetId = nil
		end
	end

	function shopPoint:nearby()
		-- if not LocalPlayer.state["currentShop"] then
		-- 	if shopData.Indicator.Marker.enabled then
		-- 		local markerConfig = shopData.Indicator.Marker
		-- 		---@diagnostic disable-next-line: missing-parameter
		-- 		DrawMarker(markerConfig.type, self.coords.x, self.coords.y, self.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
		-- 			markerConfig.size.x, markerConfig.size.y, markerConfig.size.z, markerConfig.color[1],
		-- 			markerConfig.color[2],
		-- 			markerConfig.color[3], markerConfig.color[4], markerConfig.bobUpAndDown, markerConfig.faceCamera, 2,
		-- 			markerConfig.rotate)
		-- 	end
		-- end

		-- if shopData.Interaction.HelpText.enabled or shopData.Interaction.FloatingText.enabled then
		-- 	if self.isClosest and self.currentDistance <= self.interactDistance then
		-- 		if IsPlayerDead(cache.playerId) or IsPedInAnyVehicle(cache.ped, false) then return end

		-- 		if not LocalPlayer.state["currentShop"] then
		-- 			if shopData.Interaction.HelpText.enabled then
		-- 				Functions.Interact.HelpText(locales.interaction
		-- 					.help_text)
		-- 			end
		-- 			if shopData.Interaction.FloatingText.enabled then
		-- 				Functions.Interact.FloatingHelpText(locales.interaction.floating_text
		-- 				, self.ped, self.coords)
		-- 			end
		-- 		end

		-- 		if IsControlJustReleased(0, shopData.Interaction.OpenKey) then Interaction.Open(shopKey, shopData, index) end

		-- 		if IsControlJustReleased(0, 47) then
		-- 			local isOwned = lib.callback.await('can9work_auction:server:checkOwnership', false, businessId)
		-- 			if isOwned then
		-- 				OpenOwnerMenu(businessId)
		-- 			else
		-- 				Functions.Notify.Client({
		-- 					title = "Hata",
		-- 					description = "Bu işletmenin sahibi siz değilsiniz!",
		-- 					type = "error"
		-- 				})
		-- 			end
		-- 		end
		-- 	end
		-- end
	end
end

CreateThread(function()
	for shopKey, shopData in pairs(Config.Shops) do
		for i = 1, #shopData.Locations do
			local shopCoords = shopData.Locations[i]

			if shopData.Blip.enabled then createBlip(shopCoords, shopData.Blip) end
			createPoints(shopKey, shopData, shopCoords, i)
		end
	end
end)

--[[ NUI Callbacks ]]

RegisterNUICallback("shop:callback", function(data, cb)
	local actionName = data.action
	if type(actionName) ~= "string" then return end

	local shopData = Config.Shops[LocalPlayer.state["currentShop"]]
	local businessId = LocalPlayer.state["currentBusinessId"]

	local handlers = {
		closeShop = function()
			local success = pcall(Interaction.Close)
			cb(success)
		end,

		payItems = function()
			local success = handleTransaction(data.type, data.cart, businessId)
			if success then ShopPeds.ApplySpeech("Generic_Thanks", "Speech_Params_Force_Shouted_Critical") end
			cb(success)
		end,

		-- Initialization

		getCategories = function()
			cb(shopData.Categories)
		end,
		getItems = function()
			local storeOwner = lib.callback.await("cloud-shop:server:getStoreOwner", false, businessId)
			local businessStats = lib.callback.await("cloud-shop:server:getBusinessStats", false, businessId)
			local unownedStorePriceMultiplier = tonumber(Config.UnownedStorePriceMultiplier) or 1.0
			if unownedStorePriceMultiplier <= 0 then unownedStorePriceMultiplier = 1.0 end


			if storeOwner then
				local sqlItems = (businessStats and businessStats.items) or {}
				local items = {}
				for _, configItem in ipairs(shopData.Items) do
					local sqlItem = sqlItems[configItem.name]
					local stock = sqlItem and sqlItem.stock or 0
					local price = sqlItem and sqlItem.price or math.floor(configItem.price * unownedStorePriceMultiplier)
					items[#items + 1] = {
						name = configItem.name,
						label = ("[%d] %s"):format(stock, configItem.label),
						price = price,
						description = ("Stock: %s"):format(stock),
						category = configItem.category
					}
				end
				cb(items)
			else
				local items = {}
				for _, item in pairs(shopData.Items) do
					items[#items + 1] = {
						name = item.name,
						label = item.label,
						price = math.floor(item.price * unownedStorePriceMultiplier),
						description = item.description,
						category = item.category
					}
				end
				cb(items)
			end
		end,
		getLocales = function()
			locales.ui.main.header = shopData.Locales.MainHeader
			locales.ui.cart.header = shopData.Locales.CartHeader
			cb({ imagePath = Config.ImagePath, soundVolume = (GetProfileSetting(300) / 10), locales = locales.ui })
		end,

		-- Sounds

		selectCategory = function()
			playSound("select")
			cb(true)
		end,
		addItem = function()
			playSound("add")
			cb(true)
		end,
		updateQuantity = function()
			playSound("quantity")
			cb(true)
		end,
		removeItem = function()
			playSound("remove")
			cb(true)
		end,
	}

	local handler = handlers[actionName]
	if handler then handler() end
end)

-- [[ Clean Up ]]

local function cleanUp()
	Interaction.CloseUI()
	ShopPeds.DeleteAll()
end

AddEventHandler("onResourceStop", function(resource)
	if resource ~= cache.resource then return end
	cleanUp()
end)

exports("GetShopCoords", function()
	local coords = {}
	for _, shop in pairs(Config.Shops) do
		if shop.Locations then
			for _, loc in pairs(shop.Locations) do
				coords[#coords + 1] = loc
			end
		end
	end
	return coords
end)
