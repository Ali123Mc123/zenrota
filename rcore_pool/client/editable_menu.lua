
if not Config.CustomMenu then
    Citizen.CreateThread(function()
        WarMenu.CreateMenu(
            'pool', 
            Config.Text.POOL,
            Config.Text.POOL_SUBMENU or 'Top dizilişini seçin'
        )

        WarMenu.SetTitleBackgroundSprite('pool', "rcore_pool", "pool")
        
        WarMenu.SetSubTitle('pool', Config.Text.POOL_SUBMENU or 'Top dizilişini seçin')

        if false and Config.MenuColor then
            WarMenu.SetMenuTextColor('pool', Config.MenuColor[1], Config.MenuColor[2], Config.MenuColor[3], 255)
            WarMenu.SetTitleBackgroundColor('pool', Config.MenuColor[1], Config.MenuColor[2], Config.MenuColor[3], 255)
        else
            WarMenu.SetMenuTextColor('pool', 147, 184, 168, 255)
            WarMenu.SetTitleBackgroundColor('pool', 147, 184, 168, 255)
        end

        while true do
            if IsCloseToAnyTable then
                Wait(0)
            else
                Wait(2000)
            end

            if WarMenu.IsMenuOpened('pool') then
                if ClosestTableAddress then
                    if WarMenu.Button(Config.Text.TYPE_9_BALL) then
                        TriggerEvent('rcore_pool:setupTable', 'BALL_SETUP_9_BALL')
                        WarMenu.CloseMenu()
                    elseif WarMenu.Button(Config.Text.TYPE_STRAIGHT) then
                        TriggerEvent('rcore_pool:setupTable', 'BALL_SETUP_STRAIGHT_POOL')
                        WarMenu.CloseMenu()
                    elseif WarMenu.Button('Masayı Sıfırla / Temizle') then
                        TriggerEvent('rcore_pool:setupTable', 'RESET_TABLE')
                        WarMenu.CloseMenu()
                    end

                    WarMenu.Display()
                else
                    WarMenu.CloseMenu()
                end
            else
                Wait(200)
            end
        end
    end)
end

AddEventHandler('rcore_pool:openMenu', function()
    WarMenu.OpenMenu('pool')
end)

AddEventHandler('rcore_pool:closeMenu', function()
    -- triggered
end)

AddEventHandler('rcore_pool:setupTable', function(ballNumbers)
    local map = {
        ['BALL_SETUP_9_BALL'] = BALL_SETUP_9_BALL,
        ['BALL_SETUP_STRAIGHT_POOL'] = BALL_SETUP_STRAIGHT_POOL,
    }

    if ClosestTableAddress and TableData[ClosestTableAddress] then
        local tableEntity = TableData[ClosestTableAddress].entity
        local tableEntPos = GetEntityCoords(tableEntity)

        if ballNumbers == 'RESET_TABLE' or ballNumbers == 'CLEAR_TABLE' then
            local serverIds = GetServerIdsNearTable(ClosestTableAddress)
            
            -- Bildirimi yalnızca masanın dibindeki (5.0m) oyunculara gönder
            local notifyIds = {}
            for _, pid in pairs(GetActivePlayers()) do
                local ped = GetPlayerPed(pid)
                if ped and DoesEntityExist(ped) then
                    if #(GetEntityCoords(ped) - tableEntPos) <= 5.0 then
                        table.insert(notifyIds, GetPlayerServerId(pid))
                    end
                end
            end

            TriggerServerEvent('rcore_pool:notifyResetTable', notifyIds)
            TriggerServerEvent('rcore_pool:setTableState', {
                serverIds = serverIds,
                tablePosition = {x = tableEntPos.x, y = tableEntPos.y, z = tableEntPos.z},
                data = {},
            })
            return
        end

        if ballNumbers == 'BALL_SETUP_9_BALL' or ballNumbers == 'BALL_SETUP_STRAIGHT_POOL' then
            local data = setupBalls(tableEntity, map[ballNumbers])

            TriggerServerEvent('rcore_pool:setTableState', {
                serverIds = GetServerIdsNearTable(ClosestTableAddress),
                tablePosition = {x = tableEntPos.x, y = tableEntPos.y, z = tableEntPos.z},
                data = data,
            })
        else
            print("ERROR: Unknown ball configuration name. Supported names: BALL_SETUP_9_BALL, BALL_SETUP_STRAIGHT_POOL, RESET_TABLE")
        end
    end
end)