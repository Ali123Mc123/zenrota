local localeCache = {}

local function validLocaleCode(code)
  return type(code) == 'string' and code ~= '' and code ~= 'auto' and code:match('^[%w_-]+$') ~= nil
end

function NN.LocaleCatalog(code)
  if not validLocaleCode(code) then return nil end
  if localeCache[code] ~= nil then return localeCache[code] or nil end

  local path = ('locales/%s.json'):format(code)
  local raw = LoadResourceFile(GetCurrentResourceName(), path)
  if not raw then
    print(('[nn_banking] Locale file not found: %s'):format(path))
    localeCache[code] = false
    return nil
  end

  local ok, decoded = pcall(json.decode, raw)
  if not ok or type(decoded) ~= 'table' or type(decoded.translations) ~= 'table' then
    print(('[nn_banking] Invalid locale file: %s (expected a translations object)'):format(path))
    localeCache[code] = false
    return nil
  end

  local translations = {}
  for key, value in pairs(decoded.translations) do
    if type(key) == 'string' and type(value) == 'string' then translations[key] = value end
  end

  local meta = type(decoded._meta) == 'table' and decoded._meta or {}
  local catalog = {
    code = code,
    label = type(meta.label) == 'string' and meta.label or code,
    localeTag = type(meta.localeTag) == 'string' and meta.localeTag or code,
    direction = meta.direction == 'rtl' and 'rtl' or 'ltr',
    translations = translations,
  }
  localeCache[code] = catalog
  return catalog
end

function NN.ConfiguredLocaleCatalog()
  local code = Config.Locale or 'auto'
  return NN.LocaleCatalog(code == 'auto' and 'en' or code)
end

function NN.BrandName()
  return (Config.Brand and Config.Brand.Name) or 'NN Bank'
end

function NN.Translate(key, vars)
  local configured = NN.ConfiguredLocaleCatalog()
  local fallback = NN.LocaleCatalog('en')
  local value = configured and configured.translations[key]
    or fallback and fallback.translations[key]
    or key
  if vars then
    value = value:gsub('{([%w_]+)}', function(name)
      return vars[name] ~= nil and tostring(vars[name]) or ('{' .. name .. '}')
    end)
  end
  return value
end

function NN.FormatCurrency(value)
  local amount = tostring(math.floor(tonumber(value) or 0))
  local symbol = tostring(Config.Currency or '$')
  local separator = Config.CurrencySpacing and ' ' or ''
  if Config.CurrencyPosition == 'after' then return amount .. separator .. symbol end
  return symbol .. separator .. amount
end
