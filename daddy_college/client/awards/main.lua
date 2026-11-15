-- Weekly awards from the board in the world: the paper ballot (nominate, decline, vote) for players without the
-- phone, and the photo of a winner. The server decides every step.
if Config.Modules.awards == false or Config.Modules.academics == false or not Config.Awards then return end

local function call(name, data)
    return Core.NormalizeResult(lib.callback.await('daddy_college:awards:' .. name, false, data or {}))
end

function Core.OpenAwards()
    if Core.Nui.IsOpen() then return end
    local result = call('week')
    if not result.ok then return Core.HandleResult(result, 'awards') end
    Core.Nui.Open('awards.ballot', result.data)
end

for _, name in ipairs({ 'search', 'ballot', 'nominate', 'decline', 'vote' }) do
    Core.Nui.SafeCallback('awards:' .. name, function(data) return call(name, data) end)
end
