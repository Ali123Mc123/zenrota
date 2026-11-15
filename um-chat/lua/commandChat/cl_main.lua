ChatLoaded = false
local mouse = false
local config = require('config.chat')
local commandGeneral = config.commandGeneral
local registeredCommandsTable = {}

-- RegisterNetEvent('chatMessage')
RegisterNetEvent('chat:addMessage')
RegisterNetEvent('chat:addSuggestion')
RegisterNetEvent('chat:addSuggestions')
RegisterNetEvent('chat:addMode')
RegisterNetEvent('chat:removeMode')
RegisterNetEvent('chat:removeSuggestion')
RegisterNetEvent('chat:clear')

-- internal events
RegisterNetEvent('__cfx_internal:serverPrint')

RegisterNetEvent('_chat:messageEntered')
RegisterNetEvent('um-chat:client:syncCommandNames')

-- --deprecated, use chat:addMessage
-- AddEventHandler('chatMessage', function(author, color, text, tagData)
--   if not ChatLoaded then return end

--   Debug('chatMessage event', 'info')

--   local args = { text }

--   if author ~= "" then
--     table.insert(args, 1, author)
--   end

--   SendNUIMessage({
--     type = 'ON_MESSAGE',
--     data = {
--       args = args,
--       mode = '_global',
--     }
--   })
-- end)

AddEventHandler('__cfx_internal:serverPrint', function(msg)
  print(msg)

  Debug('serverPrint event', 'info')

  if msg == '' or msg == nil then return end


  SendNUIMessage({
    type = 'ON_MESSAGE',
    data = {
      templateId = 'print',
      multiline = true,
      args = { msg },
      mode = '_global'
    }
  })
end)

-- addMessage
local addMessage = function(message)
  if not ChatLoaded then Wait(1000) end

  Debug('Adding message', 'info')

  if type(message) == 'string' then
    message = {
      args = { message }
    }
  end

  Debug(message)

  SendNUIMessage({
    type = 'ON_MESSAGE',
    data = message
  })
end

exports('addMessage', addMessage)
AddEventHandler('chat:addMessage', addMessage)

-- addSuggestion
local addSuggestion = function(name, help, params)
  if not ChatLoaded then Wait(1000) end

  if name then
    registeredCommandsTable[name:gsub('^' .. commandGeneral.forwardSlash, '')] = true
  end

  SendNUIMessage({
    type = 'ON_SUGGESTION_ADD',
    data = {
      name = name,
      help = help,
      params = params or nil
    }
  })
end

exports('addSuggestion', addSuggestion)
AddEventHandler('chat:addSuggestion', addSuggestion)

AddEventHandler('chat:addSuggestions', function(suggestions)
  if not ChatLoaded then Wait(1000) end

  Debug('Adding suggestions', 'info')

  if type(suggestions) ~= 'table' then
    Debug('Invalid suggestions type: ' .. type(suggestions), 'error')
    Debug(suggestions, 'error')
    return
  end

  -- ox_lib's lib.addCommand broadcasts a single suggestion object (not wrapped in an
  -- array) whenever one new command is registered. Detect that shape and normalize it.
  if suggestions.name then
    suggestions = { suggestions }
  end

  for _, suggestion in ipairs(suggestions) do
    -- Suggestions include server-registered commands (GetRegisteredCommands only sees
    -- client commands), so mirror them into registeredCommandsTable for no-prefix matching.
    if suggestion.name then
      registeredCommandsTable[suggestion.name:gsub('^' .. commandGeneral.forwardSlash, '')] = true
    end

    SendNUIMessage({
      type = 'ON_SUGGESTION_ADD',
      data = suggestion
    })
  end
end)


AddEventHandler('chat:removeSuggestion', function(name)
  SendNUIMessage({
    type = 'ON_SUGGESTION_REMOVE',
    name = name
  })
end)

AddEventHandler('chat:addMode', function(mode)
  SendNUIMessage({
    type = 'ON_MODE_ADD',
    mode = mode
  })
end)

AddEventHandler('chat:removeMode', function(name)
  SendNUIMessage({
    type = 'ON_MODE_REMOVE',
    name = name
  })
end)

AddEventHandler('chat:clear', function()
  SendNUIMessage({
    type = 'ON_CLEAR'
  })
end)

RegisterCommand(config.clearCommand, function()
  SendNUIMessage({
    type = 'ON_CLEAR'
  })
end)

local function dataMessageExecute(msg)
  if msg:sub(1, 1) == commandGeneral.forwardSlash and #msg > 1 then
    ExecuteCommand(msg:sub(2))
    Debug('/Command entered: ' .. msg, 'info')
    return
  end

  local firstWord = msg:match("^(%S+)")
  if commandGeneral.onlyCommand.noPrefix and firstWord and registeredCommandsTable[firstWord] then
    ExecuteCommand(msg)
    Debug('Command entered (no prefix): ' .. msg, 'info')
    return
  end

  if commandGeneral.onlyCommand.status then return end
  if #msg <= 1 then return end
  ExecuteCommand(commandGeneral.onlyCommand.executeChat .. ' ' .. tostring(msg))
  Debug('Message entered: ' .. msg, 'info')
end

local function typingDot(state)
  if not commandGeneral.typingDot.status then return end
  if GetEntityAlpha(cache.ped) < 50 then return end

  local pedCoords = GetEntityCoords(cache.ped)
  local nearbyPlayers = lib.getNearbyPlayers(pedCoords, 3, false)

  if #nearbyPlayers == 0 then return end
  TriggerServerEvent('um-chat:callback:typing', state)
