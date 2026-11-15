-- Check ID: only College's students and teachers read a player's school ID, from the target menu or a command (server/card.lua
-- says who may and checks reach). The ID comes up as a game notice.
local RESOURCE = GetCurrentResourceName()
local inspector = false

RegisterNetEvent(RESOURCE .. ':inspector', function(on) inspector = on == true end)

CreateThread(function()
    DL.fw.awaitLogin()
    inspector = lib.callback.await(RESOURCE .. ':inspector', false) == true
end)

local function checkId(target)
    local res = lib.callback.await(RESOURCE .. ':checkId', false, target)
    if not res or not res.ok then return lib.notify({ description = DL.locale.t('errors.' .. (res and res.error or 'server_error')), type = 'error' }) end
    local c = res.data
    lib.notify({
        title = DL.locale.t('target.id_title', c.school),
        description = DL.locale.t('target.id_body', c.name, c.number, c.program ~= '' and c.program or '-', c.valid),
        icon = 'id-card', duration = 10000,
    })
    -- College security also sees the exit permit: good until a time, or none.
    local p = c.permit
    if p then lib.notify({ description = p.valid and DL.locale.t('target.permit_ok', p.clock or '') or DL.locale.t('target.permit_bad'), type = p.valid and 'success' or 'error', icon = 'door-open', duration = 10000 }) end
end

if (Config.Wallet or {}).CheckTarget ~= false then DL.target.addPlayers('studentphone_check_id', {
    distance = 3.0,
    options = {
        { label = DL.locale.t('target.check_id'), icon = 'fa-solid fa-id-card', canInteract = function() return inspector end,
            onSelect = function(ped) CreateThread(function() checkId(GetPlayerServerId(NetworkGetPlayerIndexFromPed(ped))) end) end },
    },
}) end

-- The same as a command: /name [server id], without one the closest player within 3 m.
local command = (Config.Wallet or {}).CheckCommand
if type(command) == 'string' and command ~= '' then
    RegisterCommand(command, function(_, args)
        if not inspector then return lib.notify({ description = DL.locale.t('errors.no_permission'), type = 'error' }) end
        local target = tonumber(args[1])
        if not target then
            local player = lib.getClosestPlayer(GetEntityCoords(PlayerPedId()), 3.0, false)
            target = player and GetPlayerServerId(player)
        end
        if not target then return lib.notify({ description = DL.locale.t('errors.no_player'), type = 'error' }) end
        checkId(target)
    end, false)
    TriggerEvent('chat:addSuggestion', '/' .. command, DL.locale.t('command.check_id'), { { name = 'id', help = DL.locale.t('command.check_id_arg') } })
end

-- Show to Nearby needs line of sight: which of these players the one here can see (server/card.lua asks).
lib.callback.register(RESOURCE .. ':los', function(ids)
    local me, seen = PlayerPedId(), {}
    for _, id in ipairs(type(ids) == 'table' and ids or {}) do
        local player = GetPlayerFromServerId(id)
        local ped = player ~= -1 and GetPlayerPed(player) or 0
        if ped ~= 0 and HasEntityClearLosToEntity(me, ped, 17) then seen[#seen + 1] = id end
    end
    return seen
end)

-- The portrait on the school ID: a head shot of the character (MugShotBase64), or nothing without it.
RegisterNUICallback('phone:mugshot', function(_, cb)
    local image = DL.mugshot.capture(PlayerPedId(), 250000)
    cb(image and { ok = true, image = image } or { ok = false })
end)

