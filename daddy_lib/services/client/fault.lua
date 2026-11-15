-- A fault notice on servers without ox_lib: the game's own feed.
RegisterNetEvent('daddy_lib:notice', function(text)
    if type(text) ~= 'string' then return end
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(text:sub(1, 99))
    EndTextCommandThefeedPostTicker(false, true)
end)
