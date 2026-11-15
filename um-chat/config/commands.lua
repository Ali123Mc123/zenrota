--[[
        Actions:
        Examples such as /me /do are found here, every command you add to actions will be ?automatically added,

        You can add extra things like /me and /do to indicate status

        Or you can add only chatMessage like ooc no drawtext, for this delete drawText table
        https://docs.uyuyorumstore.com/scripts/um-chat/addActions
    ]]
return {
    maxCharacterLength = 200,

    --[[
        Anonymous Mask:
        be anonymous when you wear a mask
    ]]
    anonymousMask = {
        status = true,

        name = 'Bilinmeyen',
        --[[ mode
             1: excluded (if the mask slot number is in the list, not anonymous),
             2: included (if the mask slot number is in the list, anonymous)
        ]]
        mode = 1,
        --[[
        -- Exclude these mask slots number
            if mode 1 is selected, the mask slot number in this list will not be anonymous
            if mode 2 is selected, the mask slot number in this list will be anonymous (delete [-1] and 0 from the list)
        ]]
        maskSlots = {
            [-1] = true,
            [0] = true,
            --[250] = true,
        }
    },

    actions = {
        --[[ Default Commands: ]]
        ['me'] = {
            status = true,
            command = {
                help = '/me <eylem>',
                params = {
                    { name = 'message', type = 'longString' }
                }
            },
            distance = 5,
            showID = false,
            drawText = {
                -- rect = 0.025, -- Removed to disable background card
                z = 1.0, -- Moved higher to appear above character's head
                color = { r = 255, g = 255, b = 255 } -- White text for better visibility
            },
            tag = {
                name = 'ME',
                background = '#fbbf24'
            },
            logs = true,
        },
        ['do'] = {
            status = true,
            command = {
                help = '/do <durum>',
                params = {
                    { name = 'message', type = 'longString' }
                }
            },
            distance = 5,
            showID = false,
            drawText = {
                -- rect = 0.025, -- Removed to disable background card
                z = 1.0, -- Moved higher to appear above character's head
                color = { r = 128, g = 0, b = 255 }, -- Purple text
            },
            tag = {
                name = 'DO',
                background = '#f87171'
            },
            logs = true,
        },
        --[[ Games Commands (daddy-dice resource handles these with 3D props & NUI) ]]
        ['tkm'] = {
            status = false,
            command = false,
            distance = 5,
            drawText = {
                font = 7,
                rect = 0.045,
                z = 0.80,
                color = { r = 0, g = 0, b = 0 }
            },
            anim = {
                dict = 'anim@mp_player_intcelebrationmale@wank',
                clip = 'wank',
                duration = 2500
            },
            message = function()
                local rpsItems = {
                    '✊ Taş',
                    '✋ Kağıt',
                    '✌️ Makas'
                }
                return rpsItems[math.random(1, #rpsItems)]
            end
        },
        ['zarat'] = {
            status = false,
            command = {
                help = 'Zar At (/zarat [sayı])',
                params = {
                    { name = 'max', help = 'Maksimum zar sayısı (Örn: 6, 12, 30)', optional = true }
                }
            },
            distance = 5,
            drawText = {
                font = 7,
                rect = 0.045,
                z = 0.80,
                color = { r = 255, g = 255, b = 255 }
            },
            anim = {
                dict = 'anim@mp_player_intcelebrationmale@wank',
                clip = 'wank',
                duration = 2500
            },
            message = function(a, b, c)
                return '🎲 1/6'
            end
        },
        ['zar'] = {
            status = false,
            command = {
                help = 'Zar At (/zar [sayı])',
                params = {
                    { name = 'max', help = 'Maksimum zar sayısı (Örn: 6, 12, 30)', optional = true }
                }
            },
            distance = 5,
            drawText = {
                font = 7,
                rect = 0.045,
                z = 0.80,
                color = { r = 255, g = 255, b = 255 }
            },
            anim = {
                dict = 'anim@mp_player_intcelebrationmale@wank',
                clip = 'wank',
                duration = 2500
            },
            message = function(a, b, c)
                return '🎲 1/6'
            end
        },
        ['dice'] = {
            status = false,
            command = {
                help = 'Zar At (/dice [sayı])',
                params = {
                    { name = 'max', help = 'Maksimum zar sayısı (Örn: 6, 12, 30)', optional = true }
                }
            },
            distance = 5,
            drawText = {
                font = 7,
                rect = 0.045,
                z = 0.80,
                color = { r = 255, g = 255, b = 255 }
            },
            anim = {
                dict = 'anim@mp_player_intcelebrationmale@wank',
                clip = 'wank',
                duration = 2500
            },
            message = function(a, b, c)
                return '🎲 1/6'
            end
        },

    },

    --[[
        Custom Commands:
        These are [not added automatically] and are your individual commands, you must create them yourself
    ]]
    customs = {
        ['pm'] = false
    }
}
