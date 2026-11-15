-- Floor plans: boards that open the building's plans, from any floor.
local t = DL.locale.t
local RESOURCE = GetCurrentResourceName()

local function open(floor)
    local floors = {}
    for _, entry in ipairs(Config.FloorPlans.Floors) do
        local image = entry.image:find('://', 1, true) and entry.image or ('nui://%s/%s'):format(RESOURCE, entry.image)
        floors[#floors + 1] = { id = entry.id, label = entry.label, image = image }
    end
    if #floors == 0 then return Nui.notify('floors.none', 'inform') end
    Nui.open('campus.floors', { floors = floors, current = floor })
end

Campus.kind('floor_plan', function(record)
    return { options = { {
        name = 'campus_floors', label = t('floors.target'), icon = 'fa-solid fa-map-location-dot', canInteract = Campus.free,
        onSelect = function() open(record.settings.floor) end,
    } } }
end)

exports('OpenFloorPlans', open)
