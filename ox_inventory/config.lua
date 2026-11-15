Config = {}

-- Default Theme Color | Configuration
Config.DefaultThemeColor = '#d1394eb0' -- Inventory Theme Color

-- Logos | Configuration
Config.Logos = { -- Fivemanage/Discord/Imgur (Others should work)
    ServerLogo = 'https://i.imgur.com/lZn2wxx.png',
}

-- Avatars | Configuration
-- Set your discord bot token or steam api key in server.lua
Config.Avatars = { -- If disabled, server logo set in config.logos will be used
    enabled = true, -- Enable or disable the profile picture feature
    type = 'discord', -- 'discord' or 'steam'
}

-- Inventory Slots | Configuration
Config.PlayerSlots = 50 -- Number of slots for player inventories
Config.DropSlots = 50   -- Number of slots for dropped item inventories

-- Language | Configuration
-- 'en', 'es', 'fr', 'de', 'pt-br' & more
Config.Language = 'tr'

-- Hotbar Slots | Configuration
Config.SixthSlot = true -- Enable 6th hotbar slot (false = 5 slots per row)

-- Locked Slot | Configuration
-- If true, disables protection on the last hotbar slot (5th or 6th depending on Config.SixthSlot)
Config.DisableLockedSlot = false

-- Give Item Selector | Configuration
-- Controls behavior of the "Pick a player to give to" selector that appears after pressing Give.
Config.GiveItemSelector = {
    allowMovement = false,  -- false = no movement at all / true: free to move/look around.
    maxDistance = 0.8,      -- When allowMovement is true, the menu auto-closes if the player walks this far from where they opened it.
}

-- Backpacks | Configuration
-- The item name MUST exist in items.lua and have client.event = 'ox_inventory:openBackpack'
-- Add more tiers (e.g. ['tactical_backpack'] = { slots = 30, maxWeight = 22000 }) as needed.
Config.Backpacks = {
    enabled = true,
    items = {
        ['small_backpack']  = { slots = 10, maxWeight = 5000  },
        ['medium_backpack'] = { slots = 20, maxWeight = 15000 },
        ['large_backpack']  = { slots = 40, maxWeight = 30000 },
    },
}

-- Equipment Slots | Configuration
-- Items placed here don't count toward player weight (worn on the person).
Config.EquipmentSlots = {
    enabled = true,
    slots = {
        phone = {
            enabled = true,
            order = 1,
            label = 'Telefon',
            icon = 'mingcute:cellphone-2-fill',
            items = { 'phone' },
        },
        armor = {
            enabled = true,
            order = 2,
            label = 'Zırh',
            icon = 'game-icons:kevlar-vest',
            -- The items list is auto-populated from Config.Armor.items at the bottom of this
            -- file — don't edit it here. Add new armor tiers to Config.Armor.items instead.
            items = {'armour', 'pd_armour'},
        },
    },
}

-- Give Item Animation | Configuration
-- Plays a synchronized handoff animation on both players with a prop in hand when an item is given.
Config.GiveAnimation = {
    enabled = true,           -- Set to false to disable the entire system.
    duration = 2400,          -- Total animation length in ms.
    handoffAt = 1200,         -- When the prop transfers from giver -> receiver (ms into the anim).
    animDict = 'mp_common',
    giverAnim = 'givetake1_a',
    receiverAnim = 'givetake1_b',
    -- Default prop used for any item not listed in `items` below. (Set model = false to hide default prop)
    default = {
        model = false, -- Kardboard kutu (prop_cs_cardbox_01) kaldırıldı
        bone = 28422, -- 28422 = right hand (SKEL_R_Hand). 60309 = left hand.
        pos = vec3(0.05, 0.05, 0.0),
        rot = vec3(0.0, 0.0, 0.0),
    },
    -- Weapon-specific defaults. Any item starting with "WEAPON_" automatically uses its real
    -- in-game world model as the prop; these values control how it attaches to the hand.
    -- You can still override individual weapons in the `items` table below for custom offsets.
    weapon = {
        bone = 28422,         -- right hand
        pos = vec3(0.0, 0.0, 0.0),
        rot = vec3(0.0, 0.0, 0.0),
    },
    -- Per-item-name overrides. Add any item name here to swap the prop.
    -- Common money items are pre-configured; add more (e.g. ['gold_bar'] = {...}) as needed.
    items = {
        money = {
            model = 'prop_anim_cash_pile_01',
            bone = 28422,
            pos = vec3(0.05, 0.04, 0.03),
            rot = vec3(0.0, 0.0, 0.0),
        },
        cash = {
            model = 'prop_anim_cash_pile_01',
            bone = 28422,
            pos = vec3(0.05, 0.04, 0.03),
            rot = vec3(0.0, 0.0, 0.0),
        },
        black_money = {
            model = 'prop_anim_cash_pile_01',
            bone = 28422,
            pos = vec3(0.05, 0.04, 0.03),
            rot = vec3(0.0, 0.0, 0.0),
        },
    },
}

