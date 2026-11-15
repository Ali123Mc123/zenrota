return {
   ---@type FishingRod[]
   FishingRods = {
      {
         model = `qua_fishing_rod_yellow`, -- Model of the fishing rod
         name = 'fishing_rod_one', -- Unique name for the fishing rod
         label = '1. Seviye Olta', -- Display name for the fishing rod
         level = 1 -- Level required to use the fishing rod
      },
      { model = `qua_fishing_rod_red`, name = 'fishing_rod_two', label = 'Olta (Seviye 2)', level = 2 },
      { model = `qua_fishing_rod_green`, name = 'fishing_rod_three', label = 'Olta (Seviye 3)', level = 3 },
      { model = `qua_fishing_rod_neon_purple`, name = 'fishing_rod_four', label = 'Olta (Seviye 4)', level = 4 },
      { model = `qua_fishing_rod_neon_blue`, name = 'fishing_rod_five', label = 'Olta (Seviye 5)', level = 5 },
   },

   ---@type FishingNet
   FishingNet = {
      name = 'fishing_net', -- Unique name for the item
      label = 'Balık Ağı', -- Display name for the item
      level = 1 -- Level required to use the fishing net
   },

   Anchor = {
      name = 'anchor', -- Unique name for the item
      label = 'Çapa', -- Display name for the item
      level = 1 -- Level required to use the anchor
   },

   ---@type Baits[]
   Baits = {
      {
         name = 'worm_fish_bait', -- Unique name for the item
         label = 'Solucan Yem', -- Display name for the item
         level = 1 -- Level required to use the bait
      },
      { name = 'simple_fish_bait', label = 'Basit Yem', level = 1 },
      { name = 'illegal_fish_bait', label = 'Yasa Dışı Yem', level = 1 },
   },

   ---@type DivingCloth
   DivingCloth = {
      name = 'diving_cloth', -- Unique name for the item
      label = 'Dalış Kıyafeti', -- Display name for the item
      level = 1 -- Level required to use the diving cloth
   },

   ---@type DivingGear
   DivingGear = {
      name = 'diving_gear', -- Unique name for the item
      label = 'Dalış Ekipmanı', -- Display name for the item
      level = 1 -- Level required to use the diving gear
   },

   ---@type DivingTube
   DivingTube = {
      name = 'diving_fill', -- Unique name for the item (aligned with market + ox_inventory)
      label = 'Dalış Tüpü', -- Display name for the item
      level = 1 -- Level required to use the diving tube
   },

   ---@type Fishs[]
   Fishs = {
      {
         name = 'bass', -- Unique name for the item
         label = 'Levrek', -- Display name for the item
         type = 'Fish', -- Type of the item (Fish, LuckyItem)
         image = 'bass.png', -- Image filename for the item
         level = 1, -- Level required to catch the fish
         quality = 'common', -- Quality of the item (common, eco, rare, epic)
         rodLevel = 1 -- Level required to catch the fish
      },
      { name = 'bluegill', label = 'Güneş Balığı', type = 'Fish', image = 'bluegill.png', level = 1, quality = 'eco', rodLevel = 1 },
      { name = 'common_carp', label = 'Sazan', type = 'Fish', image = 'common_carp.png', level = 2, quality = 'eco', rodLevel = 1 },
      { name = 'nothern_pike', label = 'Kuzey Turnası', type = 'Fish', image = 'nothern_pike.png', level = 2, quality = 'common', rodLevel = 2 },
      { name = 'perch', label = 'Tatlısu Levreği', type = 'Fish', image = 'perch.png', level = 3, quality = 'epic', rodLevel = 2 },
      { name = 'rainbow_trout', label = 'Gökkuşağı Alabalığı', type = 'Fish', image = 'rainbow_trout.png', level = 3, quality = 'rare', rodLevel = 2 },
      { name = 'redfin_pickerel', label = 'Kızıl Turna', type = 'Fish', image = 'redfin_pickerel.png', level = 4, quality = 'common', rodLevel = 3 },
      { name = 'rock_bass', label = 'Kaya Levreği', type = 'Fish', image = 'rock_bass.png', level = 4, quality = 'common', rodLevel = 3 },
      { name = 'small_trout', label = 'Küçük Alabalık', type = 'Fish', image = 'small_trout.png', level = 5, quality = 'rare', rodLevel = 3 },
      { name = 'smallmouth_bass', label = 'Küçük Ağızlı Levrek', type = 'Fish', image = 'smallmouth_bass.png', level = 5, quality = 'common', rodLevel = 4 },
      { name = 'sockeye_salmon', label = 'Kırmızı Somon', type = 'Fish', image = 'sockeye_salmon.png', level = 6, quality = 'eco', rodLevel = 4 },
      { name = 'trout', label = 'Alabalık', type = 'Fish', image = 'trout.png', level = 6, quality = 'common', rodLevel = 4 },
      { name = 'whitefish', label = 'Beyaz Balık', type = 'Fish', image = 'whitefish.png', level = 7, quality = 'epic', rodLevel = 5 },
   },

   ---@type LuckyItems[]
   LuckyItems = {
      {
         name = 'redpearl', -- Unique name for the item
         label = 'Kırmızı İnci', -- Display name for the item
         type = 'LuckyItem', -- Type of the item (Fish, LuckyItem)
         image = 'redpearl.png', -- Image filename for the item
         level = 1, -- Level required to catch the fish
         quality = 'epic' -- Quality of the item (common, eco, rare, epic)
      },
      { name = 'bluepearl', label = 'Mavi İnci', type = 'LuckyItem', image = 'bluepearl.png', level = 1, quality = 'epic' },
      { name = 'yellowpearl', label = 'Sarı İnci', type = 'LuckyItem', image = 'yellowpearl.png', level = 1, quality = 'epic' },
      { name = 'greenpearl', label = 'Yeşil İnci', type = 'LuckyItem', image = 'greenpearl.png', level = 1, quality = 'epic' },
      { name = 'green_crab', label = 'Yeşil Yengeç', type = 'LuckyItem', image = 'green_crab.png', level = 1, quality = 'rare' },
      { name = 'red_crab', label = 'Kırmızı Yengeç', type = 'LuckyItem', image = 'red_crab.png', level = 1, quality = 'rare' },
      { name = 'blue_crab', label = 'Mavi Yengeç', type = 'LuckyItem', image = 'blue_crab.png', level = 1, quality = 'rare' },
      { name = 'king_crab', label = 'Kral Yengeç', type = 'LuckyItem', image = 'king_crab.png', level = 1, quality = 'epic' },
   },

   ---@type UnderwaterObjects[]
   UnderwaterObjects = {
      {
         name = 'coral_grass', -- Unique name for the item
         objectName = 'prop_coral_pillar_01', -- Object name for the item
         label = 'Mercan Sütunu', -- Display name for the item
         type = 'Object', -- Type of the item (Object, Trash, LuckyItem)
         image = 'prop_coral_pillar_01.png', -- Image filename for the item
         level = 1, -- Level required to catch the fish
         quality = 'common' -- Quality of the item (common, eco, rare, epic)
      },
      { name = 'scrapmetal', objectName = 'gr_prop_gr_rsply_crate01a', label = 'Tahta Kutu', type = 'Object', image = 'gr_prop_gr_rsply_crate01a.png', level = 1, quality = 'common' },
      { name = 'vehicle_wheels', objectName = 'prop_rub_tyre_03', label = 'Araç Lastiği', type = 'Object', image = 'prop_rub_tyre_03.png', level = 1, quality = 'common' },
   },

   ---@type Trashs[]
   Trashs = {
      {
         name = 'trash_can', -- Unique name for the item
         label = 'Çöp Kutusu', -- Display name for the item
         type = 'Trash', -- Type of the item (Object, Trash, LuckyItem)
         image = 'trash_can.png', -- Image filename for the item
         level = 1, -- Level required to catch the fish
         quality = 'common' -- Quality of the item (common, eco, rare, epic)
      },
      { name = 'trash_chips', label = 'Çöp Cips Paketi', type = 'Trash', image = 'trash_chips.png', level = 1, quality = 'common' },
      { name = 'trash_burger', label = 'Çöp Hamburger', type = 'Trash', image = 'trash_burger.png', level = 1, quality = 'common' },
   },

   RodPartItems = {
      rod_grip = { name = 'rod_grip', label = 'Olta Sapı', type = 'RodPart', image = 'rod_grip.png', level = 1, quality = 'common' },
      rod_reel_seet = { name = 'rod_reel_seet', label = 'Olta Makara Yuvası', type = 'RodPart', image = 'rod_reel_seet.png', level = 1, quality = 'common' },
      rod_blank = { name = 'rod_blank', label = 'Olta Gövdesi', type = 'RodPart', image = 'rod_blank.png', level = 1, quality = 'common' },
      rod_fishing_line = { name = 'rod_fishing_line', label = 'Olta Misinası', type = 'RodPart', image = 'rod_fishing_line.png', level = 1, quality = 'common' },
   }
}