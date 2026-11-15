local config = lib.load('configs.client')
local rosterZone

-- Unjail Player --
local function unjailConfirmation(info)
    local confirmation = lib.alertDialog({
        header = ('Serbest Bırak: %s?'):format(info.name),
        content = ('**%s** kişisini serbest bırakmak istediğinizden emin misiniz?  \nHâlâ **%s Ay** cezası kaldı.'):format(info.name, info.jailTime),
        centered = true,
        cancel = true,
    }) if confirmation == 'cancel' then return end

    local unjailed = lib.callback.await('xt-prison:server:unjailPlayerByRoster', false, info.source)
    if unjailed then
        lib.notify({
            title = ('%s serbest bırakıldı!'):format(info.name),
            type = 'success'
        })
    end
end

-- Change Player's Jail Time --
local function changeJailTime(info)
    local newTime = lib.inputDialog(('Ceza Süresini Değiştir: %s'):format(info.name), {
        { type = 'number', label = 'Yeni Ceza Süresi', description = ('Kalan Süre: %s Ay'):format(info.jailTime), icon = 'hashtag' },
    }) if not newTime then return end

    local setTime = lib.callback.await('xt-prison:server:changePlayerJailTimeByRoster', false, info.source, newTime[1])
    if setTime then
        lib.notify({
            title = ('%s\'nin Cezası Değiştirildi!'):format(info.name),
            description = ('Yeni Süre: %s'):format(newTime[1]),
            type = 'success'
        })
    end
end

local function rosterActionMenu(info)
    local actions = {
        {
            title = 'Ceza Süresini Değiştir',
            icon = 'fas fa-hourglass',
            onSelect = function()
                changeJailTime(info)
            end
        },
        {
            title = 'Serbest Bırak',
            icon = 'fas fa-lock-open',
            onSelect = function()
                unjailConfirmation(info)
            end
        }
    }

    lib.registerContext({
        id = 'prisoners_roster_actions',
        title = info.name,
        menu = 'prisoners_roster',
        options = actions
    })
    lib.showContext('prisoners_roster_actions')
end

local function openPublicRoster()
    local jailRoster = lib.callback.await('xt-prison:server:getJailRoster', false)
    if not jailRoster then return end

    if not jailRoster[1] then
        jailRoster = {
            {
                title = 'Tutuklu Yok!',
                readOnly = true
            }
        }
    else
        for x = 1, #jailRoster do
            jailRoster[x].readOnly = true
        end
    end

    lib.registerContext({
        id = 'prisoners_public_roster',
        title = 'Tutuklu Listesi',
        options = jailRoster
    })
    lib.showContext('prisoners_public_roster')
end

local function createRosterZone()
    -- local zoneInfo = config.RosterLocation
    -- rosterZone = exports.ox_target:addSphereZone({
    --     coords = zoneInfo.coords,
    --     radius = zoneInfo.radius,
    --     debug = zoneInfo.DebugPoly,
    --     drawSprite = true,
    --     options = {
    --         {
    --             label = 'View Prisoners Roster',
    --             icon = 'fas fa-clipboard-list',
    --             onSelect = openPublicRoster
    --         }
    --     }
    -- })
end

local function removeRosterZone()
    if not rosterZone then return end
    exports.ox_target:removeZone(rosterZone)
    rosterZone = nil
end

-- Open Prisoners Manageable Roster as Cop --
RegisterNetEvent('xt-prison:client:openPrivateJailRoster', function(jailRoster)
    if GetInvokingResource() then return end

    if not jailRoster[1] then
        jailRoster = {
            {
                title = 'Tutuklu Yok!',
                readOnly = true
            }
        }
    else
        for x = 1, #jailRoster do
            jailRoster[x].onSelect = function()
                rosterActionMenu(jailRoster[x].private)
            end
        end
    end

    lib.registerContext({
        id = 'prisoners_roster',
        title = 'Tutuklu Listesi',
        options = jailRoster
    })
    lib.showContext('prisoners_roster')
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    createRosterZone()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    removeRosterZone()
end)

AddEventHandler('xt-prison:client:onLoad', function()
    createRosterZone()
end)

AddEventHandler('xt-prison:client:onUnload', function()
    removeRosterZone()
end)