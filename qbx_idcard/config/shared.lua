return {

    idCardSettings = {
        closeKey = 'Backspace',
        autoClose = {
            status = false, -- or true
            time = 3000
        }
    },

    licenses = {
        ['id_card'] = {
            header = 'Kimlik Kartı',
            background = '#ebf7fd',
            backgroundImage = 'https://i.ibb.co/vxvGzg1/card.png',
            prop = 'prop_franklin_dl'
        },
        ['driver_license'] = {
            header = 'Sürücü Belgesi',
            background = '#febbbb',
            backgroundImage = 'https://i.ibb.co/vxvGzg1/card.png',
            prop = 'prop_franklin_dl',
        },
        ['weaponlicense'] = {
            header = 'Silah Ruhsatı',
            background = '#c7ffe5',
            backgroundImage = 'https://i.ibb.co/vxvGzg1/card.png',
            prop = 'prop_franklin_dl',
        },
        ['lawyerpass'] = {
            header = 'Avukat Kartı',
            background = '#f9c491',
            backgroundImage = 'https://i.ibb.co/vxvGzg1/card.png',
            prop = 'prop_cs_r_business_card'
        }
    }
}