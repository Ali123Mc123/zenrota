-- Options of the Student Affairs talk. Modules add their own here, so the list never depends on load order.
-- action: { label = locale key (or text), icon, order (lower first), visible(context) -> boolean, run(), panel = true }
-- A panel action opens a side panel in the talk view and has no run.
Core.Affairs = {}
local actions, sequence = {}, {}

function Core.Affairs.RegisterAction(id, action)
    if not actions[id] then sequence[#sequence + 1] = id end
    actions[id] = action
end

function Core.Affairs.GetAction(id) return actions[id] end

function Core.Affairs.RemoveAction(id)
    if not actions[id] then return end
    actions[id] = nil
    for i, known in ipairs(sequence) do
        if known == id then table.remove(sequence, i) break end
    end
end

-- Other products add options by name: { text, icon, order, event, students, shown } -> TriggerEvent(event) when picked.
-- shown: the name of the product's own client export that says whether the option is offered right now.
-- They leave with the product that added them.
local owners = {}

exports('RegisterAffairsAction', function(id, option)
    local resource = GetInvokingResource()
    if not resource or type(id) ~= 'string' or type(option) ~= 'table' or type(option.event) ~= 'string' then return false end
    local key = resource .. ':' .. id
    owners[key] = resource
    Core.Affairs.RegisterAction(key, {
        text = tostring(option.text or id), icon = option.icon, order = tonumber(option.order),
        visible = function(context)
            if option.students and context.isStudent ~= true then return false end
            return type(option.shown) ~= 'string' or exports[resource][option.shown]() == true
        end,
        run = function() TriggerEvent(option.event) end,
    })
    return true
end)

AddEventHandler('onClientResourceStop', function(resource)
    for key, owner in pairs(owners) do
        if owner == resource then
            owners[key] = nil
            Core.Affairs.RemoveAction(key)
        end
    end
end)

-- The options this visitor sees, in order.
function Core.Affairs.Visible(context)
    local list = {}
    for index, id in ipairs(sequence) do
        local action = actions[id]
        local done, shown = true, true
        if action.visible then done, shown = pcall(action.visible, context) end
        if done and shown then
            list[#list + 1] = { id = id, label = action.text or DL.locale.t(action.label), icon = action.icon, order = action.order or 100, index = index }
        end
    end
    table.sort(list, function(a, b)
        if a.order ~= b.order then return a.order < b.order end
        return a.index < b.index
    end)
    for _, item in ipairs(list) do item.order, item.index = nil, nil end
    return list
end
