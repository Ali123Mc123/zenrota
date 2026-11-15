Settings = {
    AdminGroups = {
        "admin",
        "god"
    },

    Database = {
        Tables = {
            { name = "players",                  column = "citizenid" },
            { name = "playerskins",              column = "citizenid" },
            -- { name = "no1_playerpeds",           column = "identifier" },
            { name = "player_vehicles",          column = "citizenid" },
            { name = "player_outfits",           column = "citizenid" },
            { name = "playerskins",              column = "citizenid" },
            -- nn_banking (Daddy Bank): owner / identifier = citizenid
            { name = "nn_players",               column = "identifier" },
            { name = "nn_accounts",              column = "owner" },
            { name = "nn_account_members",       column = "identifier" },
            { name = "nn_savings",               column = "owner" },
            { name = "nn_loans",                 column = "owner" },
            { name = "nn_bills",                 column = "owner" },
            { name = "nn_contacts",              column = "owner" },
            { name = "nn_stock_holdings",        column = "owner" },
            -- BakiTelli_paintballv2 (escrow): identifier format not visible, tried as citizenid and license
            { name = "debux_paintball",          column = "identifier",         identifierType = "license" },
            { name = "savana_fuel",              column = "identifier",         identifierType = "license" },
            { name = "can9work_auction_list",    column = "winner_identifier" },
            { name = "can9work_auction_bids",    column = "identifier" },
            { name = "can9work_auction_logs",    column = "identifier" },
            { name = "can9work_carwash",         column = "citizenid" },
            -- daddy_venue (staff, customers) and daddy_bills (bills sent and received); a business itself stays, an admin hands it over
            { name = "daddy_members",            column = "identifier" },
            { name = "daddy_duty",               column = "identifier" },
            { name = "daddy_loyalty",            column = "identifier" },
            { name = "daddy_reviews",            column = "customer_id" },
            { name = "daddy_applications",       column = "identifier" },
            { name = "daddy_bills_bills",        column = "sender_id" },
            { name = "daddy_bills_bills",        column = "target_id" },
            { name = "cloud_shop_data",          column = "owner_identifier" },
            { name = "izzy_motels",              column = "identifier" },
            -- { name = "daddy_scenes",             column = "creator" },
            -- { name = "daddy_scenes_log",         column = "actor" },
        },
    },

    Webhook = {
        Enabled = true,
        Color = 16711680,
        Title = "Karakter Silme İşlemi",
    },

    Archive = {
        Enabled = true,
        FileName = "data/archives.json", -- Tüm yedeklerin tutulacağı dosya
        RetentionDays = 14,              -- Kaç gün saklanacak
    },

    MassCK = {
        Enabled = true,
        Permission = "god",
        MaxLimit = 10,
        AuthorizedDiscordIDs = {
            "699334583660970077",
        }
    },

    Notifications = {
        NoPermission = "Bu komutu kullanma yetkiniz yok!",
        NoPermissionMass = "Toplu CK atma yetkiniz yok!",
        LimitExceeded = "Tek seferde en fazla %d kişi silebilirsiniz!",
        PlayerNotFound = "Belirtilen ID veya Discord ID'de oyuncu bulunamadı!",
        Success = "Karakter başarıyla silindi!",
        MassSuccess = "%d karakter başarıyla silindi!",
        Cancelled = "İşlem iptal edildi.",
        ConfirmTitle = "Karakter Silme Onayı",
        ConfirmDescription = "Bu oyuncunun karakterini silmek istediğinizden emin misiniz?",
        MassConfirmTitle = "Toplu Karakter Silme Onayı",
    }
}
