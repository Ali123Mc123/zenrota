-- NUI focus through daddy_lib, so only one resource owns it at a time.
local focus = {}
local onRevoke

AddEventHandler('daddy_lib:focus:revoke', function(resource)
    if resource == DL.resource and onRevoke then onRevoke() end
end)

-- closeUi runs when another resource takes focus.
function focus.acquire(closeUi)
    onRevoke = closeUi
    exports.daddy_lib:acquireFocus()
    SetNuiFocus(true, true)
end

function focus.release()
    SetNuiFocus(false, false)
    exports.daddy_lib:releaseFocus()
end

function focus.owner()
    return exports.daddy_lib:focusOwner()
end

return focus
