-- No inventory: products fall back to commands instead of items.
return {
    caps = { metadata = false, stash = false, slots = false },
    count = function() return 0 end,
    registerUsable = function() return false end,
    add = function() return false end,
    remove = function() return false end,
    canCarry = function() return false end,
    items = function() return {} end,
    slot = function() return nil end,
    setMetadata = function() end,
    definition = function() return nil end,
    all = function() return {} end,
}
