--[[
    daddy-queue - client/cl_init.lua
    Client-side: Oturum basladiginda server'a bildir.

    NetworkIsSessionStarted() = true olmasi, oyuncunun GTA'da
    tam olarak aktif oldugu anlama gelir. Bu bildirim:
    1. Server'in connecting listesini temizlemesine yardimci olur
    2. playerJoining eventinin gelmemesi durumunda yedek gorevi gorur
    3. Anti-bypass dogrulama icin kullanilabilir
]]

CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(50)
    end
    TriggerServerEvent('dq:sessionStarted')
end)
