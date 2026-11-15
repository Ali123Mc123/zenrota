return {
   ---@class Currency
   ---@field symbol string
   Currency = {
      symbol = '$',
   },

   ---@type MarketStore[]
   Store = {
      {
         name = 'fishing_rod_one',
         label = '1. Seviye Olta',
         type = 'Rod',
         image = 'fishing_rod_one.png',
         price = 20,
         level = 1,
         quality = 'common'
      },
      {
         name = 'worm_fish_bait',
         label = 'Solucan Yem',
         type = 'Bait',
         image = 'worm_fish_bait.png',
         price = 2,
         level = 1,
         quality = 'common'
      },
      {
         name = 'simple_fish_bait',
         label = 'Basit Yem',
         type = 'Bait',
         image = 'simple_fish_bait.png',
         price = 1,
         level = 1,
         quality = 'common'
      },
      {
         name = 'illegal_fish_bait',
         label = 'Yasa Dışı Yem',
         type = 'Bait',
         image = 'illegal_fish_bait.png',
         price = 2,
         level = 1,
         quality = 'common'
      },
      -- {
      --    name = 'diving_cloth',
      --    label = 'Dalış Kıyafeti',
      --    type = 'Diving Cloth',
      --    image = 'diving_cloth.png',
      --    price = 10,
      --    level = 1,
      --    quality = 'eco'
      -- },
      {
         name = 'diving_gear',
         label = 'Dalış Ekipmanı',
         type = 'Diving Gear',
         image = 'diving_gear.png',
         price = 10,
         level = 1,
         quality = 'rare'
      },
      {
         name = 'diving_fill',
         label = 'Dalış Tüpü',
         type = 'Diving Fill',
         image = 'diving_fill.png',
         price = 10,
         level = 1,
         quality = 'rare'
      },
      {
         name = 'lucky_hat',
         label = 'Şanslı Şapka',
         type = 'Lucky Hat',
         image = 'lucky_hat.png',
         price = 200,
         level = 1,
         quality = 'rare'
      },
      {
         name = 'anchor',
         label = 'Çapa',
         type = 'Anchor',
         image = 'anchor.png',
         price = 10,
         level = 1,
         quality = 'common'
      },
   },

    ---@type MarketSell[]
    Sell = {
       {
          name = 'bass',
          label = 'Levrek',
          type = 'Fish',
          image = 'bass.png',
          price = 15,
          level = 1,
          rodLevel = 1,
          quality = 'common'
       },
       {
          name = 'bluegill',
          label = 'Güneş Balığı',
          type = 'Fish',
          image = 'bluegill.png',
          price = 20,
          level = 1,
          rodLevel = 1,
          quality = 'common'
       },
       {
          name = 'common_carp',
          label = 'Sazan',
          type = 'Fish',
          image = 'common_carp.png',
          price = 22,
          level = 2,
          rodLevel = 1,
          quality = 'eco'
       },
       {
          name = 'nothern_pike',
          label = 'Kuzey Turnası',
          type = 'Fish',
          image = 'nothern_pike.png',
          price = 25,
          level = 2,
          rodLevel = 2,
          quality = 'eco'
       },
       {
          name = 'perch',
          label = 'Tatlısu Levreği',
          type = 'Fish',
          image = 'perch.png',
          price = 30,
          level = 3,
          rodLevel = 2,
          quality = 'eco'
       },
       {
          name = 'rainbow_trout',
          label = 'Gökkuşağı Alabalığı',
          type = 'Fish',
          image = 'rainbow_trout.png',
          price = 32,
          level = 3,
          rodLevel = 2,
          quality = 'eco'
       },
       {
          name = 'redfin_pickerel',
          label = 'Kızıl Turna',
          type = 'Fish',
          image = 'redfin_pickerel.png',
          price = 35,
          level = 4,
          rodLevel = 3,
          quality = 'rare'
       },
       {
          name = 'rock_bass',
          label = 'Kaya Levreği',
          type = 'Fish',
          image = 'rock_bass.png',
          price = 40,
          level = 4,
          rodLevel = 3,
          quality = 'rare'
       },
       {
          name = 'small_trout',
          label = 'Küçük Alabalık',
          type = 'Fish',
          image = 'small_trout.png',
          price = 42,
          level = 5,
          rodLevel = 3,
          quality = 'rare'
       },
       {
          name = 'smallmouth_bass',
          label = 'Küçük Ağızlı Levrek',
          type = 'Fish',
          image = 'smallmouth_bass.png',
          price = 47,
          level = 5,
          rodLevel = 4,
          quality = 'epic'
       },
       {
          name = 'sockeye_salmon',
          label = 'Kırmızı Somon',
          type = 'Fish',
          image = 'sockeye_salmon.png',
          price = 52,
          level = 6,
          rodLevel = 4,
          quality = 'epic'
       },
       {
          name = 'trout',
          label = 'Alabalık',
          type = 'Fish',
          image = 'trout.png',
          price = 55,
          level = 6,
          rodLevel = 4,
          quality = 'epic'
       },
       {
          name = 'whitefish',
          label = 'Beyaz Balık',
          type = 'Fish',
          image = 'whitefish.png',
          price = 57,
          level = 7,
          rodLevel = 5,
          quality = 'epic'
       },

       {
          name = 'redpearl',
          label = 'Kırmızı İnci',
          type = 'LuckyItem',
          image = 'redpearl.png',
          price = 80,
          level = 1,
          rodLevel = 0,
          quality = 'epic'
       },
       {
          name = 'bluepearl',
          label = 'Mavi İnci',
          type = 'LuckyItem',
          image = 'bluepearl.png',
          price = 80,
          level = 1,
          rodLevel = 0,
          quality = 'epic'
       },
       {
          name = 'yellowpearl',
          label = 'Sarı İnci',
          type = 'LuckyItem',
          image = 'yellowpearl.png',
          price = 80,
          level = 1,
          rodLevel = 0,
          quality = 'epic'
       },
       {
          name = 'greenpearl',
          label = 'Yeşil İnci',
          type = 'LuckyItem',
          image = 'greenpearl.png',
          price = 80,
          level = 1,
          rodLevel = 0,
          quality = 'epic'
       },
       {
          name = 'green_crab',
          label = 'Yeşil Yengeç',
          type = 'LuckyItem',
          image = 'green_crab.png',
          price = 80,
          level = 1,
          rodLevel = 0,
          quality = 'rare'
       },
       {
          name = 'red_crab',
          label = 'Kırmızı Yengeç',
          type = 'LuckyItem',
          image = 'red_crab.png',
          price = 80,
          level = 1,
          rodLevel = 0,
          quality = 'rare'
       },
       {
          name = 'blue_crab',
          label = 'Mavi Yengeç',
          type = 'LuckyItem',
          image = 'blue_crab.png',
          price = 80,
          level = 1,
          rodLevel = 0,
          quality = 'rare'
       },
       {
          name = 'king_crab',
          label = 'Kral Yengeç',
          type = 'LuckyItem',
          image = 'king_crab.png',
          price = 80,
          level = 1,
          rodLevel = 0,
          quality = 'epic'
       },
       {
          name = 'trash_can',
          label = 'Çöp Kutusu',
          type = 'Trash',
          image = 'trash_can.png',
          price = 3,
          level = 1,
          rodLevel = 0,
          quality = 'common'
       },
       {
          name = 'trash_chips',
          label = 'Çöp Cips Paketi',
          type = 'Trash',
          image = 'trash_chips.png',
          price = 3,
          level = 1,
          rodLevel = 0,
          quality = 'common'
       },
       {
          name = 'trash_burger',
          label = 'Çöp Hamburger',
          type = 'Trash',
          image = 'trash_burger.png',
          price = 3,
          level = 1,
          rodLevel = 0,
          quality = 'common'
       }
    }
}
