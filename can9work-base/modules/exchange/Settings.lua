Settings.Exchange = {
    Peds = {
        {
            model = 's_m_m_security_01',
            coords = vec4(128.4692, -764.4308, 258.1516, 333.9356),
            scenario = 'WORLD_HUMAN_CLIPBOARD',
            target = {
                label = 'Takas Yap',
                icon = 'fas fa-exchange-alt',
                distance = 2.0
            },
            deals = {
                {
                    id = 'nightgale9_to_money',
                    label = 'PD Glock -> Para (Duruma Göre)',
                    description = '1 adet PD Glock silahını durumuna göre maksimum 20.000$ nakit karşılığında sat.',
                    duration = 1000,
                    scaleWithDurability = true,
                    requiredItems = {
                        { name = 'WEAPON_NIGHTGALE9', count = 1 }
                    },
                    rewardItems = {
                        { type = 'cash', name = 'black_money', count = 20000 }
                    }
                },
                {
                    id = 'jnp_combat_pistol_to_money',
                    label = 'PD Glock -> Para (Duruma Göre)',
                    description = '1 adet PD Glock silahını durumuna göre maksimum 40.000$ nakit karşılığında sat.',
                    duration = 1000,
                    scaleWithDurability = true,
                    requiredItems = {
                        { name = 'WEAPON_JNP_COMBAT_PISTOL', count = 1 }
                    },
                    rewardItems = {
                        { type = 'cash', name = 'black_money', count = 40000 }
                    }
                },
                {
                    id = 'grd6_blackspire_to_draco',
                    label = 'PD Grd6 Blackspire -> Draco',
                    description = '1 adet PD Grd6 Blackspire silahını aynı dayanıklılıkta (durability) 1 adet Draco ile takas et.',
                    duration = 1000,
                    transferDurability = true,
                    requiredItems = {
                        { name = 'WEAPON_GRD6_BLACKSPIRE_PD', count = 1 }
                    },
                    rewardItems = {
                        { name = 'WEAPON_DRACO_YELLOW_DRIP', count = 1 }
                    }
                },
                {
                    id = 'drone_lspd_to_drone',
                    label = 'LSPD Drone -> Drone',
                    description = '1 adet drone_lspd karşılığında 1 adet drone al.',
                    duration = 1000,
                    requiredItems = {
                        { name = 'drone_lspd', count = 1 }
                    },
                    rewardItems = {
                        { name = 'drone', count = 1 }
                    }
                },
                {
                    id = 'pd_medikit_to_medikit',
                    label = 'PD Medikit -> Medikit',
                    description = '3 adet pd_medikit karşılığında 1 adet medikit al.',
                    duration = 1000,
                    requiredItems = {
                        { name = 'pd_medikit', count = 3 }
                    },
                    rewardItems = {
                        { name = 'medikit', count = 1 }
                    }
                },
                {
                    id = 'pd_armour_to_armour',
                    label = 'PD Zırh -> Zırh',
                    description = '3 adet pd_armour karşılığında 1 adet armour al.',
                    duration = 1000,
                    requiredItems = {
                        { name = 'pd_armour', count = 3 }
                    },
                    rewardItems = {
                        { name = 'armour', count = 1 }
                    }
                },
                {
                    id = 'pdmermisi_to_ammo9',
                    label = 'PD Mermisi -> 9mm Mermi',
                    description = '3 adet pdmermisi karşılığında 1 adet ammo-9 al.',
                    duration = 1000,
                    requiredItems = {
                        { name = 'pdmermisi', count = 3 }
                    },
                    rewardItems = {
                        { name = 'ammo-9', count = 1 }
                    }
                },
                {
                    id = 'pd_redbull_to_redbull',
                    label = 'Polis Enerji İçeceği -> Enerji İçeceği',
                    description = '3 adet Polis Enerji İçeceği karşılığında 1 adet Enerji İçeceği al.',
                    duration = 1000,
                    requiredItems = {
                        { name = 'pd_redbull', count = 3 }
                    },
                    rewardItems = {
                        { name = 'redbull', count = 1 }
                    }
                }
            }
        },
    }
}
