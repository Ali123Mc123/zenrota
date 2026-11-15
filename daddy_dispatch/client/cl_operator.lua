-- The operator panel: a small staff panel that stays on screen (Config.Commands.Operator), as tgiann-policealert had.
-- The command shows it with the mouse on it; Esc lets the mouse go and the panel stays; the command again gives the mouse
-- back; its close button hides it. While it shows, the units come live.
Operator = { shown = false }

local function show(on)
    Operator.shown = on
    TriggerServerEvent('daddy_dispatch:panel', on)
    Page.send('panel', { on = on })
end

function Operator.toggle()
    if not Me.unit then return end -- silent: players who are not dispatch units never get a message
    if not Operator.shown then show(true) end
    Page.open('operator')
end

Page.on('operator:hide', function()
    Page.close('operator')
    show(false)
end)

-- No longer a unit: the panel goes.
OnMe(function(unit)
    if not unit and Operator.shown then
        Page.close('operator')
        show(false)
    end
end)
