-- tgiann-core admin lib: searches the panel runs on the server while the admin types (the player picker finds
-- online and offline characters by name, citizen id or server id).
local LIMIT = 8

local function core()
    return tgiCore or exports["tgiann-core"]:getCore()
end

---@param text string
---@return { value: string, name: string, online: boolean, id?: number }[]
local function searchPlayers(text)
    local fw = core()
    local out, seen = {}, {}
    -- a server id finds that online player
    local id = tonumber(text)
    local xPlayer = id and fw.getPlayer(id)
    if xPlayer then
        local citizenId = fw.getCid(xPlayer)
        out[1] = { value = citizenId, name = fw.getCharacterName(xPlayer), online = true, id = id }
        seen[citizenId] = true
    end
    if #text < 2 or not fw.SearchCharacters then return out end
    for _, row in ipairs(fw.SearchCharacters(text, LIMIT) or {}) do
        if not seen[row.citizenId] then
            local onlinePlayer = fw.getPlayerById(row.citizenId)
            out[#out + 1] = { value = row.citizenId, name = row.name, online = onlinePlayer ~= nil, id = onlinePlayer and fw.getSource(onlinePlayer) or nil }
        end
    end
    return out
end

lib.callback.register(AdminPanel.EventName("search"), function(src, source, text)
    if not AdminPanel.IsAdmin(src) or type(text) ~= "string" then return {} end
    text = text:match("^%s*(.-)%s*$"):sub(1, 60)
    if source == "players" then return searchPlayers(text) end
    return {}
end)
