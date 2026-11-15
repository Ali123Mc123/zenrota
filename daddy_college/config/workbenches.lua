-- Workbenches placed with /collegeadmin ('workbench_workshop', 'workbench_infirmary', 'workbench_kitchen',
-- 'workbench_hidden'): [E] lists the bench's recipes, a recipe takes its materials and gives the item after a progress
-- bar. needs: the Star Skill Tree skill or level rule an enrolled student must have (nil = open); others never need it.
-- SchoolOnly: only school members and enrolled students may use a bench.
Config.Workbenches = {
    Enabled = true,
    SchoolOnly = true,
    Reach = 2.0,           -- metres from the bench
    Kinds = {
        workbench_workshop = { Model = 'prop_tool_bench02', Recipes = { 'spray_can', 'repair_kit', 'respray_kit', 'lighting_controller' } },
        workbench_infirmary = { Model = 'prop_table_03', Recipes = { 'bandage', 'medikit', 'veba_ilac' } },
        -- School kitchen: plain food open to all, the rest at Culinary 6 + Journalism 6; Culinary 6 cooks in half the time.
        workbench_kitchen = { Model = 'prop_cooker_03', Anim = { dict = 'amb@prop_human_bbq@male@idle_a', clip = 'idle_b' },
            Faster = { needs = 'skill:fast_cooking', factor = 0.5 },
            Recipes = { 'ds_fries', 'ds_energy_bar', 'ds_steak_sandwich', 'ds_hotdog', 'ds_pizza_slice', 'ds_hotdog_tray',
                'ds_brownie', 'ds_apple_pie', 'ds_cheesecake', 'ds_tiramisu' } },
        -- Hidden bench (place it somewhere quiet): illegal car parts at Art 6 + Mechanics 6.
        workbench_hidden = { Model = 'prop_tool_bench02', Recipes = { 'nitrous_bottle', 'nitrous_install_kit', 'tyre_smoke_kit' } },
    },
    -- item and count given; time in ms; materials { item, count } in the order shown.
    Recipes = {
        spray_can = { item = 'spray_can', count = 1, time = 5000, needs = 'skill:spray_production',         -- Art 3
            materials = { { 'plastic', 1 }, { 'potato', 1 } } },
        repair_kit = { item = 'repair_kit', count = 1, time = 8000, needs = 'skill:repair_kit',             -- Mechanics 3
            materials = { { 'scrapmetal', 4 }, { 'plastic', 2 }, { 'duct_tape', 1 } } },
        respray_kit = { item = 'respray_kit', count = 1, time = 10000, needs = 'skill:car_paint_kit',       -- Art 6
            materials = { { 'plastic', 2 }, { 'glass', 1 }, { 'potato', 2 }, { 'scrapmetal', 1 } } },
        lighting_controller = { item = 'lighting_controller', count = 1, time = 10000,                      -- Mechanics 6 + Art 6 (neon)
            needs = { all = { { lesson = 'mekanik', level = 6 }, { lesson = 'resim', level = 6 } } },
            materials = { { 'copperwire', 2 }, { 'plastic', 2 }, { 'glass', 1 } } },
        bandage = { item = 'bandage', count = 2, time = 5000, needs = 'skill:craft_bandage',               -- Health 3
            materials = { { 'duct_tape', 1 }, { 'potato', 1 } } },
        medikit = { item = 'medikit', count = 1, time = 8000, needs = 'skill:craft_medkit',                -- Health 6 + Biology 6
            materials = { { 'bandage', 2 }, { 'potato', 1 }, { 'plastic', 1 } } },
        veba_ilac = { item = 'veba_ilac', count = 1, time = 6000, materials = { { 'potato', 1 } } }, -- plague day (daddy_veba)
        -- Kitchen (ingredients as the canteen's own recipes in can9work-jobsv2).
        ds_fries = { item = 'ds_fries', count = 1, time = 3000, materials = { { 'potato', 2 } } },
        ds_energy_bar = { item = 'ds_energy_bar', count = 1, time = 4000, materials = { { 'wheat', 1 }, { 'pumpkin', 1 } } },
        ds_steak_sandwich = { item = 'ds_steak_sandwich', count = 1, time = 6000, needs = 'kitchen',
            materials = { { 'pig_meat', 1 }, { 'wheat', 1 }, { 'lettuce', 1 } } },
        ds_hotdog = { item = 'ds_hotdog', count = 1, time = 4000, needs = 'kitchen',
            materials = { { 'pig_meat', 1 }, { 'wheat', 1 }, { 'onion', 1 } } },
        ds_pizza_slice = { item = 'ds_pizza_slice', count = 1, time = 4500, needs = 'kitchen',
            materials = { { 'wheat', 1 }, { 'pig_meat', 1 }, { 'tomato', 1 } } },
        ds_hotdog_tray = { item = 'ds_hotdog', count = 5, time = 15000, needs = 'kitchen',                  -- 5 for the price of 4
            materials = { { 'pig_meat', 4 }, { 'wheat', 4 }, { 'onion', 4 } } },
        ds_brownie = { item = 'ds_brownie', count = 1, time = 4000, needs = 'kitchen',
            materials = { { 'wheat', 1 }, { 'egg', 1 }, { 'bottle_milk', 1 } } },
        ds_apple_pie = { item = 'ds_apple_pie', count = 1, time = 5000, needs = 'kitchen',
            materials = { { 'wheat', 2 }, { 'egg', 1 } } },
        ds_cheesecake = { item = 'ds_cheesecake', count = 1, time = 5000, needs = 'kitchen',
            materials = { { 'bottle_milk', 1 }, { 'egg', 1 } } },
        ds_tiramisu = { item = 'ds_tiramisu', count = 1, time = 4500, needs = 'kitchen',
            materials = { { 'egg', 1 }, { 'bottle_milk', 1 } } },
        -- Hidden bench.
        nitrous_bottle = { item = 'nitrous_bottle', count = 1, time = 12000, needs = 'illegal',
            materials = { { 'scrapmetal', 3 }, { 'potato', 2 }, { 'plastic', 1 } } },
        nitrous_install_kit = { item = 'nitrous_install_kit', count = 1, time = 12000, needs = 'illegal',
            materials = { { 'scrapmetal', 4 }, { 'copperwire', 2 }, { 'duct_tape', 1 } } },
        tyre_smoke_kit = { item = 'tyre_smoke_kit', count = 1, time = 10000, needs = 'illegal',            -- coloured smoke
            materials = { { 'scrapmetal', 2 }, { 'plastic', 2 }, { 'potato', 1 } } },
    },
    -- Shared locks the recipes above name by word.
    Needs = {
        kitchen = { all = { { lesson = 'ascilik', level = 6 }, { lesson = 'gazetecilik', level = 6 } } }, -- Culinary 6 + Journalism 6
        illegal = { all = { { lesson = 'resim', level = 6 }, { lesson = 'mekanik', level = 6 } } },       -- Art 6 + Mechanics 6
    },
    Anim = { dict = 'mini@repair', clip = 'fixing_a_ped' },
}

-- Recipes that name a shared lock by word get the rule itself.
for _, recipe in pairs(Config.Workbenches.Recipes) do
    if type(recipe.needs) == 'string' and Config.Workbenches.Needs[recipe.needs] then recipe.needs = Config.Workbenches.Needs[recipe.needs] end
end
