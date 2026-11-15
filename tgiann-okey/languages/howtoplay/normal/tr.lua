config.howtoplay = config.howtoplay or {}
config.howtoplay.tr = config.howtoplay.tr or {}
config.howtoplay.tr.normal = {
    title = "Normal Okey",
    summary = "Klasik Türk Okeyi. Her oyuncu 20 puanla başlar; eli ilk bitiren turu kazanır, kaybedenlerin puanı düşer.",
    sections = {
        {
            heading = "Amaç",
            body = "Elindeki 14 taşı geçerli per'lerden (üçlü/dörtlü grup veya seri) oluşturup 15. taşı yere atarak biten ilk oyuncu olmak.",
        },
        {
            heading = "Per Türleri",
            body = "Seri: aynı renkten ardışık 3+ taş (örn. kırmızı 5-6-7). Grup: farklı renklerden aynı sayı 3 veya 4 taş. Okey taşı eksik bir taşın yerine joker olarak kullanılabilir.",
        },
        {
            heading = "Tur Akışı",
            body = "Sıra sende: ya soldaki oyuncunun attığı son taşı al ya da desteden çek. Sonra elinden bir taş seçip sağa at. Sıra sağdaki oyuncuya geçer.",
        },
        {
            heading = "Bitiş Türleri",
            body = "• Normal bitiş: rakipler -2\n• Okey atarak bitiş: rakipler -4\n• Çifte bitiş (7 çift): rakipler -4\n• Çifte gidip okey atarak bitiş: rakipler -8",
        },
        {
            heading = "Puanlama",
            body = "Tüm oyuncular 20 puanla başlar. Tur kazananın puanı sabit kalır, kaybedenlerin puanı bitiş türüne göre düşer. 0 veya altına inen oyuncu elenir. Göstergenin aynısı ilk dağıtımda sana geldiyse ilk taşını atmadan önce gösterge tuşuyla gösterebilirsin, rakiplerin 1 puan kaybeder. Deste biterse el berabere biter, puan değişmez.",
        },
    },
}
