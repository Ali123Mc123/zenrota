local function running(resource)
  return GetResourceState(resource) == 'started'
end

function NN.TargetProvider()
  local configured = Config.TargetSystem
  if configured == nil then
    if Config.UseOxTarget ~= false and running('ox_target') then return 'ox_target' end
    return 'prompt'
  end

  configured = tostring(configured):lower():gsub('_', '-'):gsub('%s+', '')
  if configured == 'auto' then
    if running('ox_target') then return 'ox_target' end
    if running('qb-target') then return 'qb-target' end
  elseif (configured == 'ox' or configured == 'ox-target') and running('ox_target') then
    return 'ox_target'
  elseif (configured == 'qb' or configured == 'qb-target' or configured == 'qbtarget') and running('qb-target') then
    return 'qb-target'
  end

  return 'prompt'
end
