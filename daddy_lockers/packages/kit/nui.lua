-- One view of the product at a time (UIs on @daddy/college-kit); the focus goes through daddy_lib so other products
-- close first. Views get the product's texts, language and Config.Theme with every open.
Nui = {}
local current
local closeHooks = {}

function Nui.isOpen(view) return view and current == view or (not view and current ~= nil) end
function Nui.onClose(view, fn) closeHooks[view] = fn end
function Nui.send(action, data) SendNUIMessage({ action = action, data = data }) end

function Nui.close()
    if not current then return end
    local closing = current
    current = nil
    SendNUIMessage({ action = 'close' })
    DL.focus.release()
    if closeHooks[closing] then
        local ok, err = pcall(closeHooks[closing])
        if not ok then print(('^1[%s] close %s: %s^7'):format(GetCurrentResourceName(), closing, err)) end
    end
end

-- cursor = false keeps the mouse hidden (the arrival scene).
function Nui.open(view, payload, cursor)
    if current then Nui.close() end
    current = view
    DL.focus.acquire(Nui.close)
    SetNuiFocus(true, cursor ~= false)
    SendNUIMessage({ action = 'open', view = view, payload = payload, locale = DL.locale.table(), language = DL.locale.language(), theme = Config.Theme })
end

-- Hands focus back to the game for the place editor, keeping the view.
function Nui.suspend()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'suspend' })
end

function Nui.resume()
    if not current then return end
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'resume' })
end

-- Fields on top and in data, as the views read both.
function Nui.result(result)
    if type(result) ~= 'table' then return { ok = false, error = 'integration_unavailable' } end
    if result.ok ~= false and result.data == nil then
        local data = {}
        for key, value in pairs(result) do data[key] = value end
        result.data = data
    end
    return result
end

function Nui.notify(key, kind, ...)
    lib.notify({ description = DL.locale.t(key, ...), type = kind or 'inform' })
end

RegisterNUICallback('close', function(_, cb)
    cb({ ok = true })
    Nui.close()
end)

RegisterNetEvent(GetCurrentResourceName() .. ':notify', function(key, kind, ...) Nui.notify(key, kind, ...) end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() and current then DL.focus.release() end
end)
