if Config.Billing ~= 'bs-bill' then return end

local function refreshBankData()
    while not PhoneClient.jsLoaded do Wait(1000) end
    local unpaidVehiclesResponse = RPC.execute("bs-vehicles:getPlayerVehicleUnpaidBills")
    local unpaidApartmentsResponse = RPC.execute("bs-apartments:getPlayerApartmentUnpaidBills")
    print(json.encode(unpaidVehiclesResponse))
    print(json.encode(unpaidApartmentsResponse))
    local unpaidBillsResponse = {}
    for k, v in pairs(unpaidVehiclesResponse) do
        unpaidBillsResponse[#unpaidBillsResponse + 1] = {
            id = "vehicle_"..v.id,
            name = v.name,
            amount = v.amount,
        }
    end
    for k, v in pairs(unpaidApartmentsResponse) do
        unpaidBillsResponse[#unpaidBillsResponse + 1] = {
            id = "apartment_"..v.id,
            name = v.name,
            amount = v.tax,
        }
    end

    if not unpaidBillsResponse then return end
    local unpaidBills = {}
    for k, v in pairs(unpaidBillsResponse) do
        unpaidBills[#unpaidBills + 1] = {
            id = v.id,
            user = v.name,
            amount = v.amount,
        }
    end

    SendNUIMessage({
        action = "setAppData",
        key = "bank",
        key2 = "billing",
        type = "set",
        value = unpaidBills
    })
end

RegisterNUICallback('bank:getBills', function()
    refreshBankData()
end)

RegisterNUICallback('bank:payBill', function(data, cb)
    local underscorePos = string.find(data.data.id, "_")
    
    if underscorePos then
        local billType = string.sub(data.data.id, 1, underscorePos - 1)
        local billId = string.sub(data.data.id, underscorePos + 1)
        
        print("Bill type: " .. billType) 
        print("Bill ID: " .. billId)
        
        if billType == "vehicle" then
            if RPC.execute("bs-vehicles:payVehicleTax", billId) then
                Wait(250)
                refreshBankData()
            end
        elseif billType == "apartment" then
            if RPC.execute("bs-apartments:payApartmentTax", billId) then
                Wait(250)
                refreshBankData()
            end
        end
    else
        print("Invalid bill ID format")
    end
    
    if cb then cb({}) end
end)

RegisterNetEvent('cylex_phone:onSetPlayerData', function(data)
    refreshBankData()
end)

RegisterNetEvent('cylex_phone:client:refreshBank', function()
    refreshBankData()
end)