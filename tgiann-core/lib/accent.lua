-- Accent color of tgiann UIs in one place. Add it to a resource's client_scripts:
--     "@tgiann-core/lib/accent.lua",
-- The color is the hud's (tgiann-lumihud, or any hud that sends tgiann-lumihud:setLumiHudColor) once one was sent,
-- else tgiann-core config.defaultColor. tgiann-core keeps the last one, so a resource that starts later still gets it.
--
--     TgiAccent.Get()            -> { background = "#36ff9f", color = "#000000" }
--     TgiAccent.OnChange(fn)     -> runs fn(color) now and on every change, e.g.
--         TgiAccent.OnChange(function(color) sendNui("setLumiHudColor", color) end)
-- Send TgiAccent.Get() with the NUI's first data too: a message sent before the NUI loaded is lost.

---@class TgiAccentColor
---@field background string accent color
---@field color string text color on the accent

TgiAccent = {}

---@type fun(color: TgiAccentColor)[]
local listeners = {}

---@return TgiAccentColor
function TgiAccent.Get()
    return exports["tgiann-core"]:GetAccentColor()
end

---@param fn fun(color: TgiAccentColor)
function TgiAccent.OnChange(fn)
    listeners[#listeners + 1] = fn
    fn(TgiAccent.Get())
end

AddEventHandler("tgiann-core:client:accentColor", function(color)
    for i = 1, #listeners do listeners[i](color) end
end)
