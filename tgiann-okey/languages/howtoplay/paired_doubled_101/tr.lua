config.howtoplay = config.howtoplay or {}
config.howtoplay.tr = config.howtoplay.tr or {}
config.howtoplay.tr.paired_doubled_101 = {
    title = "Eşli Katlamalı 101",
    summary = "Eşli 101 + Katlamalı 101 birleşimi. Hem 2'ye 2 takım hem de açma barajı dinamik.",
    sections = {
        {
            heading = "Takımlar",
            body = "Koltuk 1 ve 3 → Takım A. Koltuk 2 ve 4 → Takım B. 4 koltuk dolu olmadan oyun başlamaz.",
        },
        {
            heading = "Dinamik Açma Barajı",
            body = "Seri/grup açma barajı 101 ile başlar; bir oyuncu açtıkça baraj artar. Çift açma barajı 5 ile başlar ve aynı şekilde yükselir. Açılış bireyseldir.",
        },
        {
            heading = "Lay-off",
            body = "Açıldıktan sonra herkesin yere indirdiği perlere taş ekleyebilirsin. Aynı turda aynı per'e en fazla 2 taş.",
        },
        {
            heading = "Bitiş ve Puanlama",
            body = "Takımdan biri bitince takım kazanır ve eşi ceza yazmaz. Kaybeden takımın iki oyuncusunun cezaları toplanıp takım puanına yazılır. Çarpanlar 101 ile aynıdır. İşlek ve okey atma gibi oyun içi cezalar da takımın ortak puanına yazılır.",
        },
        {
            heading = "Strateji",
            body = "Erken açmak hem rakipleri zorlar hem partnerin baskısını azaltır. Ancak partnerin henüz açmadıysa, ona zarar verecek taşlar atmaktan kaçın.",
        },
    },
}