end

AddEventHandler('um-chat:client:syncCommandNames', function(names)
  for _, name in ipairs(names) do
    registeredCommandsTable[name] = true
  end
end)

local function refreshCommands()
  if GetRegisteredCommands then
    local registeredCommands = GetRegisteredCommands()
    registeredCommandsTable = {}

    local suggestions = {}

    for _, command in ipairs(registeredCommands) do
      registeredCommandsTable[command.name] = true
      if IsAceAllowed(('command.%s'):format(command.name)) and command.name ~= 'openChat' then
        table.insert(suggestions, {
          name = '/' .. command.name,
          help = ''
        })
      end
    end

    TriggerEvent('chat:addSuggestions', suggestions)
  end
end


AddEventHandler('onClientResourceStart', function(resName)
  Wait(500)
  refreshCommands()
end)

AddEventHandler('onClientResourceStop', function(resName)
  Wait(500)
  refreshCommands()
end)

RegisterNUICallback('getConfig', function(_, cb)
  local nuiData = require('config.nui')
  cb({ data = nuiData })
  Wait(100)
  TriggerServerEvent('chat:init')
  refreshCommands()
  ChatLoaded = true
  Debug('Loaded', 'info')
end)

RegisterNUICallback('chatResult', function(data, cb)
  cb(1)
  SetNuiFocus(false, false)
  dataMessageExecute(data.message)
  typingDot(false)
  waisTyping(false)
end)

RegisterNUICallback('chatClose', function(_, cb)
  cb(1)
  mouse = false
  SetNuiFocus(false, false)
  Debug('Chat closed', 'info')
  typingDot(false)
  waisTyping(false)
end)

RegisterNUICallback('openMouse', function(_, cb)
  cb(1)
  mouse = not mouse
  SetNuiFocus(true, mouse)
  Debug('Mouse: ' .. tostring(mouse), 'info')
end)

lib.addKeybind({
  name = 'openChat',
  description = 'Sohbeti Aç',
  defaultKey = 't',
  defaultMapper = 'keyboard',
  onPressed = function(self)
    if IsPauseMenuActive() then return end
    --if exports['cylex_animmenu']:inMenu() then return end

    if not ChatLoaded then
      return Debug('Chat waiting for nui', 'warn')
    end

    SendNUIMessage({ type = 'ON_OPEN' })
    SetNuiFocus(true, false)
    Debug('Chat opened', 'info')
    typingDot(true)
    waisTyping(true)
  end
})

CreateThread(function()
  SetTextChatEnabled(false)
  SetNuiFocus(false, false)
end)

-- THE TYPING STUFF MADED BY WAIS
-- THE TYPING STUFF MADED BY WAIS
-- THE TYPING STUFF MADED BY WAIS
-- THE TYPING STUFF MADED BY WAIS

local typingPeds = {}
local typing = {}
AddStateBagChangeHandler("chat", nil, function(bagName, key, value)
  local playerPed = GetPlayerFromStateBagName(bagName)
  typingPeds[playerPed] = value
end)

function waisTyping(state)
  if GetEntityAlpha(cache.ped) < 50 or not IsEntityVisible(cache.ped) then return end
  TriggerServerEvent('wais:server:setState', state)
  LocalPlayer.state.chat = state
end

CreateThread(function()
  while true do
    local sleep = 500
    typing[#typing + 1] = "⚪"
    if #typing > 3 then
      typing = {}
    end

    Wait(sleep)
  end
end)

CreateThread(function()
  while true do
    local sleep = 1000
    local currPed = PlayerPedId()
    local currCoords = GetEntityCoords(currPed)

    if next(typingPeds) ~= nil then
      for ped, playerTyping in pairs(typingPeds) do
        ped = GetPlayerPed(ped)
        if DoesEntityExist(ped) and playerTyping then
          local pedCoords = GetEntityCoords(ped)
          local distance = #(pedCoords - currCoords)
          if distance <= 5.0 then
            sleep = 5
            DrawText3D(pedCoords, table.concat(typing, " "))
          end
        else
          typingPeds[ped] = nil
        end
      end
    end

    Wait(sleep)
  end
end)

function DrawText3D(v, text)
  -- Freecam, photo mode and phone cameras (script camera / tgiann inCameraMode): no typing dots over heads.
  if GetRenderingCam() ~= -1 or IsCinematicCamRendering() or LocalPlayer.state.inCameraMode == true then return end
  local onScreen, _x, _y = World3dToScreen2d(v.x, v.y, v.z + 0.95)
  local px, py, pz = table.unpack(GetGameplayCamCoords())
  SetTextScale(0.055, 0.055)
  SetTextFont(4)
  SetTextProportional(1)
  SetTextColour(255, 255, 255, 255)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextEdge(4, 0, 0, 0, 255)
  SetTextOutline()
  SetTextEntry("STRING")
  SetTextCentre(1)
  AddTextComponentString(text)
  DrawText(_x, _y)
  ClearDrawOrigin()
end

-- THE TYPING STUFF MADED BY WAIS
-- THE TYPING STUFF MADED BY WAIS
-- THE TYPING STUFF MADED BY WAIS
-- THE TYPING STUFF MADED BY WAIS
-- THE TYPING STUFF MADED BY WAIS
