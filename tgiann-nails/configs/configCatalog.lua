-- Nail models are exported for these exact ids, keep the ids; labels come from the language files.
-- Every price (customer prices, unlock prices, starter parts, owner price ranges) is set in game: /nailsadmin > Prices

---@type NailsCatalogPart[]
config.shapes = {
    { id = "square" },
    { id = "round" },
    { id = "almond" },
    { id = "coffin" },
    { id = "stiletto" },
    { id = "stiletto_slim" },
}

---@type NailsCatalogPart[]
config.lengths = {
    { id = "xshort" },
    { id = "short" },
    { id = "medium" },
    { id = "long" },
    { id = "xlong" },
}

-- Ready colors in the picker; players can also pick any color
config.colors = {
    "#d9a08c",
    "#f2c4c4",
    "#f28bb3",
    "#e84d8a",
    "#c4102b",
    "#8c0f2e",
    "#5e0f24",
    "#ff7f66",
    "#ffb347",
    "#f6d365",
    "#a6e6cc",
    "#3ec6a8",
    "#9fd0f2",
    "#3d6fd6",
    "#1e2a78",
    "#bfa2e6",
    "#7b4bb8",
    "#f6f4f1",
    "#b9bdc8",
    "#5d5f66",
    "#141216",
}
config.allowCustomColor = true -- Players can pick any color, not only the ready ones

-- Transparent layers drawn over the base color; image = file in ui/build/layers
---@type NailsCatalogPart[]
config.layers = {
    { id = "glitter_silver" },
    { id = "glitter_gold" },
    { id = "glitter_holo" },
    { id = "glitter_pink" },
    { id = "french_white" },
    { id = "french_black" },
    { id = "hearts" },
    { id = "hearts_white" },
    { id = "stars_gold" },
    { id = "daisy" },
    { id = "leopard" },
    { id = "marble" },
    { id = "stripes_candy" },
    { id = "stripes_black" },
    { id = "pinstripes_gold" },
    { id = "dots_white" },
    { id = "dots_black" },
    { id = "confetti" },
    { id = "checker_black" },
    { id = "zebra" },
    { id = "chevron_white" },
    { id = "waves_white" },
    { id = "ombre_white" },
    { id = "ombre_pink" },
    { id = "ombre_turquoise" },
    { id = "ombre_lilac" },
    { id = "ombre_black" },
    { id = "ombre_red" },
    { id = "love" },
    { id = "flowers" },
    { id = "sakura" },
    { id = "smiley" },
    { id = "sparkles" },
    { id = "butterflies" },
    { id = "cherries" },
    { id = "text_love" },
    { id = "text_slay" },
    { id = "text_slay_white" },
    { id = "text_queen" },
    { id = "text_king" },
    { id = "text_xoxo" },
    { id = "text_babe" },
    -- Sets: a different picture on every finger (ui/build/layers/<id>_1..5.webp = thumb..pinky); the studio's Sets tab,
    -- under the heading of their group (lang key UI_SET_GROUP_<GROUP>). glow = true: drawn with the emissive models
    -- (tgiann-nails-assets ..._gNN), the picture shines in the dark
    { id = "set_stitched_doll", group = "halloween" },
    { id = "set_ghost_smiles", group = "halloween" },
    { id = "set_scarecrow", group = "halloween" },
    { id = "set_pumpkin_patch", group = "halloween" },
    { id = "set_spiderweb", group = "halloween" },
    { id = "set_witchy_moon", group = "halloween" },
    { id = "set_slime_monster", group = "halloween" },
    { id = "set_haunted_houses", group = "halloween" },
    { id = "set_black_cat", group = "halloween" },
    { id = "set_potion_magic", group = "halloween" },
    { id = "set_voodoo_hearts", group = "halloween" },
    { id = "set_skull_florals", group = "halloween" },
    { id = "set_mummy", group = "halloween" },
    { id = "set_spooky_sweets", group = "halloween" },
    { id = "set_graveyard", group = "halloween" },
    { id = "set_gothic_lace", group = "halloween" },
    { id = "set_frankenstein", group = "halloween" },
    { id = "set_bloody_bandages", group = "halloween" },
    { id = "set_haunted_carnival", group = "halloween" },
    { id = "set_autumn_ghosts", group = "halloween" },
    { id = "set_sweetheart_patchwork", group = "love" },
    { id = "set_cherry_kiss", group = "love" },
    { id = "set_love_letters", group = "love" },
    { id = "set_cupid_dream", group = "love" },
    { id = "set_rose_romance", group = "love" },
    { id = "set_heart_candy", group = "love" },
    { id = "set_midnight_love", group = "love" },
    { id = "set_teddy_bows", group = "love" },
    { id = "set_love_blooms", group = "love" },
    { id = "set_lock_key", group = "love" },
    { id = "set_lace_cameos", group = "gothic" },
    { id = "set_cathedral_roses", group = "gothic" },
    { id = "set_moonlit_mourning", group = "gothic" },
    { id = "set_velvet_hearts", group = "gothic" },
    { id = "set_raven_manor", group = "gothic" },
    { id = "set_thorned_relics", group = "gothic" },
    { id = "set_stained_glass", group = "gothic" },
    { id = "set_black_widow", group = "gothic" },
    { id = "set_victorian_jewels", group = "gothic" },
    { id = "set_midnight_abbey", group = "gothic" },
    { id = "set_magical_girl", group = "anime" },
    { id = "set_kawaii_chibi", group = "anime" },
    { id = "set_sakura_school", group = "anime" },
    { id = "set_shonen_burst", group = "anime" },
    { id = "set_moon_spirit", group = "anime" },
    { id = "set_neon_hearts", group = "neon", glow = true },
    { id = "set_cyber_graffiti", group = "neon", glow = true },
    { id = "set_glow_butterflies", group = "neon", glow = true },
    { id = "set_electric_flame", group = "neon", glow = true },
    { id = "set_laser_moon", group = "neon", glow = true },
    { id = "set_cuddly_kittens", group = "animals" },
    { id = "set_puppy_picnic", group = "animals" },
    { id = "set_bunny_candyland", group = "animals" },
    { id = "set_panda_dream", group = "animals" },
    { id = "set_forest_friends", group = "animals" },
    -- Top coats: the finish over the whole nail, picked in the studio's Color tab (none = the glossy polish).
    -- finish = "matte": the matte models (..._m33.._m48, no shine), "jelly": the alpha blended models (..._j17.._j32,
    -- see-through, the color tints it), glow = true: the emissive models, clear: a clear nail
    { id = "coat_matte", finish = "matte" },
    { id = "coat_glow", glow = true },
    { id = "coat_clear" },
    { id = "coat_jelly", finish = "jelly" },
}
config.maxLayers = 3 -- Most layers one design can have
-- Nails can be done one by one (e.g. left hand blue, right hand red). Most different looks on one player's 10 nails (1-4).
-- Each look uses one cell of the shared nail texture, so keep it low
config.maxFingerDesigns = 4

