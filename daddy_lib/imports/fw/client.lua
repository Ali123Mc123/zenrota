local id = DL.require('fw/detect')()
local adapter = DL.require('fw/' .. id).client

local fw = { id = id }

fw.isLoggedIn = adapter.isLoggedIn
fw.citizenId = adapter.citizenId
fw.onLoaded = adapter.onLoaded
fw.onUnloaded = adapter.onUnloaded

function fw.awaitLogin()
    while not adapter.isLoggedIn() do Wait(250) end
end

return fw
