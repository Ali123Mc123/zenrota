function openInventory(id, password, level)
    TriggerServerEvent("tgiann-self-storage-v2:openStash", id, password, level)
end

RegisterNetEvent("tgiann-core:notifData")
AddEventHandler("tgiann-core:notifData", function(text, type, time)
    if not time then time = 5000 end
    sendNui("notify", {
        text = text,
        type = type,
        time = time
    })
end)

RegisterNUICallback("notify", function(data, cb)
    Notify(data.text, data.type, data.time)
    cb("")
end)

-- Picture file of an item in the tgiann-core config.itemImages folder
function getItemImg(item)
    local _, extension = tgiCore.GetItemImageLocation()
    return item.image or (item.name .. extension)
end
