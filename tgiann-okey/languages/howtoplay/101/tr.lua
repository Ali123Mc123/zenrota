config.howtoplay = config.howtoplay or {}
config.howtoplay.tr = config.howtoplay.tr or {}
config.howtoplay.tr["101"] = {
    title = "101 Okey",
    summary = "Türk Okey'in puan-bazlı versiyonu. Eli açmak için en az 101 puan değerinde per indirmen gerekir.",
    sections = {
        {
            heading = "Açma Kuralı",
            body = "Eli açmak için yere bir defada en az 101 puanlık seri/grup indirmen gerekir. Ya da en az 5 farklı çift indirip 'çift açma' yapabilirsin.",
        },
        {
            heading = "Per Puanları",
            body = "Per puanı = içindeki taşların sayı değerlerinin toplamı. Okey ve sahte joker, yerine geçtiği taşın değerini alır. Örn: kırmızı 11-12-13 = 36 puan.",
        },
        {
            heading = "Soldan Alma",
            body = "Soldaki oyuncunun attığı taşı alabilirsin. Henüz açmadıysan o tur elini açmak zorundasın; açmadan atmaya kalkarsan taş geri konur ve +101 ceza yazılır.",
        },
        {
            heading = "Lay-off (İşleme)",
            body = "Açtıktan sonra elindeki taşları yerdeki perlere ekleyebilirsin. Aynı turda aynı per'e en fazla 2 taş işleyebilirsin. Elini işleyerek boşaltamazsın, son taşını atarak bitersin.",
        },
        {
            heading = "İşlek Cezası",
            body = "Yerde işlenebilecek bir taşı yere atarsan +101 ceza yersin. Okey taşını atmak da +101 cezadır, son taşın okeyse ve onunla bitiyorsan ceza yok.",
        },
        {
            heading = "Puanlama",
            body = "Biten oyuncu -101 yazar. Açmış kaybedenlere elde kalan taşların toplamı, hiç açmamışlara 202 yazılır. Çift açıp kaybedenin cezası 2 katıdır. Okey atarak, çiftten ya da elden (hiç açmadan tek seferde) bitişte tüm puanlar 2 katı, ikisi birden olursa 4 katı yazılır. Deste biterse kazanan olmaz: açanlar elindekini, açmayanlar 202 yazar. Düşük puan iyidir.",
        },
    },
}