-- Robbing | Configuration
-- This is the robbing feature that allows players to rob other players
Config.Robbing = {
    enabled = false, -- Enable or disable the robbing feature
    handsUpRequired = true, -- Require the target player to have their hands up
    useTarget = true, -- If true, use ox_target for robbing
    useCommand = true, -- If true, allow using /robplayer command
    requireWeapon = true, -- If true, the robber must have a weapon in hand
    robStatus = 'alive', -- 'alive', 'dead', or 'both'
    robbingTime = 6000, -- Time in milliseconds for the full per-item search reveal animation (divided across occupied slots; a per-slot floor of 550ms applies in the UI)
    copBypass = true, -- If true, police group members can take from the victim's locked slot (it shows green to them during a robbery)
    robbingAnim = {
        dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@',
        anim = 'machinic_loop_mechandplayer',
        flag = 49
    },
    victimNotification = true, -- Notify the victim that they are being robbed
}

-- Armor | Configuration
Config.Armor = {
    -- Master toggle. When false, the entire durability + plates system is bypassed and the
    -- original "use armour item = instant 100 armor, item consumed" behavior is restored.
    enabled = false,
    syncIntervalMs = 2000, -- How often the client pushes the live ped armor value to the server while equipped
    plateMinPercent = 25,  -- Below this percent of the vest's current max, plates are rejected

    -- Wearable armor items. Add more vest tiers here (light, heavy, ballistic, etc.).
    -- IMPORTANT: `armor` / `maxDurability` MUST be 1-100 and nothing higher or you will break the armor system
    items = {
        armour    = { armor = 100,  maxDurability = 100  },
        pd_armour   = { armor = 100,  maxDurability = 100  },
        -- heavy_vest    = { armor = 100, maxDurability = 100 },
    },

    -- Plates: item names that repair armor when dragged onto the equipped armor slot.
    -- `repair` adds to durability (capped at the vest's current maxDurability).
    -- `maxCost` permanently lowers the vest's maxDurability each time it's applied.
    plates = {
        armour  = { repair = 25, maxCost = 5  },
        pd_armour = { repair = 50, maxCost = 10 },
    },
}

-- Creator Codes | Configuration
-- Create unlimited creator codes for players to use in all shops or specified shops in the shops.lua
Config.CreatorCodes = {
    enabled = false, -- Enable or disable the creator code feature
    codes = {
        ['WELCOME10'] = 0.10, -- 10% discount
        ['MOTION20'] = 0.20,  -- 20% discount
    }
}

-- Rarity | Configuration
-- Default rarity if none is specified on items in items.lua
Config.DefaultRarity = 'Common'

-- These rarities can be set to an item in items.lua using rarity = 'RarityName',
Config.Rarities = {
    ['Common'] = {
        color = '#9d9d9d', -- gri
        label = 'Sıradan'
    },
    ['Rare'] = {
        color = '#0070dd', -- mavi
        label = 'Değerli'
    },
    ['Epic'] = {
        color = '#a335ee', -- mor
        label = 'Nadir'
    },
    ['Legendary'] = {
        color = '#ff0000', -- kırmızı
        label = 'Efsanevi'
    },
}

-- Item Types | Configuration
-- These item types can be set to an item in items.lua using itemType = 'itemType',
Config.ItemTypes = {
    ['item'] = {
        label = 'Eşya',
        color1 = '#9d9d9d', -- Must be 6 characters
        color2 = '#7d7d7d' -- Must be 6 characters
    },
    ['medical'] = {
        label = 'Tıbbi',
        color1 = '#ff4d4d', -- Must be 6 characters
        color2 = '#cc0000' -- Must be 6 characters
    },
    ['food'] = {
        label = 'Yiyecek',
        color1 = '#ffcc00', -- Must be 6 characters
        color2 = '#ff9900' -- Must be 6 characters
    },
    ['drink'] = {
        label = 'İçecek',
        color1 = '#33ccff', -- Must be 6 characters
        color2 = '#0088cc' -- Must be 6 characters
    },
    ['weapon'] = {
        label = 'Silah',
        color1 = '#ff8000', -- Must be 6 characters
        color2 = '#e65c00' -- Must be 6 characters
    },
    ['ammo'] = {
        label = 'Mermi',
        color1 = '#99cc00', -- Must be 6 characters
        color2 = '#669900' -- Must be 6 characters
    },
    ['tool'] = {
        label = 'Alet',
        color1 = 'FFC6FD2D', -- Must be 6 characters
        color2 = 'FFE1FFB9' -- Must be 6 characters
    },
    ['material'] = {
        label = 'Malzeme',
        color1 = '#996633', -- Must be 6 characters
        color2 = '#664422' -- Must be 6 characters
    },
    ['valuable'] = {
        label = 'Değerli',
        color1 = '#e6cc80', -- Must be 6 characters
        color2 = '#b38f00' -- Must be 6 characters
    },
    ['police'] = {
        label = 'Polis',
        color1 = 'FF003CFF', -- Must be 6 characters
        color2 = 'FF8ED5FF' -- Must be 6 characters
    }
}

-- Sound | Configuration
-- This is the sound feature that allows players to play sounds in the inventory
Config.Sound = {
    enabled = false,  -- Set to false to disable sounds
    library = 'interact-sound',  -- Options: 'interact-sound' or 'xsound'
    -- (requires sound to be registered in interact-sound html/sounds)
    interactSound = {
        soundName = 'clicksound',  -- Sound registered in interact-sound
        volume = 0.1,
    },
    -- Sound settings for xsound - Use this with custom sound files in web/sounds/
    xSound = {
        soundName = 'inventory_click',  -- Unique identifier for this sound
        soundUrl = 'nui://ox_inventory/web/sounds/clicksound.ogg',  -- Your custom sound file
        volume = 0.5,
        loop = false,
    },
}

-- UI Settings | Configuration
-- This is the UI settings feature that allows players to change the UI settings in the inventory
Config.UISettings = {
    allowSettingsMenu = true,  -- Set to false to disable the settings icon/menu in the inventory UI
}

-- [[ Default Player Inventory Settings | Configuration ]]
-- This is the default player inventory settings feature that allows players to change the default inventory settings in the inventory
Config.DefaultPlayerSettings = {
    -- Inventory Type
    inventoryView = 'default', -- options: 'default', 'spaced', 'perspective'
    -- Fast Slots Style (Hotbar):
    hotbarStyle = 'hexagon', -- options: 'default' or 'hexagon'
    -- Header Shape:
    headerStyle = 'hexagon', -- options: 'square' or 'hexagon'
    -- Header Style (Icon Background):
    headerShapeStyle = 'style1', -- options: 'style1' or 'style2'
    -- Background Opacity:
    backgroundOpacity = 0.1, -- options: 0.0 to 1.0
    -- Font Style:
    themeFont = 'Default', -- options: 'Default', 'Roboto', 'Manrope', 'Space Grotesk'
    -- Weight Bar Style:
    weightBarType = 'dashes', -- options: 'solid' or 'dashes'
    -- Weight Bar Shape:
    weightBarShape = 'rounded', -- options: 'rounded' or 'squared'
    -- Weight Bar Background:
    weightBarBackground = true, -- options: true or false
    -- Notification Style:
    notificationStyle = 'style1', -- options: (Modern) 'style1' or (Default) 'style2'
    -- Notification Location (only affects Modern style):
    notificationLocation = 'bottom-center', -- options: 'left', 'top-center', 'bottom-center'
    -- ESC Button Style:
    escButtonStyle = 'style1', -- options: 'style1' (Slider), 'style2' (Split), 'style3' (Keycap)
    -- Avatar Shape:
    playerAvatarShape = 'square', -- options: 'circle' or 'square'
    -- Server Branding:
    showBranding = false, -- options: true or false
    -- Show Player Info:
    showPlayerInfo = false, -- options: true or false
    -- Show Player Avatar:
    showPlayerAvatar = false, -- options: true or false
    -- Show Player Name:
    showPlayerName = false, -- options: true or false
    -- Show Player Cash:
    showPlayerCash = false, -- options: true or false
    -- Show Player Bank:
    showPlayerBank = false, -- options: true or false
    -- Show Player ID:
    showPlayerId = false, -- options: true or false
    -- Show Player Info Icon Background:
    showPlayerInfoIconBackground = true, -- options: true or false
    -- Icon Color (color of slot icons, text, and hotbar 1-6 numbers):
    iconColor = '#FFFFFF', -- options: '#FFFFFF' (white), '#000000' (black), or any hex
    -- Slot Hover style (empty-slot hover appearance):
    slotHover = 'theme', -- options: 'theme' (theme-colored) or 'default' (original white/grey)
}

-- UI Text | Configuration
Config.Texts = {
    ServerNamePart1 = 'DADDY',
    ServerNamePart2 = '2.0',
    TopInfoDescription = 'Envanter',
    Pockets = 'Cepler',
    PocketsDescription = 'Karakterinin üzerindeki eşyalar',
    Secondary = 'İkincil / Yerdeki',
    SecondaryDescription = 'Etraftaki veya ikincil envanter eşyaları',
    FastSlot = 'Hızlı Slotlar',
    FastSlotDescription = 'Eşyalarını hızlıca kuşan',
    Close_header_1 = 'Envanteri',
    Close_header_2 = 'Kapat',
}

if Config.EquipmentSlots and Config.EquipmentSlots.slots and Config.EquipmentSlots.slots.armor then
    if Config.Armor and Config.Armor.enabled ~= false and Config.Armor.items then
        local list = {}
        for itemName in pairs(Config.Armor.items) do list[#list + 1] = itemName end
        Config.EquipmentSlots.slots.armor.items = list
    else
        Config.EquipmentSlots.slots.armor.enabled = false
    end
end

Config.EquipmentReservedSlots = {}   -- { [slotNumber] = slotKey }
Config.EquipmentSlotCount = 0
if Config.EquipmentSlots and Config.EquipmentSlots.enabled and Config.EquipmentSlots.slots then
    -- Enabled keys in a stable order (by `order`, then name) — must match the React renderer.
    local ordered = {}
    for key, slotCfg in pairs(Config.EquipmentSlots.slots) do
        if slotCfg and slotCfg.enabled ~= false then ordered[#ordered + 1] = key end
    end
    table.sort(ordered, function(a, b)
        local oa = Config.EquipmentSlots.slots[a].order or 999
        local ob = Config.EquipmentSlots.slots[b].order or 999
        if oa ~= ob then return oa < ob end
        return a < b
    end)

    local base = Config.PlayerSlots or 50
    for i = 1, #ordered do
        local key = ordered[i]
        local slotNumber = base + i
        Config.EquipmentSlots.slots[key].invSlot = slotNumber   -- exposed to NUI via init payload
        Config.EquipmentReservedSlots[slotNumber] = key
    end
    Config.EquipmentSlotCount = #ordered
end