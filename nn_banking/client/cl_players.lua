-- Nearby-player picker + ped-headshot avatars.
--
-- The phone's Send / Invoice screens ask for players standing close by; we resolve them client-side
-- (peds in scope within Config.NearbyMaxDistance) and return their SERVER ids. The server
-- re-validates the distance, so a spoofed id/distance is harmless.
--
-- Avatars use MugShotBase64 (-> a data: URL usable directly in NUI). GTA ped headshots are game
-- textures that CEF can't load, so this resource converts them to base64 for us. Everything falls
-- back to the initials avatar when disabled or the resource isn't running.

local function avatarEnabled()
  return Config.Avatar and Config.Avatar.UsePedShot and GetResourceState('MugShotBase64') == 'started'
end

-- Ped headshot as a NUI data: URL (or nil). Blocks briefly (MugShotBase64 awaits the headshot),
-- so only call from a thread / NUI callback coroutine.
local function pedMugshot(ped)
  if not avatarEnabled() or not ped or ped == 0 or not DoesEntityExist(ped) then return nil end
  local ok, b64 = pcall(function()
    return exports['MugShotBase64']:GetMugShotBase64(ped, Config.Avatar.Transparent ~= false)
  end)
  if ok and type(b64) == 'string' and b64:sub(1, 10) == 'data:image' then return b64 end
  return nil
end

-- The local player's avatar (their ped headshot), captured once and cached for the session.
local myAvatarCache = nil
RegisterNUICallback('myAvatar', function(_, cb)
  if not avatarEnabled() then cb({ avatar = nil }); return end
  CreateThread(function()
    if not myAvatarCache then myAvatarCache = pedMugshot(PlayerPedId()) end
    cb({ avatar = myAvatarCache })
  end)
end)

RegisterNUICallback('nearbyPlayers', function(_, cb)
  CreateThread(function()
    local maxDist = (Config and Config.NearbyMaxDistance) or 12.0
    local me = PlayerId()
    local myCoords = GetEntityCoords(PlayerPedId())
    local out = {}

    for _, pl in ipairs(GetActivePlayers()) do
      if pl ~= me then
        local ped = GetPlayerPed(pl)
        if ped and ped ~= 0 and DoesEntityExist(ped) then
          local d = #(myCoords - GetEntityCoords(ped))
          if d <= maxDist then
            local sid = GetPlayerServerId(pl)
            out[#out + 1] = {
              serverId = sid,
              name = GetPlayerName(pl) or ('Oyuncu ' .. sid),
              dist = math.floor(d * 10) / 10,
              ped = ped,
            }
          end
        end
      end
    end

    table.sort(out, function(a, b) return a.dist < b.dist end)

    -- Attach ped-headshot avatars (cap the count so the call stays snappy), then drop the handle.
    for i, p in ipairs(out) do
      if i <= 8 then p.avatar = pedMugshot(p.ped) end
      p.ped = nil
    end

    cb(out)
  end)
end)
