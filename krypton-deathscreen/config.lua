Config = {}

Config.Framework = 'auto'

Config.Debug = false

Config.Locales = {
    laststand = {
        title       = 'Hareketsiz Durumdasın',
        description = 'Hareketsiz durumdasınız. Doktorların size ulaşmasını bekleyin yardım çağrısı gönderildi.',
        reportKey   = 'G'
    },

    dead = {
        title              = 'Bilincini Kaybettin',
        waitingDescription = 'Bilincinizi kaybettiniz. {key} tuşuna basarak doktorlara yardım çağrısı gönderebilirsiniz.',
        respawnDescription =
        'Süre doldu. {key} tuşuna {second} saniye basılı tutarak hastaneye gidin. Bu size 200$ mal olacak.',
        reportKey          = 'G',
        respawnKey         = 'E',
        second             = '5'
    }
}
