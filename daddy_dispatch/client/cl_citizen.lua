-- Citizen calls: /911 (each Config.Numbers entry) opens a small card, or sends at once with a message after it. Units
-- answer the newest citizen call (Y); the caller sees the answer on a plate.
for _, n in ipairs(Config.Numbers) do
    Command(n.number, function(_, args)
        if #args > 0 then
            local p = GetEntityCoords(PlayerPedId())
            local street, area = Context.street(p)
            TriggerServerEvent('daddy_dispatch:citizen', n.number, table.concat(args, ' '), false, street or area)
            return
        end
        Page.open('compose', { number = n.number, to = Core.t('numbers.' .. n.number) })
    end, false)
    TriggerEvent('chat:addSuggestion', '/' .. n.number, Core.t('cmd.number', n.number), { { name = 'message', help = Core.t('cmd.message') } })
end

Page.on('citizen', function(data)
    local p = GetEntityCoords(PlayerPedId())
    local street, area = Context.street(p)
    TriggerServerEvent('daddy_dispatch:citizen', tostring(data.number), tostring(data.text or ''), data.anonymous == true, street or area)
    Page.close('compose')
end)

-- Answering the newest citizen call.
local function reply(id)
    local call = Calls.list[id or Calls.current or -1]
    if not call or not call.citizen then
        call = nil
        for _, c in pairs(Calls.list) do
            if c.citizen and (not call or c.id > call.id) then call = c end
        end
    end
    if not call then return end
    Page.open('compose', { reply = { id = call.id, code = call.code, title = call.title } })
end

Keys.map('reply', function()
    if Me.unit then reply() end
end)

Page.on('reply', function(data)
    if data.text then
        TriggerServerEvent('daddy_dispatch:reply', tonumber(data.id), tostring(data.text))
        Page.close('compose')
    else
        reply(tonumber(data.id))
    end
end)

-- An answer to my call.
RegisterNetEvent('daddy_dispatch:reply', function(data)
    if type(data) ~= 'table' then return end
    Page.send('answer', { code = data.code, from = data.from, text = data.text })
    if not Prefs.mute then Page.send('play', { sound = 'chirp', volume = Prefs.volume / 100, single = true }) end
end)
