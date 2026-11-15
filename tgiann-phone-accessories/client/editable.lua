editable = {}

-- Phone scripts this script talks to, checked in this order (tgiann-phone, sd-phone and sky_phone also provide "lb-phone", so they come first)
local PHONE_SCRIPTS = { "tgiann-phone", "sd-phone", "sky_phone", "lb-phone", "npwd", "codem-phone", "high-phone", "17mov_Phone", "yseries", "yphone", "yflip-phone", "qs-smartphone", "gksphone", "cylex_phone" }

---Phone script of the server, nil when none of PHONE_SCRIPTS runs. The client only knows the resources the
---server runs, so a phone that is still starting while this script loads counts too
---@return string?
---@diagnostic disable-next-line: duplicate-set-field
function editable.getPhoneScript()
    for _, resource in ipairs(PHONE_SCRIPTS) do
        if GetResourceState(resource) ~= "missing" then return resource end
    end
    return nil
end

---Return false to stop the editor from opening (handcuffed, in a vehicle, ...)
---@return boolean
function editable.canOpenEditor()
    return not IsPedInAnyVehicle(cache.ped, false) and not IsEntityDead(cache.ped)
end

---Runs when the editor opens: hide your HUD here
function editable.editorOpened()
    if GetResourceState("wais-primehud") == "started" then exports["wais-primehud"]:showHud() end
end

---Runs when the editor closes: show your HUD again here
function editable.editorClosed()
    if GetResourceState("wais-primehud") == "started" then exports["wais-primehud"]:hideHud() end
end

---The phone in the player's hand wears a case of this color (#RRGGBB, nil = no known case).
---tgiann-phone paints its screen frame with it and hides its own Frame Color setting while the case is on
---(second argument false keeps the setting visible); add other phone scripts here
---@param color? string
function editable.onCaseColor(color)
    if editable.getPhoneScript() == "tgiann-phone" then
        exports["tgiann-phone"]:SetFrameColorOverride(color, true)
    end
end

---Tells the script when the local player's phone is out (open, peeking, on a call) and when it is put away.
---tgiann-phone, lb-phone, npwd, sd-phone, sky_phone, codem-phone, high-phone, gksphone and cylex_phone work out of the box. 17mov_Phone,
---yseries (yphone, yflip-phone) and qs-smartphone have no open/close event, so call one of these from your phone's open and close code:
---  exports["tgiann-phone-accessories"]:SetPhoneVisible(true)   /   TriggerEvent("tgiann-phone-accessories:phoneVisible", false)
function editable.registerPhoneEvents()
    local phone = editable.getPhoneScript()
    if phone == "tgiann-phone" then
        AddEventHandler("tgiann-phone:hook:visibility", function(_, onScreen)
            SetAccessoryPhoneVisible(onScreen == true)
        end)
    elseif phone == "lb-phone" then
        AddEventHandler("lb-phone:phoneToggled", function(open)
            SetAccessoryPhoneVisible(open == true)
        end)
    elseif phone == "npwd" then
        AddEventHandler("npwd:disableControlActions", function(open)
            SetAccessoryPhoneVisible(open == true)
        end)
    elseif phone == "sd-phone" then
        AddEventHandler("sd-phone:client:openState", function(open)
            SetAccessoryPhoneVisible(open == true)
        end)
    elseif phone == "codem-phone" then
        -- codem-phone puts { m = model, v = visible } on the player's "codemPhone" statebag while the phone is in hand.
        -- It hides the prop right after creating it, so the value is read once codem-phone is done for that frame
        AddStateBagChangeHandler("codemPhone", ("player:%s"):format(cache.serverId), function()
            SetTimeout(0, function()
                local held = LocalPlayer.state.codemPhone
                SetAccessoryPhoneVisible(type(held) == "table" and held.v == true)
            end)
        end)
    elseif phone == "high-phone" then
        AddStateBagChangeHandler("phone:open", ("player:%s"):format(cache.serverId), function(_, _, open)
            SetAccessoryPhoneVisible(open == true)
        end)
    elseif phone == "gksphone" then
        AddStateBagChangeHandler("phoneOpen", ("player:%s"):format(cache.serverId), function(_, _, open)
            SetAccessoryPhoneVisible(open == true)
        end)
    elseif phone == "cylex_phone" then
        AddStateBagChangeHandler("isPhoneOpen", ("player:%s"):format(cache.serverId), function(_, _, open)
            SetAccessoryPhoneVisible(open == true)
        end)
        if LocalPlayer.state.isPhoneOpen then SetAccessoryPhoneVisible(true) end
    elseif phone == "sky_phone" then
        -- sky_phone holds the phone while it is open and while a call rings or is connected
        local open, call = false, false
        AddEventHandler("sky_phone:animation:phone", function(state)
            open = state == true
            SetAccessoryPhoneVisible(open or call)
        end)
        AddEventHandler("sky_phone:animation:call", function(data)
            call = type(data) == "table" and (data.state == "ringing" or data.state == "connected")
            SetAccessoryPhoneVisible(open or call)
        end)
    end
end

---Puts the phone away before Casely opens the studio. Add other phone scripts here
function editable.closePhone()
    local phone = editable.getPhoneScript()
    if phone == "tgiann-phone" then
        exports["tgiann-phone"]:ClosePhone()
    elseif phone == "lb-phone" then
        exports["lb-phone"]:ToggleOpen(false)
    elseif phone == "npwd" then
        exports["npwd"]:setPhoneVisible(false)
    elseif phone == "sd-phone" then
        exports["sd-phone"]:close()
    elseif phone == "high-phone" then
        exports["high-phone"]:closePhone()
    elseif phone == "17mov_Phone" then
        exports["17mov_Phone"]:ClosePhone()
    elseif phone == "yseries" or phone == "yphone" or phone == "yflip-phone" then
        exports[phone]:ToggleOpen(false)
    elseif phone == "qs-smartphone" then
        exports["qs-smartphone"]:ClosePhone()
    elseif phone == "gksphone" then
        exports["gksphone"]:PhoneClose()
    elseif phone == "sky_phone" then
        exports["sky_phone"]:TogglePhone(false)
    elseif phone == "cylex_phone" then
        TriggerEvent("cylex_phone:client:openPhone", false)
    end
end
