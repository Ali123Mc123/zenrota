local function get_self_tag()
    local ply = LocalPlayer.state.phoneData
    if not ply or not ply.selectedAccounts then
        return false
    end
    if not ply.selectedAccounts['hacker'] or not ply.selectedAccounts['hacker'].logged then
        return false
    end
    return ply.selectedAccounts['hacker'].tag
end

HackerConfig = {
    -- If you dont want the "console" feature, just set it to false
    enable_console = true,

    levels = {
        -- { xp = 0, title = "Script Kiddie", color = "#95a5a6" },
        { xp = 25, title = "Çaylak Hacker", color = "#3498db" },
        { xp = 50, title = "Hacker", color = "#9b59b6" },
        { xp = 75, title = "Elit Hacker", color = "#e67e22" },
        { xp = 100, title = "Siber Büyücü", color = "#e74c3c" },
        { xp = 125, title = "Legendary Hacker", color = "#f1c40f" },
    },

    commands = {
        ['help'] = {
            command = "help",
            description = "Kullanılabilir komutlar:",
            need_xp = 0,
            need_level = 1
        },
         ['whoami'] = {
            command = "whoami",
            description = "Ben kimim?",
            need_xp = 1,
            need_level = 1
        },
        ['whoweare'] = {
            command = "whoweare",
            description = "Kim olduğumuzu göster.",
            need_xp = 2,
            need_level = 1
        },
        ['echo'] = {
            command = "echo",
            description = "Girilen metni geri yazdır.",
            need_xp = 1,
            need_level = 0
        },
        ['account'] = {
            command = "account",
            description = "Hesap bilgilerini göster.",
            need_xp = 10,
            need_level = 4
        },
        ['location'] = {
            command = "location",
            description = "Hedefin konumunu göster.",
            need_xp = 15,
            need_level = 3,
            cooldown = {
                max_per_day = 5,
                reset_time = 3 * 60 * 60, -- 3 hours
            } 
        },
        ['user_info'] = {
            command = "user_info",
            description = "Hedef kullanıcının bilgilerini göster.",
            need_xp = 10,
            need_level = 5
        },
        ['crack_code'] = {
            command = "crack_code",
            description = "Şifre Kır",
            need_xp = 0,
            need_level = 1,
            reward_xp = 1,
            
            cooldown = {
                max_per_day = 5,
                reset_time = 1 * 60 * 60, -- 1 hours
            } 
        },
    },    
}

HackerConfig.command_handlers = {
    ['help'] = {
        can_use = function() 
            return true 
        end,
        action = function(args)
            local output = {HackerConfig.commands['help'].description}
            for k, v in pairs(HackerConfig.commands) do
                -- Format: - command : description
                local padding = string.rep(' ', 25 - #v.command)
                table.insert(output, '- ' .. v.command .. padding .. ': ' .. v.description)
            end
            return true, output
        end
    },
    ['whoami'] = {
        can_use = function() 
            return true 
        end,
        action = function(args)
            local self_tag = get_self_tag()
            if not self_tag then
                return "Giriş yapmadın."
            end
            local account = AppAccounts['hacker'][self_tag]
            if not account then
                return "Hesap bulunamadı."
            end
            return true, ("Giriş yapılan hesap: %s | XP: %d | Seviye: %d"):format(account.tag, account.xp, account.level)
        end
    },
    ['whoweare'] = {
        can_use = function() 
            return true 
        end,
        action = function(args)
            print("We are Cylex, the developers of this phone.", json.encode(args))
            return true, "Biz Cylex, bu telefonun geliştiricileriyiz."
        end
    },
    ['echo'] = {
        can_use = function() 
            return true 
        end,
        action = function(args)
            if #args == 0 then
                return "Kullanım: echo [metin]"
            end
            return true, table.concat(args, " ")
        end
    },
    ['account'] = {
        can_use = function() 
            return true 
        end,
        action = function(args)
            local app = args[1]
            local tag = args[2]
            local blacklist = {
                ["twitter"] = {
                    ["cylex"] = true,
                }
            }

            if blacklist[app] and blacklist[app][tag] then
                return false, "Bu hesaba erişim kısıtlı."
            end
            local data = Cylex.TriggerCallback('cylex_phone:server:hacker:getAccountData', {
                app = app,
                tag = tag,
            })
            return data.success, data.message
        end
    },
    ['location'] = {
        can_use = function() 
            return true 
        end,
        action = function(args)
            print(134, json.encode(args))
            local data = Cylex.TriggerCallback('cylex_phone:server:hacker:getLocationData', {
                targetNumber = args[1],
            })

            if data.success then
                create_radius_blip({
                    coords = data.coords,
                    radius = 100,
                    duration = 60000,
                    jitter = 60,
                })
            end

            return data.success, data.message
        end
    },
    ['user_info'] = {
        can_use = function() 
            return true 
        end,
        action = function(args)
            print(141, json.encode(args))
            local user_info = Cylex.TriggerCallback('cylex_phone:server:hacker:getUserInfoData')
            return true, user_info
        end
    },
    ['crack_code'] = {
        can_use = function() 
            return true 
        end,
        action = function(args)
            return true
        end,
    },
}

function create_radius_blip(args)
    local coords = args.coords
    local baseX = coords.x or coords[1]
    local baseY = coords.y or coords[2]
    local baseZ = coords.z or coords[3] or 0.0

    -- Parameters args.radius = radius(m), args.duration = duration(ms), args.jitter = jitter(m)
    local radiusMeters = tonumber(args.radius) or 120.0   -- Çember yarıçapı (haritada)
    local durationMs   = tonumber(args.duration) or 60000   -- Blip kalma süresi
    local maxJitter    = tonumber(args.jitter) or 70.0    -- Merkez sapması

    local angle = math.random() * math.pi * 2
    local dist  = math.sqrt(math.random()) * maxJitter
    local cx    = baseX + math.cos(angle) * dist
    local cy    = baseY + math.sin(angle) * dist
    local cz    = baseZ

    -- Haritada kırmızı yarıçap blip'i oluştur
    local blip = AddBlipForRadius(cx + 0.0, cy + 0.0, cz + 0.0, radiusMeters + 0.0)
    if blip ~= 0 then
        SetBlipColour(blip, 1)       -- 1 = Kırmızı
        SetBlipAlpha(blip, 120)      -- Şeffaflık (0-255)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Muhtemel Konum")
        EndTextCommandSetBlipName(blip)

        -- Süre sonunda blip'i kaldır
        Citizen.SetTimeout(durationMs, function()
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end)
    end
end