Roles = {}

-- Izin verilen roller (whitelist modu icin)
-- Config.Whitelist.enabled = false ise bu liste kontrol EDILMEZ
Roles.allowlistedRoles = {
    '1450669277186097203',  -- Üye rolü — bu role sahip olmayan sunucuya giremez
}

-- Oncelik rolleri: { id, name, points }
-- Oyuncunun TUMU eslesen rollerin puanlari TOPLANIR (stackable)
Roles.priorityRoles = {
    { id = '1450693427690868831', name = 'DADDY',           points = 100000 },
    { id = '1450693433504043038', name = 'Project Leader',  points = 70000  },
    { id = '1450693612097765440', name = 'Daddy Team',      points = 50000  },
    { id = '1450693568455901334', name = 'Gold Streamer',   points = 30000  },
    { id = '1450669277186097203', name = 'Uye',             points = 500   }, -- bu rol id karakter onay için ama 1450669263051427943 rolünü de kontrol etmeli 
}
