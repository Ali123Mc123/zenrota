WheelchairPermissionsClient = WheelchairPermissionsClient or {}

local cfg = Config.Wheelchair.permissions
local MAIN_CONTEXT = 'dpt_wheelchair_permissions'
local GRANT_CONTEXT = 'dpt_wheelchair_permissions_grant'
local MANAGE_CONTEXT = 'dpt_wheelchair_permissions_manage'

function WheelchairPermissionsClient.CanUse()
    return Utils.CanUseEmsInteract() or LocalPlayer.state[cfg.stateKey] == true
end

function WheelchairPermissionsClient.CanManage()
    return cfg.enabled == true and Utils.CanUseEmsInteract()
end

local function notify(messageKey, nType, ...)
    Utils.Notify('title_wheelchair_permissions', messageKey, nType or 'inform', ...)
end

local function fetchMenuData()
    local response = lib.callback.await('daddy-patienttransport:wheelchair:server:getPermissionMenu', false)
    if type(response) ~= 'table' or response.ok ~= true then
        notify(type(response) == 'table' and response.reason or 'wheelchair_permission_failed', 'error')
        return nil
    end
    return response
end

local showGrantMenu
local showManageMenu

showGrantMenu = function(menuData)
    local data = menuData or fetchMenuData()
    if not data then return end

    local options = {}
    for i = 1, #data.nearby do
        local player = data.nearby[i]
        options[#options + 1] = {
            title = ('%s [ID: %s]'):format(player.name, player.source),
            icon = 'fa-solid fa-user-plus',
            onSelect = function()
                local decision = lib.alertDialog({
                    header = L('wheelchair_permission_grant'),
                    content = L('wheelchair_permission_confirm_grant', player.name),
                    centered = true,
                    cancel = true,
                    labels = {
                        confirm = L('wheelchair_permission_grant'),
                        cancel = L('wheelchair_permission_cancel'),
                    },
                })
                if decision ~= 'confirm' then return end

                local response = lib.callback.await('daddy-patienttransport:wheelchair:server:grantPermission', false, player.source)
                if type(response) ~= 'table' or response.ok ~= true then
                    notify(type(response) == 'table' and response.reason or 'wheelchair_permission_failed', 'error')
                    return
                end
                notify(response.message, 'success', response.name)
                showGrantMenu()
            end,
        }
    end

    if #options == 0 then
        options[1] = {
            title = L('wheelchair_permission_no_nearby'),
            icon = 'fa-solid fa-user-slash',
            disabled = true,
        }
    end

    lib.registerContext({
        id = GRANT_CONTEXT,
        title = L('wheelchair_permission_menu_grant'),
        menu = MAIN_CONTEXT,
        options = options,
    })
    lib.showContext(GRANT_CONTEXT)
end

showManageMenu = function(menuData)
    local data = menuData or fetchMenuData()
    if not data then return end

    local options = {}
    for i = 1, #data.grants do
        local entry = data.grants[i]
        options[#options + 1] = {
            title = entry.name,
            description = L('wheelchair_permission_entry_desc',
                entry.grantedByName,
                entry.grantedAtText,
                L(entry.online and 'wheelchair_permission_online' or 'wheelchair_permission_offline')),
            icon = entry.online and 'fa-solid fa-user-check' or 'fa-solid fa-user-clock',
            onSelect = function()
                local decision = lib.alertDialog({
                    header = L('wheelchair_permission_revoke'),
                    content = L('wheelchair_permission_confirm_revoke', entry.name),
                    centered = true,
                    cancel = true,
                    labels = {
                        confirm = L('wheelchair_permission_revoke'),
                        cancel = L('wheelchair_permission_cancel'),
                    },
                })
                if decision ~= 'confirm' then return end

                local response = lib.callback.await('daddy-patienttransport:wheelchair:server:revokePermission', false, entry.citizenId)
                if type(response) ~= 'table' or response.ok ~= true then
                    notify(type(response) == 'table' and response.reason or 'wheelchair_permission_failed', 'error')
                    return
                end
                notify(response.message, 'success', response.name)
                showManageMenu()
            end,
        }
    end

    if #options == 0 then
        options[1] = {
            title = L('wheelchair_permission_no_grants'),
            icon = 'fa-solid fa-list-check',
            disabled = true,
        }
    end

    lib.registerContext({
        id = MANAGE_CONTEXT,
        title = L('wheelchair_permission_menu_manage'),
        menu = MAIN_CONTEXT,
        options = options,
    })
    lib.showContext(MANAGE_CONTEXT)
end

local function openPermissionMenu()
    if not WheelchairPermissionsClient.CanManage() then
        Utils.JobDeniedNotify('title_wheelchair_permissions')
        return
    end

    local data = fetchMenuData()
    if not data then return end

    lib.registerContext({
        id = MAIN_CONTEXT,
        title = L('title_wheelchair_permissions'),
        options = {
            {
                title = L('wheelchair_permission_menu_grant'),
                description = L('wheelchair_permission_menu_grant_desc', #data.nearby),
                icon = 'fa-solid fa-user-plus',
                arrow = true,
                onSelect = function() showGrantMenu(data) end,
            },
            {
                title = L('wheelchair_permission_menu_manage'),
                description = L('wheelchair_permission_menu_manage_desc', #data.grants),
                icon = 'fa-solid fa-users-gear',
                arrow = true,
                onSelect = function() showManageMenu(data) end,
            },
        },
    })
    lib.showContext(MAIN_CONTEXT)
end

if cfg.enabled then
    RegisterCommand(cfg.command, openPermissionMenu, false)
    TriggerEvent('chat:addSuggestion', ('/%s'):format(cfg.command), L('cmd_wheelchairaccess'))
end
