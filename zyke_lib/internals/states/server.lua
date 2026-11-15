-- Sets the OsTime
CreateThread(function()
    while (true) do
        GlobalState:set("OsTime", os.time(), true)
        Wait(1000)
    end
end)

-- Keeping track of routing buckets
-- The last bucket written is kept here, so the state bag is only touched when it changes (reading
-- Player(id).state for every player twice a second cost ~1.7 ms each round).
local lastBucket = {}

AddEventHandler("playerDropped", function()
    lastBucket[tonumber(source)] = nil
end)

CreateThread(function()
    while (true) do
        local players = GetPlayers()
        for i = 1, #players do
            local src = tonumber(players[i])
            local bucketId = GetPlayerRoutingBucket(players[i])

            if (lastBucket[src] ~= bucketId) then
                lastBucket[src] = bucketId
                Player(players[i]).state:set("routingBucket", bucketId, true)
            end
        end

        Wait(500)
    end
end)