Config = {}

Config.Debug = false -- prints swap steps to F8. Set false for release.

Config.Enabled = true -- master switch for the auto-swap

-- Each downtown slot ships three placements of the same interior, all script
-- IPLs (ymap flag 1); the script loads exactly ONE and despawns the others:
--
--   'mirror'  = the vanilla GTA interior re-declared under our own archetype
--               (prompt_sdt_*) with our own copy of its collision. Immune to
--               other resources replacing the vanilla .ybn / .ytyp.  DEFAULT.
--   'vanilla' = the stock GTA archetype (v_barbers ...). Uses GTA's collision,
--               so a server that edits that collision elsewhere breaks it here.
--   'custom'  = a custom interior from another resource (barber / tattoo only).
--
-- Selection per slot:
--   defaultInterior = 'mirror' | 'vanilla'   used when no custom interior is active
--   customResource  = resource providing a custom interior (optional)
--   forceUseCustom  = true/false to override autodetect (nil = auto: custom when
--                     customResource is started, re-checked on start/stop)
--   gtaType / mirrorType / customType = MLO archetype names (to locate interiors)
--   coords         = a point at the interior
--   ipls / mirrorIpl / customIpl = placement ymaps of each variant
Config.Slots = {
    barber = {
        defaultInterior = 'mirror',
        customResource = 'prompt_barber',
        forceUseCustom = nil,
        gtaType    = 'v_barbers',
        mirrorType = 'prompt_sdt_v_barbers',
        customType = 'prompt_vbarber_col',
        coords     = vector3(1605.44861, 3719.40454, 33.6415253),
        ipls       = { 'sm_cs4_sandydt_barbers_milo', 'sm_cs4_sandydt_barbers_lod' },
        mirrorIpl  = 'prompt_sdt_v_barbers_milo',
        customIpl  = 'prompt_sandy_downtown_barber_dlc',
    },
    tattoo = {
        defaultInterior = 'mirror',
        customResource = 'prompt_tattoo',
        forceUseCustom = nil,
        gtaType    = 'v_tattoo',
        mirrorType = 'prompt_sdt_v_tattoo',
        customType = 'prompt_v_tattoo',
        coords     = vector3(1599.50391, 3713.97314, 33.99297),
        ipls       = { 'sm_cs4_sandydt_tattoo_milo', 'sm_cs4_sandydt_tattoo_lod' },
        mirrorIpl  = 'prompt_sdt_v_tattoo_milo',
        customIpl  = 'prompt_sandy_tattoo_dlc',
    },
    ammunation = {
        defaultInterior = 'mirror',
        gtaType    = 'v_gun2',
        mirrorType = 'prompt_sdt_v_gun2',
        coords     = vector3(1684.4436, 3766.48779, 34.5896072),
        ipls       = { 'sm_cs4_sandydt_v_gun2_milo' },
        mirrorIpl  = 'prompt_sdt_v_gun2_milo',
    },
    fleeca = {
        defaultInterior = 'mirror',
        gtaType    = 'v_genbank',
        mirrorType = 'prompt_sdt_v_genbank',
        coords     = vector3(1644.15942, 3725.76221, 33.2266464),
        ipls       = { 'sm_cs4_sandydt_v_genbank_milo', 'sm_cs4_sandydt_v_genbank_lod' },
        mirrorIpl  = 'prompt_sdt_v_genbank_milo',
    },
}
