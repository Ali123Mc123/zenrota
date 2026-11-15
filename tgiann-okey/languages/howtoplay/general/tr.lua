config.howtoplay = config.howtoplay or {}
config.howtoplay.tr = config.howtoplay.tr or {}
config.howtoplay.tr.general = {
    title = "Genel",
    summary = "Okey scriptinin temel kontrolleri ve taş yönetimi. Mod kuralları için sağdaki sekmelere geç.",
    sections = {
        {
            heading = "Tuşlar",
            body =
            "• E: Boş bir sandalyenin yanına gidip basınca oturursun.\n• X: Sandalyeden kalkarsın (oyun bitmeden kalkarsan turdan düşersin).\n• V: Kamera modunu değiştir: oyun kamerası ↔ oturma kamerası.\n• Caps Lock: Skor tablosunu aç/kapa.\n• I: Bu yardım panelini aç/kapa.\n• B: 101 modlarında yere açılan tüm per'leri gösteren paneli aç/kapa.\n• Boşluk (Space): 101 modlarında elinin uygun kombinasyonunu otomatik açmak için basılı tut.\n• R (yalnızca admin): Oyunu zorla sıfırlamak için basılı tut.",
        },
        {
            heading = "Taş Yönetimi",
            body =
            "• Sol Click + Sürükle: Tek taşı tut, başka bir slot/zone'a bırak.\n• Sağ Click: Hover'lanan kendi taşını ters/düz çevir (örn. okey taşını işaretlemek için).\n• Ctrl + Sol Click: Birden fazla taşı seç (mavi outline). Tekrar Ctrl + Click ile seçim kalkar.\n• Çoklu seçim sürükleme: 2+ taş seçiliyken sürükleyip kendi yere-indirme bölgendeki yeşil işaretçinin üzerine bırakırsan yeni bir per olarak açılır.",
        },
        {
            heading = "Atma & Çekme",
            body =
            "• Sıra sende olduğunda ya soldaki oyuncunun attığı son taşı al ya da ortadaki kapalı desteden (pool) çek.\n• Çekmek için ilgili taşa sol tıkla.\n• Atmak için elinden bir taşı tutup sağındaki köşeye (yeşil daire işareti) sürükle.",
        },
        {
            heading = "101'de İşleme",
            body =
            "• Elini açtıktan sonra (Boşluk) tek bir taşı sürükleyip yerdeki bir per'in üzerine getir. İşleme geçerliyse satırın taşları yeşil, geçersizse kırmızı outline ile parlar.\n• Yeşil parlayan per'in üzerine bırakırsan taş o pere işlenir.\n• Kendi per'lerine veya rakibinkilere işleyebilirsin (kuralları sağlıyorsa).",
        },
        {
            heading = "Okey Swap (Yerden Okey Alma)",
            body =
            "• Yerdeki bir per'de okey taşı varsa ve sende okeyin temsil ettiği gerçek taş varsa o taşı verip okey'i alabilirsin.\n• Per cyan (turkuaz) outline'la parlarsa swap geçerli demektir.\n• Drop ile swap: senin taşın per'e gider, okey eline gelir.\n• ÖNEMLİ: Okey'i aldığın tur içinde mutlaka bir per'e işlemen gerek. Okey işlenmeden HİÇBİR taş atamazsın (kendi okey'i atmak veya başka bir taş atmak, hepsi yasak). Tek çıkış yolu okey'i lay-off etmek.",
        },
        {
            heading = "Tepe Kamerası",
            body =
            "Bir taşı tutup masanın ortasına yaklaştırırsan kamera otomatik olarak tepeden bakacak şekilde geçer. Taşı bırakana kadar bu görünüm korunur, yere serili per'leri ve yığınları net görmek için.",
        },
    },
}
