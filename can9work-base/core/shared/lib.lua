can9work = can9work or {}
can9work.Shared = can9work.Shared or {}

---@description Formats a number into a currency string (e.g., 1000000 -> 1.000.000)
---@param amount number
---@return string
function can9work.Shared.FormatMoney(amount)
    local formatted = tostring(amount)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
        if k == 0 then break end
    end
    return formatted
end

---@description Standardized debug print
---@param ... any
function can9work.Shared.Debug(...)
    if not Settings or not Settings.Debug then return end
    print('^4[can9work-Debug]^7', ...)
end

---@description Deep copies a table
---@param obj table
---@return table
function can9work.Shared.DeepCopy(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[can9work.Shared.DeepCopy(k)] = can9work.Shared.DeepCopy(v) end
    return res
end