-- 3D charms glued on the nails; each nail has 3 spots (cuticle, middle, tip). Models: tgiann-nails-assets/stream/charms/tgiann_nail_charm_<id>
---@type NailsCatalogPart[]
config.charms = {
    { id = "bow_pink" },
    { id = "bow_blue" },
    { id = "bow_lilac" },
    { id = "bow_white" },
    { id = "butterfly_blue" },
    { id = "butterfly_pink" },
    { id = "gem_clear" },
    { id = "gem_pink" },
    { id = "gem_blue" },
    { id = "gem_lilac" },
    { id = "pearl" },
    { id = "heart_pink" },
    { id = "heart_red" },
    { id = "star" },
    { id = "strawberry" },
    { id = "cherry" },
    { id = "daisy" },
    { id = "flower_rainbow" },
    { id = "bear" },
    { id = "bunny" },
    { id = "crown" },
}
config.maxCharms = 10 -- Most charms on one player's 10 nails (each one is a small prop)

-- Player owned salons (what they unlock, pay for bills and charge is set in /nailsadmin > Prices)
---@type NailsBusinessConfig
config.business = {
    keyPrefix = "nails_", -- Business id in the tgiann-core control panel
    panelDistance = 3.0, -- Metres the buy / management point shows from
    historyDays = 90, -- Days the salon history (sales, NPC orders, shop, expenses), the staff stats and the income chart keep
}
