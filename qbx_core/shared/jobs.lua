---Job names must be lower case (top level table key)
---@type table<string, Job>
return {
    ['unemployed'] = {
        label = 'Sivil',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = {
                name = 'Sivil',
                payment = 50
            },
        },
    },

    ['ambulance'] = {
        label = 'EMS',
        type = 'ems',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0]  = { name = 'Stajyer', payment = 530 },
            [1]  = { name = 'Paramedik', payment = 580 },
            [2]  = { name = 'Hemşire', payment = 630 },
            [3]  = { name = 'Pratisyen Doktor', payment = 680 },
            [4]  = { name = 'Asistan Doktor', payment = 740 },
            [5]  = { name = 'Uzman Doktor', payment = 790 },
            [6]  = { name = 'Operatör Doktor', payment = 840 },
            [7]  = { name = 'Yardımcı Doçent Doktor', payment = 890 },
            [8]  = { name = 'Doçent Doktor', payment = 950 },
            [9]  = { name = 'Profesör Doktor', payment = 1000 },
            [10] = { name = 'Direktör', payment = 1050 },
            [11] = { name = 'Başhekim Yardımcısı', isboss = true, bankAuth = true, payment = 1100 },
            [12] = { name = 'Başhekim', isboss = true, bankAuth = true, payment = 1160 },
        },
    },

    ['police'] = {
        label = 'PD',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Trainer Officer', payment = 510 },
            [1] = { name = 'Officer 1', payment = 570 },
            [2] = { name = 'Officer 2', payment = 640 },
            [3] = { name = 'Officer 3', payment = 710 },
            [4] = { name = 'Detective 1', payment = 780 },
            [5] = { name = 'Officer 3 + 1', payment = 840 },
            [6] = { name = 'Detective 2', payment = 910 },
            [7] = { name = 'Sergeant', payment = 980 },
            [8] = { name = 'Detective 3', payment = 1050 },
            [9] = { name = 'Sergeant II', payment = 1110 },
            [10] = { name = 'Lieutenant', payment = 1180 },
            [11] = { name = 'Lieutenant II', payment = 1250 },
            [12] = { name = 'Deputy Captain', payment = 1320 },
            [13] = { name = 'Captain', payment = 1380 },
            [14] = { name = 'Commander', payment = 1450 },
            [15] = { name = 'Assistant Chief', payment = 1520 },
            [16] = { name = 'Deputy Chief', payment = 1590 },
            [17] = { name = 'Chief', isboss = true, bankAuth = true, payment = 1650 },
        },
    },

    ['sasp'] = {
        label = 'SASP',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Trainee Trooper', payment = 510 },
            [1] = { name = 'Trooper 1', payment = 570 },
            [2] = { name = 'Trooper 2', payment = 640 },
            [3] = { name = 'Trooper 3', payment = 710 },
            [4] = { name = 'Detective 1', payment = 780 },
            [5] = { name = 'Senior Trooper', payment = 840 },
            [6] = { name = 'Detective 2', payment = 910 },
            [7] = { name = 'Sergeant', payment = 980 },
            [8] = { name = 'Detective 3', payment = 1050 },
            [9] = { name = 'Sergeant II', payment = 1110 },
            [10] = { name = 'Lieutenant', payment = 1180 },
            [11] = { name = 'Lieutenant II', payment = 1250 },
            [12] = { name = 'Deputy Captain', payment = 1320 },
            [13] = { name = 'Captain', payment = 1380 },
            [14] = { name = 'Commander', payment = 1450 },
            [15] = { name = 'Assistant Chief', payment = 1520 },
            [16] = { name = 'Deputy Chief', payment = 1590 },
            [17] = { name = 'Chief', isboss = true, bankAuth = true, payment = 1650 },
        },
    },

    ['pbsd'] = {
        label = "PBSD",
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Trainee Deputy', payment = 510 },
            [1] = { name = 'Deputy 1', payment = 570 },
            [2] = { name = 'Deputy 2', payment = 640 },
            [3] = { name = 'Deputy 3', payment = 710 },
            [4] = { name = 'Detective 1', payment = 780 },
            [5] = { name = 'Senior Deputy', payment = 840 },
            [6] = { name = 'Detective 2', payment = 910 },
            [7] = { name = 'Sergeant', payment = 980 },
            [8] = { name = 'Detective 3', payment = 1050 },
            [9] = { name = 'Sergeant II', payment = 1110 },
            [10] = { name = 'Lieutenant', payment = 1180 },
            [11] = { name = 'Lieutenant II', payment = 1250 },
            [12] = { name = 'Deputy Captain', payment = 1320 },
            [13] = { name = 'Captain', payment = 1380 },
            [14] = { name = 'Commander', payment = 1450 },
            [15] = { name = 'Assistant Sheriff', payment = 1520 },
            [16] = { name = 'Deputy Sheriff', payment = 1590 },
            [17] = { name = 'Sheriff', isboss = true, bankAuth = true, payment = 1650 },
        },
    },

    ['cppd'] = {
        label = 'CPPD',
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Trainer Officer', payment = 510 },
            [1] = { name = 'Officer 1', payment = 570 },
            [2] = { name = 'Officer 2', payment = 640 },
            [3] = { name = 'Officer 3', payment = 710 },
            [4] = { name = 'Detective 1', payment = 780 },
            [5] = { name = 'Officer 3 + 1', payment = 840 },
            [6] = { name = 'Detective 2', payment = 910 },
            [7] = { name = 'Sergeant', payment = 980 },
            [8] = { name = 'Detective 3', payment = 1050 },
            [9] = { name = 'Sergeant II', payment = 1110 },
            [10] = { name = 'Lieutenant', payment = 1180 },
            [11] = { name = 'Lieutenant II', payment = 1250 },
            [12] = { name = 'Deputy Captain', payment = 1320 },
            [13] = { name = 'Captain', payment = 1380 },
            [14] = { name = 'Commander', payment = 1450 },
            [15] = { name = 'Assistant Chief', payment = 1520 },
            [16] = { name = 'Deputy Chief', payment = 1590 },
            [17] = { name = 'Chief', isboss = true, bankAuth = true, payment = 1650 },
        },
    },

    -- ['dp'] = {
    --     label = "DP",
    --     type = 'leo',
    --     defaultDuty = true,
    --     offDutyPay = false,
    --     grades = {
    --         [0] = { name = 'Cadet', payment = 510 },
    --         [1] = { name = 'Deputy I', payment = 570 },
    --         [2] = { name = 'Deputy II', payment = 640 },
    --         [3] = { name = 'Deputy III', payment = 710 },
    --         [4] = { name = 'Detective I', payment = 780 },
    --         [5] = { name = 'Senior Deputy', payment = 840 },
    --         [6] = { name = 'Detective II', payment = 910 },
    --         [7] = { name = 'Sergeant I', payment = 980 },
    --         [8] = { name = 'Detective III', payment = 1050 },
    --         [9] = { name = 'Sergeant II', payment = 1110 },
    --         [10] = { name = 'Lieutenant I', payment = 1180 },
    --         [11] = { name = 'Lieutenant II', payment = 1250 },
    --         [12] = { name = 'Deputy Captain', payment = 1320 },
    --         [13] = { name = 'Captain', payment = 1380 },
    --         [14] = { name = 'Commander', payment = 1450 },
    --         [15] = { name = 'Assistant Sheriff', payment = 1520 },
    --         [16] = { name = 'Undersheriff', payment = 1590 },
    --         [17] = { name = 'Sheriff', isboss = true, bankAuth = true, payment = 1650 },
    --     },
    -- },

    ['sapr'] = {
        label = "SAPR",
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Trainee Ranger', payment = 510 },
            [1] = { name = 'Ranger 1', payment = 640 },
            [2] = { name = 'Ranger 2', payment = 780 },
            [3] = { name = 'Ranger 3', payment = 910 },
            [4] = { name = 'Detective 1', payment = 1050 },
            [5] = { name = 'Senior Ranger', payment = 1110 },
            [6] = { name = 'Corporal', payment = 1180 },
            [7] = { name = 'Detective 2', payment = 1250 },
            [8] = { name = 'Master Corporal', payment = 1320 },
            [9] = { name = 'Sergeant', payment = 1380 },
            [10] = { name = 'Detective 3', payment = 1450 },
            [11] = { name = 'Sergeant 2', payment = 1520 },
            [12] = { name = 'Lieutenant', payment = 1590 },
            [13] = { name = 'Lieutenant 2', payment = 1650 },
            [14] = { name = 'Deputy Captain', payment = 1720 },
            [15] = { name = 'Captain', payment = 1790 },
            [16] = { name = 'Commander', payment = 1860, isboss = true, bankAuth = true },
            [17] = { name = 'Assistant Chief', payment = 1920, isboss = true, bankAuth = true },
            [18] = { name = 'Deputy Chief', payment = 1990, isboss = true, bankAuth = true },
            [19] = { name = 'Chief', payment = 2060, isboss = true, bankAuth = true },
        },
    },

    ['bcso'] = {
        label = "SD",
        type = 'leo',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Trainee Deputy', payment = 510 },
            [1] = { name = 'Deputy 1', payment = 570 },
            [2] = { name = 'Deputy 2', payment = 640 },
            [3] = { name = 'Deputy 3', payment = 710 },
            [4] = { name = 'Detective 1', payment = 780 },
            [5] = { name = 'Senior Deputy', payment = 840 },
            [6] = { name = 'Detective 2', payment = 910 },
            [7] = { name = 'Sergeant', payment = 980 },
            [8] = { name = 'Detective 3', payment = 1050 },
            [9] = { name = 'Sergeant II', payment = 1110 },
            [10] = { name = 'Lieutenant', payment = 1180 },
            [11] = { name = 'Lieutenant II', payment = 1250 },
            [12] = { name = 'Deputy Captain', payment = 1320 },
            [13] = { name = 'Captain', payment = 1380 },
            [14] = { name = 'Commander', payment = 1450 },
            [15] = { name = 'Assistant Sheriff', isboss = true, bankAuth = true, payment = 1520 },
            [16] = { name = 'Deputy Sheriff', isboss = true, bankAuth = true,payment = 1590 },
            [17] = { name = 'Sheriff', isboss = true, bankAuth = true, payment = 1650 },
        },
    },

    ['doj'] = {
        label = 'DOJ',
        type = 'doj',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Stajyer', payment = 270 },
            [1] = { name = 'Hukuk Asistanı (Paralegal)', payment = 305 },
            [2] = { name = 'Yardımcı Avukat', payment = 340 },
            [3] = { name = 'Avukat', payment = 370 },
            [4] = { name = 'Yardımcı Bölge Savcısı', payment = 405 },
            [5] = { name = 'Soruşturmacı (Müfettiş)', payment = 440 },
            [6] = { name = 'Dedektif', payment = 440 },
            [7] = { name = 'Özel Kalem Asistanı', payment = 475 },
            [8] = { name = 'Yardımcı Hakim', payment = 505 },
            [9] = { name = 'Avukat Temsilcisi', payment = 540 },
            [10] = { name = 'Baş Soruşturmacı', payment = 575 },
            [11] = { name = 'İdari İşler Müdürü', payment = 610 },
            [12] = { name = 'Hakim', payment = 640 },
            [13] = { name = 'Bölge Savcısı', payment = 675, isboss = true, bankAuth = true },
        },
    },

    ['mekanik1'] = {
        label = 'Mekanik 1',
        type = 'mechanic',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Kalfa', payment = 50},
            [2] = { name = 'Usta', payment = 50},
            [3] = { name = 'Müdür', payment = 50},
            [4] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['mekanik2'] = {
        label = 'Mekanik 2',
        type = 'mechanic',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Kalfa', payment = 50},
            [2] = { name = 'Usta', payment = 50},
            [3] = { name = 'Müdür', payment = 50},
            [4] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['mekanik3'] = {
        label = "Mekanik 3",
        type = 'mechanic',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Kalfa', payment = 50},
            [2] = { name = 'Usta', payment = 50},
            [3] = { name = 'Müdür', payment = 50},
            [4] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['mekanik4'] = {
        label = 'Mekanik 4',
        type = 'mechanic',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Kalfa', payment = 50},
            [2] = { name = 'Usta', payment = 50},
            [3] = { name = 'Müdür', payment = 50},
            [4] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['mekanik5'] = {
        label = 'Mekanik 5',
        type = 'mechanic',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Kalfa', payment = 50},
            [2] = { name = 'Usta', payment = 50},
            [3] = { name = 'Müdür', payment = 50},
            [4] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['mekanik6'] = {
        label = 'Mekanik 6',
        type = 'mechanic',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Kalfa', payment = 50},
            [2] = { name = 'Usta', payment = 50},
            [3] = { name = 'Müdür', payment = 50},
            [4] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['mekanik7'] = {
        label = 'Mekanik 7',
        type = 'mechanic',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Kalfa', payment = 50},
            [2] = { name = 'Usta', payment = 50},
            [3] = { name = 'Müdür', payment = 50},
            [4] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['mekanik8'] = {
        label = 'Mekanik 8',
        type = 'mechanic',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Kalfa', payment = 50},
            [2] = { name = 'Usta', payment = 50},
            [3] = { name = 'Müdür', payment = 50},
            [4] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['illegalmekanik1'] = {
        label = 'AfterLife Mekanik',
        type = 'illegalmekanik',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Kalfa', payment = 50},
            [2] = { name = 'Usta', payment = 50},
            [3] = { name = 'Müdür', payment = 50},
            [4] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['illegalmekanik2'] = {
        label = 'Bunker Mekanik',
        type = 'illegalmekanik',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Kalfa', payment = 50},
            [2] = { name = 'Usta', payment = 50},
            [3] = { name = 'Müdür', payment = 50},
            [4] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['dovmeci1'] = {
        label = 'Dövmeci 1',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['dovmeci2'] = {
        label = 'Dövmeci 2',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['dovmeci3'] = {
        label = 'Dövmeci 3',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['dovmeci4'] = {
        label = 'Dövmeci 4',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['dovmeci5'] = {
        label = 'Dövmeci 5',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['dovmeci6'] = {
        label = 'Dövmeci 6',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['dovmeci7'] = {
        label = 'Dövmeci 7',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['nailart1'] = {
        label = 'Nail Art 1',
        defaultDuty = false,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Manikürcü', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['cardealer'] = {
        label = 'PDM',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },


    ['cardealer2'] = {
        label = 'Auto Luxury',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },


    ['blackmarket1'] = {
        label = 'Blackmarket 1',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['blackmarket2'] = {
        label = 'Blackmarket 2',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['gunshop1'] = {
        label = 'Gunshop 1',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['gunshop2'] = {
        label = 'Gunshop 2',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['gunshop3'] = {
        label = 'Gunshop 3',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['gunshop4'] = {
        label = 'Gunshop 4',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['gunshop5'] = {
        label = 'Gunshop 5',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['gunshop6'] = {
        label = 'Gunshop 6',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },


    ['news'] = {
        label = 'News',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Stajyer', payment = 50},
            [1] = { name = 'Muhabir', payment = 50},
            [2] = { name = 'Editör', payment = 50},
            [3] = { name = 'Müdür', payment = 50},
            [4] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['lojistik1'] = {
        label = 'Lojistik 1',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['lojistik2'] = {
        label = 'Lojistik 2',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['pawnshop1'] = {
        label = 'Pawnshop 1',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['pawnshop2'] = {
        label = 'Pawnshop 2',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['kalpazan1'] = {
        label = 'Kalpazan 1',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['kalpazan2'] = {
        label = 'Kalpazan 2',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', isboss = true, payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['kalpazan3'] = {
        label = 'Kalpazan 3',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['kalpazan4'] = {
        label = 'Kalpazan 4',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['tacir1'] = {
        label = 'Tacir 1',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['tacir2'] = {
        label = 'Tacir 2',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['tacir3'] = {
        label = 'Tacir 3',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['tacir4'] = {
        label = 'Tacir 4',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['torbaci1'] = {
        label = 'Torbaci 1',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['torbaci2'] = {
        label = 'Torbaci 2',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['torbaci3'] = {
        label = 'Torbaci 3',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['torbaci4'] = {
        label = 'Torbaci 4',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['emlakci1'] = {
        label = 'Emlakci 1',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['emlakci2'] = {
        label = 'Emlakci 2',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['weedshop1'] = {
        label = 'Weedshop 1',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['weedshop2'] = {
        label = 'Weedshop 2',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50},
            [1] = { name = 'Usta', payment = 50},
            [2] = { name = 'Müdür', payment = 50},
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50},
        },
    },

    ['weedcamp'] = {
        label = 'Weedcamp',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Çırak', payment = 50 },
            [1] = { name = 'Usta', payment = 50 },
            [2] = { name = 'Müdür', payment = 50 },
            [3] = { name = 'Patron', isboss = true, bankAuth = true, payment = 50 },
        },
    },

    ['ogrenci'] = {
        label = 'Öğrenci',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Öğrenci', payment = 0 },
        },
    },

    -- Grade sirasi daddy_college/config/main.lua -> Config.Lessons ile ayni (13 aktif ders, 2026-11-08).
    -- Grade[0] brans atanmamis ogretmenler icin; [1..13] ders unvani (kolej karti ve mudur paneli bunu okur).
    ['ogretmen'] = {
        label = 'Öğretmen',
        type = 'college',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Öğretmen', payment = 1000 },
            [1] = { name = 'Müzik Öğretmeni', payment = 1000 },
            [2] = { name = 'Resim Öğretmeni', payment = 1000 },
            [3] = { name = 'Dans Öğretmeni', payment = 1000 },
            [4] = { name = 'Beden Eğitimi Öğretmeni', payment = 1000 },
            [5] = { name = 'Yazılım Öğretmeni', payment = 1000 },
            [6] = { name = 'Aşçılık Öğretmeni', payment = 1000 },
            [7] = { name = 'Mekanik Öğretmeni', payment = 1000 },
            [8] = { name = 'Gazetecilik Öğretmeni', payment = 1000 },
            [9] = { name = 'Hukuk Öğretmeni', payment = 1000 },
            [10] = { name = 'Sağlık Öğretmeni', payment = 1000 },
            [11] = { name = 'Polislik Öğretmeni', payment = 1000 },
            [12] = { name = 'Almanca Öğretmeni', payment = 1000 },
            [13] = { name = 'Biyoloji Öğretmeni', payment = 1000 },
        },
    },

    ['okulmuduru'] = {
        label = 'Okul İdaresi',
        type = 'college',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Personel', payment = 850 },
            [1] = { name = 'Müdür Yardımcısı', payment = 1200 },
            [2] = { name = 'Müdür', isboss = true, bankAuth = true, payment = 1500 },
        },
    },

    -- School services: canteen and janitor are one job; the name stays 'kantin' (can9work business, doors, multichar).
    -- Enrolled students work it at grade 0 only (daddy_college enforces it).
    ['kantin'] = {
        label = 'Kantin ve Temizlik',
        type = 'college',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Stajyer Kantinci', payment = 150 },
            [1] = { name = 'Kantin ve Temizlik Görevlisi', payment = 750 },
            [2] = { name = 'Kantin Şefi', isboss = true, bankAuth = true, payment = 900 },
        },
    },

    ['servis'] = {
        label = 'Kolej Servisi',
        type = 'college',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Stajyer Şoför', payment = 200 },
            [1] = { name = 'Servis Şoförü', payment = 200 },
            [2] = { name = 'Baş Şoför', isboss = true, bankAuth = true, payment = 200 },
        },
    },

    ['guvenlik'] = {
        label = 'Okul Güvenliği',
        type = 'college',
        defaultDuty = true,
        offDutyPay = false,
        grades = {
            [0] = { name = 'Güvenlik Görevlisi', payment = 750 },
            [1] = { name = 'Kıdemli Güvenlik', payment = 750 },
            [2] = { name = 'Güvenlik Amiri', isboss = true, bankAuth = true, payment = 750 },
        },
    },

}
