-- Paper (6-tahta-video-sanat.md 3.5, gallery): every canvas has its colour drawn just behind its face, so one whose
-- ink page or picture is not in view yet shows blank paper, never nothing. One small runtime texture per colour, made
-- once from a PNG written here (stored deflate) and loaded as a data URL.
Paper = {}

local made = {} -- colour -> txd name | false

local CRC = {}
for i = 0, 255 do
    local c = i
    for _ = 1, 8 do c = (c & 1) == 1 and (0xEDB88320 ~ (c >> 1)) or (c >> 1) end
    CRC[i] = c
end

local function crc32(s)
    local c = 0xFFFFFFFF
    for i = 1, #s do c = CRC[(c ~ s:byte(i)) & 255] ~ (c >> 8) end
    return (c ~ 0xFFFFFFFF) & 0xFFFFFFFF
end

local function chunk(kind, data)
    return string.pack('>I4', #data) .. kind .. data .. string.pack('>I4', crc32(kind .. data))
end

-- An 8 x 8 RGB PNG of one colour.
local function png(r, g, b)
    local raw = (string.char(0) .. string.char(r, g, b):rep(8)):rep(8)
    local a, s = 1, 0
    for i = 1, #raw do
        a = (a + raw:byte(i)) % 65521
        s = (s + a) % 65521
    end
    local z = string.char(0x78, 0x01, 0x01) .. string.pack('<I2<I2', #raw, ~#raw & 0xFFFF) .. raw .. string.pack('>I4', (s << 16) | a)
    return '\137PNG\r\n\26\n' .. chunk('IHDR', string.pack('>I4>I4BBBBB', 8, 8, 8, 2, 0, 0, 0)) .. chunk('IDAT', z) .. chunk('IEND', '')
end

-- The texture dictionary of a colour ('#rrggbb'), or nil when this client cannot load one.
function Paper.of(color)
    color = type(color) == 'string' and color:lower() or ''
    if made[color] ~= nil then return made[color] or nil end
    local r, g, b = color:match('^#(%x%x)(%x%x)(%x%x)$')
    if not r then
        made[color] = false
        return nil
    end
    local bytes = { png(tonumber(r, 16), tonumber(g, 16), tonumber(b, 16)):byte(1, -1) }
    local name = DL.dui.name(GetCurrentResourceName() .. '_paper')
    local ok, tex = pcall(CreateRuntimeTextureFromImage, CreateRuntimeTxd(name), 'tex', 'data:image/png;base64,' .. Ink.codec.toBase64(bytes))
    made[color] = ok and tex and GetRuntimeTextureWidth(tex) > 0 and name or false
    return made[color] or nil
end
