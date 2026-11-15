local isStarted = isStarted

-- OpenMenu Function
local function openQBMenu(menu, data)
    exports['qb-menu']:openMenu(menu)
end

local function openOXMenu(menu, data)
    local options = {}
    
    -- Convert QB menu format to OX_LIB format
    for _, item in ipairs(menu) do
        local option = {
            title = item.header,
            description = item.txt,
            icon = item.icon or nil,
            disabled = item.disabled,
        }
        
        if item.image then 
            option.image = item.image
        end
        
        -- Handle the different callback types properly
        if item.params and item.params.event then
            option.onSelect = function()
                if item.params.isServer then
                    TriggerServerEvent(item.params.event, item.params.args)
                else
                    TriggerEvent(item.params.event, item.params.args)
                end
            end
        elseif item.onSelect then
            -- Direct onSelect function - maintain the original callback
            option.onSelect = item.onSelect
        end
        
        table.insert(options, option)
    end
    
    -- Create a unique ID for each menu instance to avoid conflicts
    local menuId = 'job_garage_menu_' .. math.random(1000, 9999)
    
    -- Register and show the context menu
    lib.registerContext({
        id = menuId,
        title = data.header or 'İş Garajı',
        options = options,
        canClose = data.canClose
    })
    
    lib.showContext(menuId)
end

-- Register the global openMenu function
function openMenu(menu, data)
    if Config.System.Menu == "ox" then
        openOXMenu(menu, data)
    else
        openQBMenu(menu, data)
    end
end