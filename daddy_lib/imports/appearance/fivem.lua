-- fivem-appearance: illenium's exports without a save event, so the product's '<resource>:appearance:save' stores it.
local illenium = DL.require('appearance/illenium')

return function(ctx)
    ctx.save = function(appearance)
        lib.callback.await(DL.resource .. ':appearance:save', false, appearance)
    end
    return illenium(ctx)
end
