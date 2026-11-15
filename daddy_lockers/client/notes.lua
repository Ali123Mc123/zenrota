-- Notes: anyone slips one through the vent of a rented locker; the owner reads them from the envelopes inside the door.
local call = Lockers.call

-- The note page in front of the locker's vent.
function Lockers.leaveNote(spot)
    if Nui.isOpen() then return end
    Lockers.current = { uid = spot.uid, mode = 'note' }
    local rental = Lockers.rentals[spot.uid]
    Nui.open('lockers.note', { uid = spot.uid, code = spot.code, label = spot.label, max = Config.Notes.MaxLength, plate = rental and rental.plate or 'classic', owner = rental and rental.owner, paint = spot.paint })
end

-- The note is folded and pushed in on the page first; the page closes once it is gone.
RegisterNUICallback('lockers:leaveNote', function(data, cb)
    data = type(data) == 'table' and data or {}
    local current = Lockers.current
    local result = call('leaveNote', { uid = current and current.uid, title = data.title, message = data.message, anonymous = data.anonymous == true })
    cb(result)
    if not result.ok then return end
    Nui.notify('lockers.note_left', 'success')
    SetTimeout(900, function() if Lockers.current == current then Nui.close() end end)
end)

RegisterNUICallback('lockers:notes', function(_, cb)
    cb(call('notes', { uid = Lockers.current and Lockers.current.uid }))
end)

RegisterNUICallback('lockers:deleteNote', function(data, cb)
    data = type(data) == 'table' and data or {}
    local result = call('deleteNote', { uid = Lockers.current and Lockers.current.uid, id = data.id })
    if result.ok then Nui.notify('lockers.note_deleted', 'success') end
    cb(result)
end)
