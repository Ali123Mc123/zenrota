config.howtoplay = config.howtoplay or {}
config.howtoplay.tr = config.howtoplay.tr or {}
config.howtoplay.tr.doubled_101 = {
    title = "Katlamalı 101",
    summary = "101 Okey'in artan barajlı versiyonu. Her açılışta sonraki oyuncuların açma barajı yükselir.",
    sections = {
        {
            heading = "Temel Kurallar",
            body = "Tüm 101 Okey kuralları geçerlidir: açma, lay-off, soldan alma, işlek cezası. Tek fark açma barajının dinamik olmasıdır.",
        },
        {
            heading = "Dinamik Açma Barajı",
            body = "Seri/grup açma barajı 101 ile başlar. Biri açınca yeni baraj onun puanının 1 fazlası olur, sonraki açacak oyuncu onu geçmek zorundadır.",
        },
        {
            heading = "Çift Açma Barajı",
            body = "Çift açma barajı 5 çift ile başlar. Biri çift açınca sonraki çift açacak oyuncu en az 1 çift fazla açmalıdır.",
        },
        {
            heading = "Strateji",
            body = "Erken açmak avantajlıdır çünkü sonraki rakipler daha zor bir baraja takılır. Ancak elindeki taşlarla daha yüksek puana ulaşamayacaksan çift açma yolunu denemelisin.",
        },
        {
            heading = "Puanlama",
            body = "101 ile aynı. Biten oyuncu -101 yazar. Açmış kaybedenlere elde kalan taşların toplamı, hiç açmamışlara 202 yazılır. Çift açıp kaybedenin cezası 2 katıdır. Okey atarak, çiftten ya da elden (hiç açmadan tek seferde) bitişte tüm puanlar 2 katı, ikisi birden olursa 4 katı yazılır. Deste biterse kazanan olmaz: açanlar elindekini, açmayanlar 202 yazar. Düşük puan iyidir.",
        },
    },
}
