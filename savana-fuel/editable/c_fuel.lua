fuelSynced = false
inBlacklisted = false
isNearPump = nil

function GetFuel(vehicle)
	return DecorGetFloat(vehicle, Config.FuelDecor)
end

function SetFuel(vehicle, fuel)
	if type(fuel) == 'number' and fuel >= 0 then
		fuel = math.min(100.0, fuel)
		SetVehicleFuelLevel(vehicle, fuel + 0.0)
		DecorSetFloat(vehicle, Config.FuelDecor, GetVehicleFuelLevel(vehicle))
	end
end

function ManageFuelUsage(vehicle)
	if not DecorExistOn(vehicle, Config.FuelDecor) then
		-- Deniz araçları (class 14) her zaman tam yakıtla başlasın
		if GetVehicleClass(vehicle) == 14 then
			SetFuel(vehicle, 100.0)
		else
			SetFuel(vehicle, math.random(200, 800) / 10)
		end
	elseif not fuelSynced then
		SetFuel(vehicle, GetFuel(vehicle))

		fuelSynced = true
	end

	if IsVehicleEngineOn(vehicle) then
		if Config.NoFuelClasses and Config.NoFuelClasses[GetVehicleClass(vehicle)] then return end
		SetFuel(vehicle, GetVehicleFuelLevel(vehicle) - Config.FuelUsage[Round(GetVehicleCurrentRpm(vehicle), 1)] * (Config.Classes[GetVehicleClass(vehicle)] or 1.0) / 10)
	end
end

exports('GetFuel', GetFuel)
exports('SetFuel', SetFuel)

-- Özel Eklenen Benzinlik Propları ve Blipleri
local spawnedCustomPumps = {}
local spawnedCustomBlips = {}

local function cleanupOldPumpsNear(coords, radius)
	local r = radius or 80.0
	for _, modelName in ipairs(Config.PumpModelsName) do
		local hash = joaat(modelName)
		local obj = GetClosestObjectOfType(coords.x, coords.y, coords.z, r, hash, false, false, false)
		while obj ~= 0 and DoesEntityExist(obj) do
			SetEntityAsMissionEntity(obj, true, true)
			DeleteObject(obj)
			obj = GetClosestObjectOfType(coords.x, coords.y, coords.z, r, hash, false, false, false)
		end
	end
end

CreateThread(function()
	if not Config.CustomPumps or #Config.CustomPumps == 0 then return end

	for _, pump in ipairs(Config.CustomPumps) do
		local model = type(pump.model) == "number" and pump.model or joaat(pump.model)
		RequestModel(model)
		while not HasModelLoaded(model) do Wait(10) end

		local obj = CreateObject(model, pump.coords.x, pump.coords.y, pump.coords.z - 1.0, false, false, false)
		SetEntityHeading(obj, pump.coords.w)
		FreezeEntityPosition(obj, true)
		SetEntityInvincible(obj, true)
		SetModelAsNoLongerNeeded(model)

		table.insert(spawnedCustomPumps, obj)

		if pump.blip and pump.blip.enabled then
			local blip = AddBlipForCoord(pump.coords.x, pump.coords.y, pump.coords.z)
			SetBlipSprite(blip, pump.blip.sprite or 361)
			SetBlipDisplay(blip, 4)
			SetBlipScale(blip, pump.blip.scale or 0.7)
			SetBlipColour(blip, pump.blip.color or 4)
			SetBlipAsShortRange(blip, true)
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(pump.blip.text or "Benzin İstasyonu")
			EndTextCommandSetBlipName(blip)

			table.insert(spawnedCustomBlips, blip)
		end
	end
end)

AddEventHandler('onResourceStop', function(resourceName)
	if resourceName ~= GetCurrentResourceName() then return end

	for _, obj in ipairs(spawnedCustomPumps) do
		if DoesEntityExist(obj) then
			SetEntityAsMissionEntity(obj, true, true)
			DeleteObject(obj)
		end
	end

	for _, blip in ipairs(spawnedCustomBlips) do
		if DoesBlipExist(blip) then
			RemoveBlip(blip)
		end
	end
end)