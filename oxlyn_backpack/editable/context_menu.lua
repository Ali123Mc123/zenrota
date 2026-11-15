-- OPEN SOURCE: Backpack Context Menu
-- Shown when the player opens a PIN-enabled backpack.
-- Exposes _G.OxlynBackpackMenu(backpackID, hasPIN, onOpen, onChangePin)
--
-- Swap the implementation below to use a different context menu resource.
-- Supported out of the box: ox_lib (default)
-- To use qb-menu / ESX menu / etc, replace the body of OxlynBackpackMenu.
--
-- Parameters passed to OxlynBackpackMenu:
--   backpackID  (string)   — unique backpack identifier
--   hasPIN      (boolean)  — whether a PIN is already set
--   onOpen      (function) — call this to proceed with opening (runs PIN unlock flow)
--   onChangePin (function) — call this to proceed with change-PIN flow (only when hasPIN)

_G.OxlynBackpackMenu = function(backpackID, hasPIN, onOpen, onChangePin)
    local options = {
        {
            title    = Config.Labels.MenuOpen,
            icon     = 'box-open',
            onSelect = onOpen,
        },
    }

    if hasPIN and onChangePin then
        table.insert(options, {
            title       = Config.Labels.MenuChangePin,
            description = Config.Labels.MenuChangePinDesc,
            icon        = 'lock',
            onSelect    = onChangePin,
        })
    end
    
    if hasPIN then
        table.insert(options, {
            title       = Config.Labels.MenuRemovePadlock,
            description = Config.Labels.MenuRemovePadlockDesc,
            icon        = 'unlock',
            onSelect    = function() TriggerServerEvent('oxlyn_backpack:server:removePadlock', backpackID) end,
        })
    end

    lib.registerContext({
        id      = 'oxlyn_backpack_menu_' .. backpackID,
        title   = Config.Labels.MenuTitle,
        options = options,
    })
    lib.showContext('oxlyn_backpack_menu_' .. backpackID)
end
