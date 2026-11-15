-- ============================================================================
-- CLIENT EDITABLE FUNCTIONS
-- ============================================================================
-- You can edit this file to customize how the script interacts with your server.
-- ============================================================================

Editable = {}

-- Check if player has the required item
-- @param item: string (Config.ItemName)
-- @return boolean
function Editable.HasItem(item)
    -- Default: Check via Framework
    if Framework.HasItem then
        return Framework.HasItem(item)
    end
    
    -- Fallback/Custom implementation example:
    -- return exports.ox_inventory:Search('count', item) > 0
    
    return true -- Default to true if no check is implemented
end

-- Check if player has an allowed job
-- @return boolean
function Editable.IsAllowedJob()
    local job = Editable.GetPlayerJob()
    return job and Config.AllowedJobs[job] ~= nil
end

-- Get player's job name
-- @return string or nil
function Editable.GetPlayerJob()
    local jobData = Framework.GetJob()
    return jobData and jobData.name or nil
end

-- Send notification to player
-- @param msg: string
-- @param type: string ('success', 'error', 'info')
function Editable.Notify(msg, type)
    Framework.Notify(nil, msg, type or 'info')
end
