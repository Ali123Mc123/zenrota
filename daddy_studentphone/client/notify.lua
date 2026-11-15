-- Banners from the server: drawn by the page, inside the phone or at the screen corner when it is away; the page
-- plays the iPhone's own alert tone either way. side is the player's corner, for a page that has not opened yet.
local RESOURCE = GetCurrentResourceName()

RegisterNetEvent(RESOURCE .. ':notice', function(n)
    if type(n) ~= 'table' then return end
    SendNUIMessage({ action = 'notify', id = n.id, app = n.app, title = n.title, body = n.body, thread = n.thread, data = n.data, quiet = n.quiet, critical = n.critical, side = n.side, tone = n.tone })
end)
