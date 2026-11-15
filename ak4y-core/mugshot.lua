Wait(4000)

exports["ak4y-core"]:Register('ak4y-core:GetMyMugshot', function()
    local ped = PlayerPedId()
    local handle = RegisterPedheadshot(ped)
    local timeout = GetGameTimer() + 3000

    while (not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle)) and GetGameTimer() < timeout do
        Wait(0)
    end

    if IsPedheadshotValid(handle) then
        local txd = GetPedheadshotTxdString(handle)
        UnregisterPedheadshot(handle)

        return "https://nui-img/" .. txd .. "/" .. txd
    else
        UnregisterPedheadshot(handle)
        return nil
    end
end)