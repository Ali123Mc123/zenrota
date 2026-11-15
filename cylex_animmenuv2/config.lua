-- Play Emote Export: exports['cylex_animmenuv2']:playEmote('emotename')
-- Cancel Emote Export: exports['cylex_animmenuv2']:playEmote('c')
-- Open Menu Event (For radial menu etc): TriggerEvent('emotes:openMenu')
-- Get Current Emote Export: exports['cylex_animmenuv2']:getCurrentEmote()

local canCancelAnimation = true
Config = {
    Debug = false, -- If you want to see the debug prints, set this to true

    -- If you want to change the key, go to https://docs.fivem.net/docs/game-references/controls/
    OpenKey = 'F4',       -- Key to open the menu
    Language = 'tr',      -- en, tr, ko
    MultipleAnim = true,  -- If you want to play multiple animations at the same time without cancelling, set this to true
    AnimOnVehicle = true, -- If you want to disable emotes on vehicles, set this to false

    WalkInMenu = true,    -- If you want to enable walk in the menu, set this to true

    -- If you want to use custom emotes (AnimationList.json), set this to true ( YOU NEED TO BUY BUNDLE FOR THIS, IF YOU DON'T HAVE BUNDLE, SET THIS TO FALSE)
    CustomEmotes = true,
    AfterCooldown = 250, -- (Milliseconds) Sets how long after the next animation is available (You can disable with setting 0)

    SpawnEvents = {      -- this is for persistent walk and expressions
        'QBCore:Client:OnPlayerLoaded',
        'BSCore:Client:OnPlayerLoaded',
        'esx:playerLoaded',
        'hospital:client:Revive',
        'playerSpawned'
    },

    -- This values only applying on first time login.
    DefaultMenuValues = {
        menuType = 'minimal',  -- default, medium, minimal
        streamer_mode = false, -- Hides special from the menu and category for streamer.
        show_gif = true,       -- Shows gifs of animations (for players who encountering performance issues)
        white_gif = false,     -- If true, gifs will be white (silhouette style)
        themeHue = 0,          -- Theme color of the menu (0-255) 0 = RED
    },

    PersistentExpressions = true, -- If you want to keep the expressions active when u relog, set this to true
    PersistentWalkStyle = true,   -- If you want to keep the walk styles active when u relog, set this to true

    NoCollisionProps = true,      -- If you want to disable collision for props, set this to true

    -- You can find the list of keys on this website https://docs.fivem.net/docs/game-references/controls/
    -- (Shared Animation Binds)
    AcceptBind = 246,  -- Key to accept the emote (Currently: Y)
    AcceptLabel = 'Y', -- Label shown on the UI button
    RefuseBind = 74,   -- Key to refuse the emote (Currently: H)
    RefuseLabel = 'H', -- Label shown on the UI button

    -- (PTFX / Particle Effect Bind)
    PtfxBind = 47,   -- Key to activate particle effect (Currently: G)
    PtfxLabel = 'G', -- Label shown on the notification

    -- (Group Emote Binds)
    GroupAcceptBind = 246,   -- Key to accept group invite (Currently: Y)
    GroupAcceptLabel = 'Y',  -- Label shown on the UI button
    GroupDeclineBind = 74,   -- Key to decline group invite (Currently: H)
    GroupDeclineLabel = 'H', -- Label shown on the UI button

    Ragdoll = {
        enabled = true,
        keybind = 'U',          -- Get the button string from here https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard
        ragdollAsToggle = true, -- If you want to use ragdoll as toggle, set this to true
    },

    DisableKeys = { -- If you want to disable some keys while open menu, you can add them here
        1, 2, 3, 4, 5, 6, 7, 8, 9, 24, 25, 177, 199, 200, 202, 322
    },

    -- If you have another crouch, crawl, handsup or pointing, disable it
    -- Or just disable all my features and keep using own.
    Crouch = {
        enabled = false,
        keybindEnabled = false, -- If true, crouching will use keybinds otherwise you need to use comand.
        keybind = 'LCONTROL',   -- The default crouch keybind, get the button string here: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
        crouchOverride = false, -- If true, you won't enter stealth mode even if the crouch key and the "duck" key are the same.
        cooldown = 1000,        -- Cooldown for crouching in milliseconds
    },

    Crawl = {
        enabled = false,       -- If true, crawling will be enabled, otherwise you need to use comand.
        keybindEnabled = true, -- If true, crawling will use keybinds.
        keybind = 'RCONTROL',  -- The default crawl keybind, get the button string here: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
    },

    Handsup = {
        enabled = true,
        command = 'handsup',                                                        -- The default handsup command
        keybind = 'X',                                                              -- The default handsup keybind, get the button string here: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
        controls = { 24, 25, 47, 58, 59, 63, 64, 75, 140, 141, 142, 257, 263, 264 } -- 71, 72, 143
    },

    Pointing = {
        enabled = true,
        command = 'point', -- The default point command
        keybind = 'B',     -- The default point keybind, get the button string here: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
    },

    -- NEW
    -- Fortnite style emote wheel (circular emote menu)
    -- Opens when the key is held down, selected with the mouse, and the emote plays when the key is released
    EmoteWheel = {
        enabled = true,
        -- CAPITAL (CAPSLOCK) Get the button string here: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
        keybind = 'CAPITAL',

        -- true: Use emotes from the favorites list
        -- false: Use the 'emotes' list below
        useFromFavorites = true,

        -- If useFromFavorites is false, this list will be used
        emotes = {
            'wave', 'salute', 'sit', 'think', 'clap', 'bow', 'cheer', 'dance'
        }
    },

    -- NEW
    -- Group Emote (for groups)
    GroupEmote = {
        enabled = true
    },

    AnimPos = {
        EnableAnimPos = true, -- If you want to disable animation position completly, set this to false

        -- When you set this to true, if the character is on emote, it switches to an animpos that scrolls the character not with the clone pad.
        -- If false, or if the character is not currently on emote, it switches to an animpos with clone pad.
        EnableNormalAnimPos = true,

        -- if you want to disable alpha, set it false.
        -- If you want to enable alpha, set the alpha value
        -- 255 is max alpha, 0 is min alpha, 75 is default alpha
        EnableNormalAnimPosAlpha = 75, -- Alpha value when you are on normal animpos


        MaxDistance = 25.0,           -- How far they can move away from the starting distance of the anim pos.
        MaxZDistance = 2.0,           -- How far they can move up and down Z axis of anim pos.

        FreeModeMaxDistance = 8.0,    -- How far they can move away from the starting distance of the anim pos in free mode.
        TeleportBackOnCancel = false, -- If you want to teleport back to the starting position when the emote is canceled ON ANIMATION POSITION, set this to true

        up = 241,                     -- UP (Currently: Scroll wheel up)
        down = 242,                   -- DOWN (Currently: Scroll wheel down)

        left = 174,                   -- LEFT (Currently: ARROW LEFT)
        right = 175,                  -- RIGHT (Currently: ARROW RIGHT)

        forward = 172,                -- FORWARD (Currently: ARROW UP)
        backward = 173,               -- BACKWARD (Currently: ARROW DOWN)

        rotateLeft = 52,              -- Rotate Left (Currently: Q)
        rotateRight = 51,             -- Rotate tRight (Currently: E)

        followMouse = 47,             -- Freeze Mouse Follow (Currently: G)
        done = 191,                   -- Done (Currently: ENTER)
        cancel = 73,                  -- Done (Currently: ENTER)

        KeyInfos = {
            { label = 'Sağ',                    key = 175 },
            { label = 'Sol',                    key = 174 },
            { label = 'Geri',                   key = 173 },
            { label = 'İleri',                  key = 172 },
            { label = 'Sağa Döndür',            key = 51 },
            { label = 'Sola Döndür',            key = 52 },
            { label = 'Yukarı / Aşağı',         key = 348 },
            { label = 'Fare Takibini Aç/Kapat', key = 47 },
            { label = 'İptal',                  key = 73 },
            { label = 'Tamam',                  key = 191 },
        }
    },


    Categories = {
        {
            id = 'all',
            label = 'Tümü',
            icon = 'fas fa-house',
        },
        {
            id = 'favorites',
            label = 'Favoriler',
            icon = 'fas fa-star',
        },
        {
            id = 'sequences',
            label = 'Sıralamalar',
            icon = 'fas fa-stopwatch',
        },
        {
            id = 'emotes',
            label = 'Genel',
            icon = 'fas fa-male',
        },
        {
            id = 'dances',
            label = 'Danslar',
            icon = 'fas fa-running',
        },
        {
            id = 'expressions',
            label = 'İfadeler',
            icon = 'fas fa-laugh-beam',
        },
        {
            id = 'walks',
            label = 'Yürüyüşler',
            icon = 'fas fa-running',
        },
        {
            id = 'custom',
            label = 'Özel Emote',
            icon = 'fas fa-male',
        },
        {
            id = 'shared',
            label = 'Ortak Emote',
            icon = 'fa-solid fa-user-group',
        },
        {
            id = 'propemotes',
            label = 'Prop Emote',
            icon = 'fa-solid fa-hands',
        },
        {
            id = 'couple',
            label = 'Çift Animasyon',
            icon = 'fas fa-venus-mars',
        },
        {
            id = 'animals',
            label = 'Hayvan Emote',
            icon = 'fa-solid fa-dog',
        },
    }
}

Notify = function(msg, type)
    lib.notify({
        description = msg,
        type = type or 'inform',
        duration = 3000
    })

    -- print('notify', msg)
end

Lang = function(msg)
    local lang = Config.Language or 'en'
    if Locales[lang] and Locales[lang][msg] then
        return Locales[lang][msg]
    elseif Locales['en'] and Locales['en'][msg] then
        return Locales['en'][msg]
    end
    return 'Translation not found'
end

CreateThread(function()
    RegisterNetEvent('emotes:openMenu', function()
        openMenu()
    end)

    RegisterNetEvent('emotes:closeMenu', function()
        if not menuState then return end
        openMenu(false)
    end)

    RegisterCommand('emotemenu', function()
        openMenu()
    end)

    RegisterKeyMapping('emotemenu', 'Animasyon Menüsünü Aç', 'keyboard', Config.OpenKey)

    RegisterCommand('emotecancel', function()
        if not canCancelAnimation then return end
        onEmoteCancel()
    end)

    RegisterKeyMapping('emotecancel', 'Animasyonu İptal Et', 'keyboard', 'X')

    -- Animation commands
    local function setWalk(walkStyle)
        for _, animation in pairs(Config.AllAnimations) do
            if (animation.id == walkStyle or animation.value == walkStyle) and animation.category == 'walks' then
                return onWalk(animation)
            end
        end
    end

    RegisterNetEvent('cylex_animmenuv2:client:setWalk', setWalk)
    RegisterCommand('walk', function(_, args)
        local emote = args[1]
        if not emote then return end
        local emote = emote:lower()

        if emote == 'c' or emote == 'cancel' then
            return onWalkCancel()
        end

        setWalk(emote)
    end)

    TriggerEvent('chat:addSuggestion', '/walk', 'Yürüyüş stili oynat.', {
        { name = "walk", help = "Yürüyüş adı" }
    })

    local function setExpression(expression)
        for _, animation in pairs(Config.AllAnimations) do
            if animation.id == expression and animation.category == 'expressions' then
                return onExpression(animation)
            end
        end
    end

    RegisterCommand('expression', function(_, args)
        local emote = args[1]
        if not emote then return end
        local emote = emote:lower()

        if emote == 'c' or emote == 'cancel' then
            return onExpressionCancel()
        end

        setExpression(emote)
    end)

    RegisterNetEvent('cylex_animmenuv2:client:setExpression', setExpression)

    TriggerEvent('chat:addSuggestion', '/expression', 'Yüz ifadesi oynat.', {
        { name = "expression", help = "İfade adı" }
    })

    ------------------------------------------------------

    local function playEmote(emote)
        if emote then
            local emote = emote:lower()

            if emote == 'c' or emote == 'cancel' then
                if not canCancelAnimation then return end
                return onEmoteCancel()
            end

            for _, animation in pairs(Config.AllAnimations) do
                if animation.id == emote and animation.category ~= 'walks' and animation.category ~= 'expressions' then
                    return onAnimTriggered(animation)
                end
            end
        end
        print('Animation not found: ', emote)
        return false
    end

    RegisterCommand('e', function(_, args)
        return playEmote(args[1])
    end)

    TriggerEvent('chat:addSuggestion', '/e', 'Animasyon oynat.', {
        { name = "emote", help = "Animasyon adı" }
    })

    exports('playEmote', function(emote)
        return playEmote(emote)
    end)

    ------------------------------------------------------

    local function playSequence(sequenceId)
        sequenceId = tonumber(sequenceId)
        for _, sequence in pairs(sequences) do
            if tonumber(sequence.id) == sequenceId then
                return onSequence(sequence)
            end
        end

        print('Sequence not found: ', sequence)
        return false
    end

    RegisterCommand('sequence', function(_, args)
        return playSequence(args[1])
    end)

    TriggerEvent('chat:addSuggestion', '/sequence', 'ID ile sekans oynat.', {
        { name = "id", help = "Sekans ID" }
    })

    exports('playSequence', function(emote)
        return playSequence(emote)
    end)

    ------------------------------------------------------
    local function animPos(emote)
        if isEmotePlaying() then
            return createClonePed()
        end
        if not emote then return end
        local emote = emote:lower()
        for _, animation in pairs(Config.AllAnimations) do
            if animation.id == emote and animation.category ~= 'walks' and animation.category ~= 'expressions' then
                return createClonePed(animation)
            end
        end

        print('Animation not found: ', emote)
        return false
    end

    if Config.AnimPos.EnableAnimPos then
        RegisterCommand('animpos', function(_, args)
            return animPos(args[1])
        end)
    end

    exports('animpos', function(emote)
        return animPos(emote)
    end)


    -- You can add your exports etc here and prevent them from using animpos in certain situations.
    function canUseAnimPos(anim)
        local ped = PlayerPedId()
        if IsPedInAnyVehicle(ped, false) then
            return false
        end

        if IsPedSwimmingUnderWater(ped) or IsPedFalling(ped) or IsPedInMeleeCombat(ped) or IsPedShooting(ped) or IsPedGettingUp(ped) then
            return false
        end

        -- you can add your dead check here

        return true
    end

    -- You can add your exports etc here and prevent them from using emotes in certain situations.
    function canPlayEmote(anim)
        local ped = PlayerPedId()
        if IsPedSwimming(ped) or IsPedSwimmingUnderWater(ped) or IsPedFalling(ped) or IsPedInMeleeCombat(ped) or
            IsPedShooting(ped) or IsPedGettingUp(ped) then
            exports.qbx_core:Notify('Şu anda bu animasyonu oynatamazsınız.', 'error', 5000)
            return false
        end

        local wasDamaged = lib.callback.await('can9work:checkDamage:server:WasDamagedRecently', false, 10)
        if wasDamaged then
            exports.qbx_core:Notify('Hasar aldığınız için 10 saniye boyunca animasyon oynatamazsınız.', 'error',
                5000)
            return false
        end

        if exports.qbx_medical:IsDead() or exports.qbx_medical:IsLaststand() then
            exports.qbx_core:Notify('Ölüsün, animasyon oynatamazsın.', 'error', 5000)
            return false
        end

        return true
    end

    function isEmotePlaying()
        return playingEmote
    end

    exports('isEmotePlaying', isEmotePlaying)

    function getEmoteData(id)
        for _, animation in pairs(Config.AllAnimations) do
            if animation.id == id then
                return animation
            end
        end
        return nil
    end

    exports('getEmoteData', getEmoteData)

    -----------------------------------------------------
    -- /nearby [emote] - Send shared emote invite to nearest player
    RegisterCommand('nearby', function(_, args)
        local emoteName = args[1]
        if not emoteName then
            return sendNotification({
                timeout = 5,
                title = Lang('notification_error'),
                text = Lang('nearby_no_emote'),
                type = 'notification',
            })
        end

        emoteName = emoteName:lower()
        local animData = nil
        for _, animation in pairs(Config.AllAnimations) do
            if animation.id == emoteName then
                animData = animation
                break
            end
        end

        if not animData then
            return sendNotification({
                timeout = 5,
                title = Lang('notification_error'),
                text = Lang('nearby_emote_not_found'):format(emoteName),
                type = 'notification',
            })
        end

        if not canPlayEmote(animData) then return end

        local closestPlayer, closestDistance = GetClosestPlayer()
        if closestPlayer == -1 or closestDistance == -1 or closestDistance > 3.0 then
            return sendNotification({
                timeout = 5,
                title = Lang('notification_error'),
                text = Lang('no_player_nearby'),
                type = 'notification',
            })
        end

        local targetId = GetPlayerServerId(closestPlayer)
        TriggerServerEvent('cylex_animmenuv2:server:sendAnimationInvite', targetId, {
            animation = animData,
        })
    end)

    TriggerEvent('chat:addSuggestion', '/nearby', 'En yakın oyuncuya ortak animasyon daveti gönder.', {
        { name = "emote", help = "Animasyon adı (örn. dance2)" }
    })
end)


-- dpemotes & rpemotes support
RegisterNetEvent('animations:client:EmoteCommandStart', function(args)
    local emote = args[1] -- Assuming the emote is passed as the first argument
    if not emote then return end
    return exports['cylex_animmenuv2']:playEmote(emote)
end)

-- if you want to disable completely the idle animation,
-- remove cylex_animmenuv2/stream/[Custom Emotes]/move_m@generic_idles@std

RegisterCommand('idlecam', function()
    local ped = PlayerPedId()
    local idleCamDisabled = GetResourceKvpString("idleCam") ~= "on" -- DaddyRP: off unless the player turned it on
    if idleCamDisabled then
        DisableIdleCamera(false)
        SetPedCanPlayAmbientAnims(ped, true)
        SetResourceKvp("idleCam", "on")
        Notify('Boşta kamera açıldı!')
    else
        DisableIdleCamera(true)
        SetPedCanPlayAmbientAnims(ped, false)
        SetResourceKvp("idleCam", "off")
        Notify('Boşta kamera kapatıldı!')
    end
end)

Citizen.CreateThread(function()
    TriggerEvent("chat:addSuggestion", "/idlecam", "Bekleme kamerasını aç/kapat")
    local idleCamDisabled = GetResourceKvpString("idleCam") ~= "on" -- DaddyRP: off unless the player turned it on
    DisableIdleCamera(idleCamDisabled)
end)

CreateThread(function()
    local shiftPressed = false
    RegisterKeyMapping('+emote_shortcuts', 'Animasyon Kısayol Tuşu', 'keyboard', 'LSHIFT')
    RegisterCommand('+emote_shortcuts', function()
        shiftPressed = true
    end)
    RegisterCommand('-emote_shortcuts', function()
        shiftPressed = false
    end)

    for i = 1, 7 do
        RegisterCommand('emote_shortcuts_' .. i, function(source, args)
            if not shiftPressed then
                return print('Shift is not pressed', i)
            end

            local shortcut = shortcuts[i]
            if shortcut and next(shortcut) and shortcut.id then
                for _, animation in pairs(Config.AllAnimations) do
                    if animation.id == shortcuts[i].id then
                        return onAnimTriggered(animation)
                    end
                end
            end
        end)

        RegisterKeyMapping('emote_shortcuts_' .. i, 'Animasyon Kısayolu ' .. i, 'keyboard', 'NUMPAD' .. i)
    end
end)


-- With this event you can do what to do when the emote is canceled.
-- RegisterNetEvent('cylex_animmenuv2:client:onEmoteCancel', function(lastEmote)
--     print(lastEmote)
-- end)

-- With this event you can do what to do when the expression is changed.
-- RegisterNetEvent('cylex_animmenuv2:client:onExpressionSet', function(expression)
--     print(expression)
-- end)

-- With this event you can do what to do when the walk style is changed.
-- RegisterNetEvent('cylex_animmenuv2:client:onWalkSet', function(walkStyle)
--     print(walkStyle)
-- end)

-- With this event you can do what to do when the emote is triggered.
-- RegisterNetEvent('cylex_animmenuv2:client:onEmoteTriggered', function(emote)
--     print(emote)
-- end)

-- You can check the menu is open with this export
exports('isMenuOpened', function()
    return menuState
end)


-- It's for disabling weapon wheel while in menu.
CreateThread(function()
    while true do
        if menuState then
            BlockWeaponWheelThisFrame()
            DisableControlAction(0, 37, true)
            DisableControlAction(0, 199, true)
        else
            Wait(500)
        end
        Wait(1)
    end
end)

-- You can get the current emote with this export
exports('getCurrentEmote', function()
    return playingEmote
end)

local ragdoll = Config['Ragdoll']
if ragdoll.enabled then
    RegisterCommand('+ragdoll', function(source, args, raw) Ragdoll() end)
    RegisterCommand('-ragdoll', function(source, args, raw) StopRagdoll() end)
    RegisterKeyMapping("+ragdoll", "Karakteri Yere Düşür", "keyboard", ragdoll.keybind)

    local stop = true
    function Ragdoll()
        if IsPedInAnyVehicle(PlayerPedId(), false) then return end
        if ragdoll.ragdollAsToggle then
            stop = not stop
        else
            stop = false
        end

        while not stop do
            local ped = PlayerPedId()
            if IsPedOnFoot(ped) then
                SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
            end
            Wait(10)
        end
    end

    function StopRagdoll()
        if ragdoll.ragdollAsToggle then return end
        stop = true
    end
end


exports('IsPlayerCrouched', IsPlayerCrouched)
exports('IsPlayerProne', IsPlayerProne)
exports('IsPlayerCrawling', IsPlayerCrawling)

local crouch = Config['Crouch']
if crouch.enabled then
    if crouch.keybindEnabled then
        RegisterKeyMapping('+crouch', "Eğil", "keyboard", crouch.keybind)
        RegisterCommand('+crouch', function() CrouchKeyPressed() end, false)
        RegisterCommand('-crouch', function() end, false) -- This needs to be here to prevent errors/warnings
    end
    RegisterCommand('crouch', function()
        if inAction then return end

        if isCrouched then
            isCrouched = false
            return
        end

        if IsProne then return end

        AttemptCrouch(PlayerPedId())
    end, false)
    TriggerEvent('chat:addSuggestion', '/crouch', 'Eğil')
end

local crawl = Config['Crawl']

if crawl.enabled then
    if crawl.keybindEnabled then
        RegisterKeyMapping('crawl', "Sürün", "keyboard", Config['Crawl'].keybind)
    end
    RegisterCommand('crawl', function() CrawlKeyPressed() end, false)
end

local handsup = Config['Handsup']
if handsup.enabled then
    RegisterKeyMapping(handsup.command, 'Eller Yukarı', 'keyboard', handsup.keybind)

    handsUp = false
    local controls = handsup.controls
    RegisterCommand(handsup.command, function()
        local ped = PlayerPedId()
        local animDict = "missminuteman_1ig_2"
        local animName = 'handsup_base'
        if not HasAnimDictLoaded(animDict) then
            if lib and lib.requestAnimDict then
                lib.requestAnimDict(animDict, 5000)
            else
                RequestAnimDict(animDict)
                local timeout = 0
                while not HasAnimDictLoaded(animDict) and timeout < 50 do
                    Wait(10)
                    timeout = timeout + 1
                end
            end
        end

        if IsPedReloading(ped) or IsPedShooting(ped) then return end
        if exports.qbx_medical:IsDead() or exports.qbx_medical:IsLaststand() then return end
        if IsProne or isCrawling then return end

        handsUp = not handsUp
        if handsUp then
            -- Cancel active emote if any
            if playingEmote then
                onEmoteCancel()
            end

            -- Stop crouching if active
            if isCrouched then
                isCrouched = false
            end

            -- Stop pointing if active
            if mp_pointing then
                mp_pointing = false
            end

            TriggerEvent('cylex:handsUp', true)
            TaskPlayAnim(ped, animDict, animName, 8.0, 8.0, -1, 50, 0, false, false, false)
        else
            TriggerEvent('cylex:handsUp', false)
            ClearPedTasks(ped)
        end

        while handsUp do
            Wait(1)
            if not IsEntityPlayingAnim(ped, animDict, animName, 3) or exports.qbx_medical:IsDead() or exports.qbx_medical:IsLaststand() or IsPedInAnyVehicle(ped, false) then
                handsUp = false
                ClearPedTasks(ped)
            end

            for _, control in pairs(controls) do
                DisableControlAction(0, control, true)
            end
        end
        for _, control in pairs(controls) do
            EnableControlAction(0, control, true)
        end
    end, false)
end

local pointing = Config['Pointing']
if pointing.enabled then
    RegisterKeyMapping(pointing.command, 'İşaret Et', 'keyboard', pointing.keybind)
    mp_pointing = false

    local function startPointing()
        local ped = PlayerPedId()
        if not HasAnimDictLoaded("anim@mp_point") then
            if lib and lib.requestAnimDict then
                lib.requestAnimDict("anim@mp_point", 5000)
            else
                RequestAnimDict("anim@mp_point")
                local timeout = 0
                while not HasAnimDictLoaded("anim@mp_point") and timeout < 50 do
                    Wait(10)
                    timeout = timeout + 1
                end
            end
        end
        if not HasAnimDictLoaded("anim@mp_point") then return end
        SetPedCurrentWeaponVisible(ped, 0, true, true, true)
        SetPedConfigFlag(ped, 36, 1)
        TaskMoveNetworkByName(ped, 'task_mp_pointing', 0.5, false, 'anim@mp_point', 24)
        RemoveAnimDict("anim@mp_point")
    end

    local function stopPointing()
        local ped = PlayerPedId()
        if not IsPedInjured(ped) then
            RequestTaskMoveNetworkStateTransition(ped, 'Stop')
            ClearPedSecondaryTask(ped)
            if not IsPedInAnyVehicle(ped, 1) then
                SetPedCurrentWeaponVisible(ped, 1, true, true, true)
            end
            SetPedConfigFlag(ped, 36, false)
        end
    end

    RegisterCommand('point', function()
        local ped = PlayerPedId()
        if not IsPedInAnyVehicle(ped, false) then
            if not mp_pointing and GetSelectedPedWeapon(ped) ~= GetHashKey("WEAPON_UNARMED") then
                Notify(Lang('pointing_weapon_error'))
                return
            end
            mp_pointing = not mp_pointing
            if mp_pointing then
                startPointing()
            else
                stopPointing()
            end
            while mp_pointing do
                if GetSelectedPedWeapon(ped) ~= GetHashKey("WEAPON_UNARMED") then
                    stopPointing()
                    mp_pointing = false
                    break
                end
                local camPitch = GetGameplayCamRelativePitch()
                local camHeading = GetGameplayCamRelativeHeading()
                local cosCamHeading = Cos(camHeading)
                local sinCamHeading = Sin(camHeading)
                camPitch = math.max(-70.0, math.min(42.0, camPitch))
                camPitch = (camPitch + 70.0) / 112.0
                camHeading = math.max(-180.0, math.min(180.0, camHeading))
                camHeading = (camHeading + 180.0) / 360.0

                local coords = GetOffsetFromEntityInWorldCoords(ped,
                    (cosCamHeading * -0.2) - (sinCamHeading * (0.4 * camHeading + 0.3)),
                    (sinCamHeading * -0.2) + (cosCamHeading * (0.4 * camHeading + 0.3)), 0.6)
                local ray = StartShapeTestCapsule(coords.x, coords.y, coords.z - 0.2, coords.x, coords.y, coords.z + 0.2,
                    0.4, 95, ped, 7)
                local _, blocked = GetRaycastResult(ray)
                SetTaskMoveNetworkSignalFloat(ped, "Pitch", camPitch)
                SetTaskMoveNetworkSignalFloat(ped, "Heading", camHeading * -1.0 + 1.0)
                SetTaskMoveNetworkSignalBool(ped, "isBlocked", blocked)
                SetTaskMoveNetworkSignalBool(ped, "isFirstPerson",
                    GetCamViewModeForContext(GetCamActiveViewModeContext()) == 4)
                Wait(0)
            end
        end
    end, false)
end


exports('SetCanCancelAnimation', function(canCancel)
    canCancelAnimation = canCancel
end)



------ [[[[[ GROUP EMOTE ]]]]] -------

-- Export for other scripts
exports('isInGroup', function()
    return activeGroup ~= nil
end)

exports('getActiveGroup', function()
    return activeGroup
end)

---------------------------------------



------- [[[[[ RADIAL MENU ]]]]] -------
function canOpenRadialMenu()
    local ped = PlayerPedId()
    if IsPedSwimming(ped) or IsPedSwimmingUnderWater(ped) or IsPedFalling(ped) or IsPedInMeleeCombat(ped) or IsPedShooting(ped) or IsPedGettingUp(ped) then
        return false
    end
    -- you can add your dead check here

    return true
end

exports('canOpenRadialMenu', canOpenRadialMenu)

exports('isWheelOpen', function()
    return wheelOpen
end)

CreateThread(function()
    if not Config or not Config.EmoteWheel or not Config.EmoteWheel.enabled then return end
    RegisterKeyMapping('+openEmoteWheel', 'Animasyon Çarkını Aç', 'keyboard', Config.EmoteWheel.keybind or 'B')

    RegisterCommand('+openEmoteWheel', function()
        if wheelOpen then return end
        if not canOpenRadialMenu() then return end

        isWheelKeyPressed = true

        if ignoreNextPress then
            return
        end

        openEmoteWheel()
    end, false)

    RegisterCommand('-openEmoteWheel', function()
        isWheelKeyPressed = false
        ignoreNextPress = false
    end, false)
end)

------ [[[[[ TGIANN PHONE ACCESSORIES ]]]]] -------
-- Emotes that use one of these phone props put the player's own phone in their hand, case and accessories included.
-- If tgiann-phone-accessories isn't running, the emote's normal prop is used.
-- Set enabled = false to turn it off.
Config.HandPhone = {
    enabled = true,
    resource = 'tgiann-phone-accessories',
    props = {
        'prop_phone_ing',
        'prop_phone_ing_02',
        'prop_phone_ing_03',
        'prop_player_phone_01',
        'prop_player_phone_02',
        'prop_npc_phone',
        'prop_npc_phone_02',
        'prop_amb_phone',
        'prop_cs_phone_01',
        'prop_phone_proto',
        'prop_phone_taymckenzienz', -- custom phone used by 11 emotes in AnimationList.json
    },
}

CreateThread(function()
    -- Wait one tick so every client file is loaded, then wrap the prop functions
    local hp = Config.HandPhone
    if not hp or not hp.enabled or not AddPropToPlayer or not DestroyAllProps then return end

    local function modelKey(model)
        return (type(model) == 'number' and model or joaat(model)) % 0x100000000
    end

    local phoneModels = {}
    for i = 1, #hp.props do
        phoneModels[modelKey(hp.props[i])] = true
    end

    local handPhoneActive = false
    local originalAddProp = AddPropToPlayer
    local originalDestroyProps = DestroyAllProps

    AddPropToPlayer = function(ped, model, bone, off1, off2, off3, rot1, rot2, rot3, textureVariation)
        local playerPed = PlayerPedId()
        if (ped or playerPed) == playerPed and phoneModels[modelKey(model)] and GetResourceState(hp.resource) == 'started' then
            local ok, entity = pcall(function()
                return exports[hp.resource]:SpawnHandPhone({
                    bone = bone,
                    offset = vec3(off1 or 0.0, off2 or 0.0, off3 or 0.0),
                    rotation = vec3(rot1 or 0.0, rot2 or 0.0, rot3 or 0.0),
                })
            end)
            if ok and entity and DoesEntityExist(entity) then
                prop = entity -- used for ptfx sync
                PlayerHasProp = true
                handPhoneActive = true
                return true
            end
        end
        return originalAddProp(ped, model, bone, off1, off2, off3, rot1, rot2, rot3, textureVariation)
    end

    DestroyAllProps = function(...)
        originalDestroyProps(...)
        if handPhoneActive then
            handPhoneActive = false
            if GetResourceState(hp.resource) == 'started' then
                pcall(function() exports[hp.resource]:DeleteHandPhone() end)
            end
        end
    end
end)
