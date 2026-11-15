-- Ink codec (6-tahta-video-sanat.md 3.2): an op is base64 of a 9-byte header and a body, on a 0..4095 grid per axis.
-- Header: kind, flags, R, G, B, A (opacity), width (u16 LE, 1/8 px at the 680 px reference), hardness.
-- Strokes and shapes: point count (varint), first point (2 x u16 LE), zigzag varint deltas. del/undel: target seqs
-- (ascending, as deltas) and the author's own client keys. clear: no body. Decoding is strict, so every op has one
-- byte string: encode(decode(s)) == s. Twin of daddy_lib/web/packages/ink/codec.ts (packages/ink/tests/codec-cases.json).
Ink = Ink or {}
local codec = {}

local byte, concat, ceil, floor = string.byte, table.concat, math.ceil, math.floor
local toint = math.tointeger

local GRID, MAX_POINTS, MAX_B64, MAX_RAW = 4095, 4096, 16384, 12288
local MAX_TARGETS, MAX_SEQ, MAX_KEY, MAX_CELLS = 256, 268435455, 16, 4096
local WIDTH_MIN, WIDTH_MAX, REFERENCE = 4, 1600, 680
local ARROW_HEAD, ARROW_MIN = 4, 12 -- an arrow head is 4 widths long, at least 12 reference px

codec.GRID, codec.MAX_POINTS, codec.MAX_B64, codec.MAX_RAW = GRID, MAX_POINTS, MAX_B64, MAX_RAW
codec.MAX_TARGETS, codec.MAX_SEQ, codec.MAX_KEY, codec.MAX_CELLS = MAX_TARGETS, MAX_SEQ, MAX_KEY, MAX_CELLS
codec.WIDTH_MIN, codec.WIDTH_MAX, codec.REFERENCE = WIDTH_MIN, WIDTH_MAX, REFERENCE
codec.ARROW_HEAD, codec.ARROW_MIN = ARROW_HEAD, ARROW_MIN

local F = { FILLED = 1, DASHED = 2, CONT = 4, LEGACY = 8, NOSMOOTH = 16, BOLD = 32, CENTER = 64 }
codec.FLAG = F

-- Objects (P4): a text box or a picture; 'of' names the object an op is the new version of (0: a new object).
local MAX_TEXT, MAX_CHARS, MAX_LINES, TEXT_MIN, FONTS = 1200, 280, 10, 64, 2 -- UTF-8 bytes, letters, lines, 8 px, fonts
codec.MAX_TEXT, codec.MAX_CHARS, codec.MAX_LINES, codec.TEXT_MIN, codec.FONTS = MAX_TEXT, MAX_CHARS, MAX_LINES, TEXT_MIN, FONTS

-- A kind's code is its place in this list. rep, bg and page are kept for later stages.
local NAMES = { 'pen', 'marker', 'brush', 'airbrush', 'eraser', 'line', 'arrow', 'rect', 'ellipse',
    'patch', 'text', 'image', 'del', 'undel', 'rep', 'clear', 'bg', 'page' }
local CODE = {}
for i, name in ipairs(NAMES) do CODE[name] = i end
codec.NAMES, codec.CODE = NAMES, CODE

-- body: 'points' (a stroke 1..4096, a shape exactly 2), 'targets', 'empty' or 'mask' (the bucket: cols, rows, a box
-- x, y, w, h as u16 LE, then varint runs over the box row by row, off first; only its colour in the header),
-- 'text' (of, then x, y, w as u16 LE, a varint length and strict UTF-8; size in width, font in hardness) or 'image'
-- (of, the sha256 as 32 bytes, x, y, w, h, rot as u16 LE; no header). mask: the flags the kind may carry.
local STROKE = F.CONT | F.LEGACY | F.NOSMOOTH
local SPEC = {
    pen = { body = 'points', mask = STROKE },
    marker = { body = 'points', mask = STROKE },
    brush = { body = 'points', mask = STROKE },
    airbrush = { body = 'points', mask = STROKE },
    eraser = { body = 'points', mask = STROKE },
    line = { body = 'points', shape = true, mask = F.DASHED | F.LEGACY },
    arrow = { body = 'points', shape = true, mask = F.DASHED | F.LEGACY },
    rect = { body = 'points', shape = true, mask = F.FILLED | F.DASHED | F.LEGACY },
    ellipse = { body = 'points', shape = true, mask = F.FILLED | F.DASHED | F.LEGACY },
    patch = { body = 'mask', mask = F.CONT },
    del = { body = 'targets', mask = 0 },
    undel = { body = 'targets', mask = 0 },
    clear = { body = 'empty', mask = 0 },
    text = { body = 'text', mask = F.BOLD | F.CENTER },
    image = { body = 'image', mask = 0 },
}
codec.SPEC = SPEC

-- Base64 (RFC 4648, padded) ----------------------------------------------------------------------------------

local ENC, DEC = {}, {} -- DEC: a byte's 6 bits, 64 for anything that is not a base64 letter
do
    local alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    for i = 0, 255 do DEC[i] = 64 end
    for i = 1, 64 do
        ENC[i - 1] = alphabet:sub(i, i)
        DEC[alphabet:byte(i)] = i - 1
    end
end

-- bytes: a list of 0..255 (n of them).
function codec.toBase64(bytes, n)
    n = n or #bytes
    local out, o, i = {}, 0, 1
    while i + 2 <= n do
        local v = (bytes[i] << 16) | (bytes[i + 1] << 8) | bytes[i + 2]
        out[o + 1], out[o + 2], out[o + 3], out[o + 4] = ENC[v >> 18], ENC[(v >> 12) & 63], ENC[(v >> 6) & 63], ENC[v & 63]
        o, i = o + 4, i + 3
    end
    if i == n then
        local v = bytes[i] << 16
        out[o + 1], out[o + 2], out[o + 3] = ENC[v >> 18], ENC[(v >> 12) & 63], '=='
    elseif i == n - 1 then
        local v = (bytes[i] << 16) | (bytes[i + 1] << 8)
        out[o + 1], out[o + 2], out[o + 3], out[o + 4] = ENC[v >> 18], ENC[(v >> 12) & 63], ENC[(v >> 6) & 63], '='
    end
    return concat(out)
end

-- The bytes and their count, or nil: wrong length or letter, padding inside, or stray bits before the padding.
-- Two quanta per string.byte call and one check for bad letters at the end: this is the server's hot path.
function codec.fromBase64(s)
    if type(s) ~= 'string' then return nil end
    local n = #s
    if n == 0 or n % 4 ~= 0 then return nil end
    local bytes, o, bad, i = {}, 0, 0, 1
    while i <= n - 11 do
        local a, b, c, d, e, f, g, h = byte(s, i, i + 7)
        a, b, c, d, e, f, g, h = DEC[a], DEC[b], DEC[c], DEC[d], DEC[e], DEC[f], DEC[g], DEC[h]
        bad = bad | a | b | c | d | e | f | g | h
        local v, w = (a << 18) | (b << 12) | (c << 6) | d, (e << 18) | (f << 12) | (g << 6) | h
        bytes[o + 1], bytes[o + 2], bytes[o + 3] = v >> 16, (v >> 8) & 255, v & 255
        bytes[o + 4], bytes[o + 5], bytes[o + 6] = w >> 16, (w >> 8) & 255, w & 255
        o, i = o + 6, i + 8
    end
    if i <= n - 7 then
        local a, b, c, d = byte(s, i, i + 3)
        a, b, c, d = DEC[a], DEC[b], DEC[c], DEC[d]
        bad = bad | a | b | c | d
        local v = (a << 18) | (b << 12) | (c << 6) | d
        bytes[o + 1], bytes[o + 2], bytes[o + 3] = v >> 16, (v >> 8) & 255, v & 255
        o = o + 3
    end
    local a, b, c, d = byte(s, n - 3, n)
    a, b = DEC[a], DEC[b]
    if (bad | a | b) > 63 then return nil end
    if d == 61 then
        if c == 61 then
            if b & 15 ~= 0 then return nil end
            bytes[o + 1] = (a << 2) | (b >> 4)
            return bytes, o + 1
        end
        c = DEC[c]
        if c > 63 or c & 3 ~= 0 then return nil end
        local v = (a << 18) | (b << 12) | (c << 6)
        bytes[o + 1], bytes[o + 2] = v >> 16, (v >> 8) & 255
        return bytes, o + 2
    end
    c, d = DEC[c], DEC[d]
    if (c | d) > 63 then return nil end
    local v = (a << 18) | (b << 12) | (c << 6) | d
    bytes[o + 1], bytes[o + 2], bytes[o + 3] = v >> 16, (v >> 8) & 255, v & 255
    return bytes, o + 3
end

-- Helpers ----------------------------------------------------------------------------------------------------

-- Client keys: 1..16 of 0-9 A-Z a-z _ -.
local KEY = {}
for c in ('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_-'):gmatch('.') do KEY[c:byte()] = true end

function codec.isKey(ck)
    if type(ck) ~= 'string' or #ck < 1 or #ck > MAX_KEY then return false end
    for i = 1, #ck do
        if not KEY[byte(ck, i)] then return false end
    end
    return true
end

-- A whole number in lo..hi (16.0 counts; NaN, text and booleans do not).
local function int(v, lo, hi)
    return type(v) == 'number' and v >= lo and v <= hi and v % 1 == 0
end

local function zigzag(d) return d >= 0 and d * 2 or -d * 2 - 1 end
local function vsize(v) return v < 128 and 1 or v < 16384 and 2 or v < 2097152 and 3 or 4 end
codec.zigzag, codec.varintSize = zigzag, vsize

local function put(out, n, v)
    while v >= 128 do
        n = n + 1
        out[n] = (v & 127) | 128
        v = v >> 7
    end
    n = n + 1
    out[n] = v
    return n
end

-- A varint at pos: value and the next pos, or nil and a reason. At most 4 bytes, and the shortest form only.
local function varint(bytes, pos)
    local value, shift = 0, 0
    for i = 0, 3 do
        local b = bytes[pos + i]
        if not b then return nil, 'short' end
        value = value | ((b & 127) << shift)
        if b < 128 then
            if i > 0 and b == 0 then return nil, 'varint' end
            return value, pos + i + 1
        end
        shift = shift + 7
    end
    return nil, 'varint'
end

local function zeroHeader(op)
    for _, key in ipairs({ 'r', 'g', 'b', 'a', 'width', 'hardness' }) do
        local v = op[key]
        if v ~= nil and v ~= 0 then return false end
    end
    return true
end

-- Letters and lines of bytes i..j as strict UTF-8 (the WHATWG decoder's rules) with no control letter but the
-- newline, or nil.
local function utf8Check(b, i, j)
    local chars, lines = 0, 1
    while i <= j do
        local c, n, lo, hi = b[i], 0, 128, 191
        if c < 128 then
            if (c < 32 and c ~= 10) or c == 127 then return nil end
            if c == 10 then lines = lines + 1 end
        elseif c >= 194 and c <= 223 then
            n = 1
            if c == 194 then lo = 160 end -- C1 controls
        elseif c >= 224 and c <= 239 then
            n = 2
            if c == 224 then lo = 160 elseif c == 237 then hi = 159 end
        elseif c >= 240 and c <= 244 then
            n = 3
            if c == 240 then lo = 144 elseif c == 244 then hi = 143 end
        else
            return nil
        end
        if i + n > j then return nil end
        for k = 1, n do
            local d = b[i + k]
            if d < (k == 1 and lo or 128) or d > (k == 1 and hi or 191) then return nil end
        end
        i, chars = i + n + 1, chars + 1
    end
    return chars, lines
end
codec.utf8Check = utf8Check

local function u16(out, n, ...)
    for _, v in ipairs({ ... }) do
        v = toint(v)
        out[n + 1], out[n + 2] = v & 255, v >> 8
        n = n + 2
    end
    return n
end

-- A text box's or picture's body after the header, or nil and the reason.
local function object(op, spec, out)
    local of = op.of == nil and 0 or op.of
    if not int(of, 0, MAX_SEQ) then return nil, 'targets' end
    if spec.body == 'text' then
        local r, g, b, a, w, h = op.r, op.g, op.b, op.a, op.width, op.hardness
        if not (int(r, 0, 255) and int(g, 0, 255) and int(b, 0, 255) and int(a, 1, 255) and int(h, 0, FONTS - 1) and int(w, TEXT_MIN, WIDTH_MAX)) then
            return nil, 'header'
        end
        w = toint(w)
        out[3], out[4], out[5], out[6], out[7], out[8], out[9] = toint(r), toint(g), toint(b), toint(a), w & 255, w >> 8, toint(h)
        if not (int(op.x, 0, GRID) and int(op.y, 0, GRID) and int(op.w, 1, GRID)) then return nil, 'coord' end
        local s = op.text
        if type(s) ~= 'string' or #s < 1 or #s > MAX_TEXT then return nil, 'text' end
        local bytes = { byte(s, 1, -1) }
        local chars, lines = utf8Check(bytes, 1, #bytes)
        if not chars or chars > MAX_CHARS or lines > MAX_LINES then return nil, 'text' end
        local n = u16(out, put(out, 9, toint(of)), op.x, op.y, op.w)
        n = put(out, n, #bytes)
        for i = 1, #bytes do out[n + i] = bytes[i] end
        return out, n + #bytes
    end
    if not zeroHeader(op) then return nil, 'header' end
    local hash = op.hash
    if type(hash) ~= 'string' or #hash ~= 64 or hash:find('[^0-9a-f]') then return nil, 'hash' end
    if not (int(op.x, 0, GRID) and int(op.y, 0, GRID) and int(op.w, 1, GRID) and int(op.h, 1, GRID)) then return nil, 'coord' end
    local rot = op.rot == nil and 0 or op.rot
    if not int(rot, 0, 359) then return nil, 'coord' end
    local n = put(out, 9, toint(of))
    for i = 1, 63, 2 do
        n = n + 1
        out[n] = tonumber(hash:sub(i, i + 1), 16)
    end
    return out, u16(out, n, op.x, op.y, op.w, op.h, rot)
end

-- Encode -----------------------------------------------------------------------------------------------------

-- The op's bytes and their count, or nil and the reason (the same reasons decode gives).
local function build(op)
    if type(op) ~= 'table' then return nil, 'op' end
    local spec = type(op.kind) == 'string' and SPEC[op.kind]
    if not spec then return nil, 'kind' end
    local flags = op.flags == nil and 0 or op.flags
    if not int(flags, 0, 255) or (toint(flags) | spec.mask) ~= spec.mask then return nil, 'flags' end
    local out = { CODE[op.kind], toint(flags), 0, 0, 0, 0, 0, 0, 0 }

    if spec.body == 'points' then
        local r, g, b, a, w, h = op.r, op.g, op.b, op.a, op.width, op.hardness
        if not (int(r, 0, 255) and int(g, 0, 255) and int(b, 0, 255) and int(a, 1, 255) and int(h, 0, 255) and int(w, WIDTH_MIN, WIDTH_MAX)) then
            return nil, 'header'
        end
        w = toint(w)
        out[3], out[4], out[5], out[6], out[7], out[8], out[9] = toint(r), toint(g), toint(b), toint(a), w & 255, w >> 8, toint(h)
        local pts = op.points
        if type(pts) ~= 'table' then return nil, 'count' end
        local len = #pts
        if len < 2 or len % 2 ~= 0 or len > MAX_POINTS * 2 or (spec.shape and len ~= 4) then return nil, 'count' end
        local x, y = pts[1], pts[2]
        if not (int(x, 0, GRID) and int(y, 0, GRID)) then return nil, 'coord' end
        x, y = toint(x), toint(y)
        local n = put(out, 9, len // 2)
        out[n + 1], out[n + 2], out[n + 3], out[n + 4] = x & 255, x >> 8, y & 255, y >> 8
        n = n + 4
        for i = 3, len, 2 do
            local nx, ny = pts[i], pts[i + 1]
            if not (int(nx, 0, GRID) and int(ny, 0, GRID)) then return nil, 'coord' end
            nx, ny = toint(nx), toint(ny)
            n = put(out, n, zigzag(nx - x))
            n = put(out, n, zigzag(ny - y))
            x, y = nx, ny
        end
        if n > MAX_RAW then return nil, 'size' end
        return out, n
    end

    if spec.body == 'mask' then
        local r, g, b, a = op.r, op.g, op.b, op.a
        if not (int(r, 0, 255) and int(g, 0, 255) and int(b, 0, 255) and int(a, 1, 255))
            or (op.width ~= nil and op.width ~= 0) or (op.hardness ~= nil and op.hardness ~= 0) then return nil, 'header' end
        out[3], out[4], out[5], out[6] = toint(r), toint(g), toint(b), toint(a)
        local m = op.mask
        if type(m) ~= 'table' or not (int(m.cols, 1, MAX_CELLS) and int(m.rows, 1, MAX_CELLS)) then return nil, 'count' end
        if not (int(m.x, 0, m.cols - 1) and int(m.y, 0, m.rows - 1) and int(m.w, 1, m.cols - m.x) and int(m.h, 1, m.rows - m.y)) then
            return nil, 'coord'
        end
        local n = 9
        for _, v in ipairs({ m.cols, m.rows, m.x, m.y, m.w, m.h }) do
            v = toint(v)
            out[n + 1], out[n + 2] = v & 255, v >> 8
            n = n + 2
        end
        local runs, total, cells = m.runs, 0, toint(m.w) * toint(m.h)
        if type(runs) ~= 'table' or #runs < 2 then return nil, 'count' end
        for i = 1, #runs do
            local v = runs[i]
            if not int(v, i == 1 and 0 or 1, cells) or total + v > cells then return nil, 'count' end
            v = toint(v)
            total = total + v
            n = put(out, n, v)
        end
        if total ~= cells then return nil, 'count' end
        if n > MAX_RAW then return nil, 'size' end
        return out, n
    end

    if spec.body == 'text' or spec.body == 'image' then return object(op, spec, out) end

    if not zeroHeader(op) then return nil, 'header' end
    if spec.body == 'empty' then return out, 9 end

    local seqs, cks = op.seqs or {}, op.cks or {}
    if type(seqs) ~= 'table' or type(cks) ~= 'table' then return nil, 'targets' end
    local ns, nc = #seqs, #cks
    if ns + nc < 1 or ns + nc > MAX_TARGETS then return nil, 'targets' end
    local n, last = put(out, 9, ns), 0
    for i = 1, ns do
        local s = seqs[i]
        if not int(s, 1, MAX_SEQ) or s <= last then return nil, 'targets' end
        s = toint(s)
        n = put(out, n, s - last)
        last = s
    end
    n = put(out, n, nc)
    local seen = {}
    for i = 1, nc do
        local ck = cks[i]
        if not codec.isKey(ck) or seen[ck] then return nil, 'ck' end
        seen[ck] = true
        n = n + 1
        out[n] = #ck
        for j = 1, #ck do out[n + j] = byte(ck, j) end
        n = n + #ck
    end
    return out, n
end

-- nil when the op can be sent, else the reason.
function codec.check(op)
    local out, reason = build(op)
    if out then return nil end
    return reason
end

-- Base64 of the op, or nil and the reason.
function codec.encode(op)
    local out, n = build(op)
    if not out then return nil, n end
    return codec.toBase64(out, n)
end

-- Decode -----------------------------------------------------------------------------------------------------

-- The op as a table (kind, flags, r, g, b, a, width, hardness and points or seqs and cks), or nil and the reason:
-- b64, size, short, kind, flags, header, count, coord, varint, targets, ck, trailing. Never throws.
function codec.decode(s)
    if type(s) ~= 'string' then return nil, 'b64' end
    if #s > MAX_B64 then return nil, 'size' end
    local bytes, n = codec.fromBase64(s)
    if not bytes then return nil, 'b64' end
    if n < 9 then return nil, 'short' end
    local kind = NAMES[bytes[1]]
    local spec = kind and SPEC[kind]
    if not spec then return nil, 'kind' end
    local flags = bytes[2]
    if (flags | spec.mask) ~= spec.mask then return nil, 'flags' end
    local width = bytes[7] | (bytes[8] << 8)
    local op = { kind = kind, flags = flags, r = bytes[3], g = bytes[4], b = bytes[5], a = bytes[6], width = width, hardness = bytes[9] }

    if spec.body == 'points' then
        if op.a == 0 or width < WIDTH_MIN or width > WIDTH_MAX then return nil, 'header' end
        local count, pos = varint(bytes, 10)
        if not count then return nil, pos end
        if count < 1 or count > MAX_POINTS or (spec.shape and count ~= 2) then return nil, 'count' end
        if pos + 3 > n then return nil, 'short' end
        local x, y = bytes[pos] | (bytes[pos + 1] << 8), bytes[pos + 2] | (bytes[pos + 3] << 8)
        if x > GRID or y > GRID then return nil, 'coord' end
        pos = pos + 4
        local pts = { x, y }
        for i = 2, count do -- one- and two-byte steps read here, longer ones by varint()
            local zx, hi = bytes[pos], nil
            if not zx then return nil, 'short' end
            if zx < 128 then
                pos = pos + 1
            else
                hi = bytes[pos + 1]
                if hi and hi > 0 and hi < 128 then
                    zx, pos = (zx & 127) | (hi << 7), pos + 2
                else
                    zx, pos = varint(bytes, pos)
                    if not zx then return nil, pos end
                end
            end
            local zy = bytes[pos]
            if not zy then return nil, 'short' end
            if zy < 128 then
                pos = pos + 1
            else
                hi = bytes[pos + 1]
                if hi and hi > 0 and hi < 128 then
                    zy, pos = (zy & 127) | (hi << 7), pos + 2
                else
                    zy, pos = varint(bytes, pos)
                    if not zy then return nil, pos end
                end
            end
            x, y = x + ((zx >> 1) ~ -(zx & 1)), y + ((zy >> 1) ~ -(zy & 1))
            if x < 0 or x > GRID or y < 0 or y > GRID then return nil, 'coord' end
            pts[i * 2 - 1], pts[i * 2] = x, y
        end
        if pos ~= n + 1 then return nil, 'trailing' end
        op.points = pts
        return op
    end

    if spec.body == 'mask' then
        if op.a == 0 or width ~= 0 or op.hardness ~= 0 then return nil, 'header' end
        if n < 21 then return nil, 'short' end
        local v = {}
        for i = 0, 5 do v[i + 1] = bytes[10 + i * 2] | (bytes[11 + i * 2] << 8) end
        local cols, rows, x, y, w, h = v[1], v[2], v[3], v[4], v[5], v[6]
        if cols < 1 or cols > MAX_CELLS or rows < 1 or rows > MAX_CELLS then return nil, 'count' end
        if x >= cols or y >= rows or w < 1 or h < 1 or x + w > cols or y + h > rows then return nil, 'coord' end
        local cells, total, runs, pos = w * h, 0, {}, 22
        while total < cells do
            local run
            run, pos = varint(bytes, pos)
            if not run then return nil, pos end
            if (#runs > 0 and run < 1) or total + run > cells then return nil, 'count' end
            runs[#runs + 1] = run
            total = total + run
        end
        if #runs < 2 then return nil, 'count' end
        if pos ~= n + 1 then return nil, 'trailing' end
        op.mask = { cols = cols, rows = rows, x = x, y = y, w = w, h = h, runs = runs }
        return op
    end

    if spec.body == 'text' then
        if op.a == 0 or width < TEXT_MIN or width > WIDTH_MAX or op.hardness >= FONTS then return nil, 'header' end
        local of, pos = varint(bytes, 10)
        if not of then return nil, pos end
        if pos + 5 > n then return nil, 'short' end
        local x, y, w = bytes[pos] | (bytes[pos + 1] << 8), bytes[pos + 2] | (bytes[pos + 3] << 8), bytes[pos + 4] | (bytes[pos + 5] << 8)
        if x > GRID or y > GRID or w < 1 or w > GRID then return nil, 'coord' end
        local len
        len, pos = varint(bytes, pos + 6)
        if not len then return nil, pos end
        if len < 1 or len > MAX_TEXT then return nil, 'text' end
        if pos + len - 1 > n then return nil, 'short' end
        if pos + len - 1 < n then return nil, 'trailing' end
        local chars, lines = utf8Check(bytes, pos, n)
        if not chars or chars > MAX_CHARS or lines > MAX_LINES then return nil, 'text' end
        op.of, op.x, op.y, op.w, op.text = of, x, y, w, string.char(table.unpack(bytes, pos, n))
        return op
    end

    if flags ~= 0 or not zeroHeader(op) then return nil, 'header' end

    if spec.body == 'image' then
        local of, pos = varint(bytes, 10)
        if not of then return nil, pos end
        if pos + 41 > n then return nil, 'short' end
        if pos + 41 < n then return nil, 'trailing' end
        local hex = {}
        for i = 0, 31 do hex[i + 1] = ('%02x'):format(bytes[pos + i]) end
        local v = {}
        for i = 0, 4 do v[i + 1] = bytes[pos + 32 + i * 2] | (bytes[pos + 33 + i * 2] << 8) end
        if v[1] > GRID or v[2] > GRID or v[3] < 1 or v[3] > GRID or v[4] < 1 or v[4] > GRID or v[5] > 359 then return nil, 'coord' end
        op.of, op.hash, op.x, op.y, op.w, op.h, op.rot = of, concat(hex), v[1], v[2], v[3], v[4], v[5]
        return op
    end

    if spec.body == 'empty' then
        if n ~= 9 then return nil, 'trailing' end
        return op
    end

    local ns, pos = varint(bytes, 10)
    if not ns then return nil, pos end
    if ns > MAX_TARGETS then return nil, 'targets' end
    local seqs, last = {}, 0
    for i = 1, ns do
        local step
        step, pos = varint(bytes, pos)
        if not step then return nil, pos end
        if step < 1 or last + step > MAX_SEQ then return nil, 'targets' end
        last = last + step
        seqs[i] = last
    end
    local nc
    nc, pos = varint(bytes, pos)
    if not nc then return nil, pos end
    if ns + nc < 1 or ns + nc > MAX_TARGETS then return nil, 'targets' end
    local cks, seen = {}, {}
    for i = 1, nc do
        local len = bytes[pos]
        if not len then return nil, 'short' end
        if len < 1 or len > MAX_KEY then return nil, 'ck' end
        if pos + len > n then return nil, 'short' end
        for j = pos + 1, pos + len do
            if not KEY[bytes[j]] then return nil, 'ck' end
        end
        local ck = string.char(table.unpack(bytes, pos + 1, pos + len))
        if seen[ck] then return nil, 'ck' end
        seen[ck] = true
        cks[i] = ck
        pos = pos + len + 1
    end
    if pos ~= n + 1 then return nil, 'trailing' end
    op.seqs, op.cks = seqs, cks
    return op
end

-- Geometry ---------------------------------------------------------------------------------------------------

-- A 0..1 position on the grid.
function codec.grid(u)
    if type(u) ~= 'number' or u ~= u or u <= 0 then return 0 end
    if u >= 1 then return GRID end
    return floor(u * GRID + 0.5)
end

-- A width in reference px as the header's 1/8 px steps.
function codec.width8(px)
    if type(px) ~= 'number' or px ~= px then return WIDTH_MIN end
    return math.max(WIDTH_MIN, math.min(WIDTH_MAX, floor(px * 8 + 0.5)))
end

-- A text box (its written lines at 1.3 x the size) or a picture (turned: the circle around it) on the grid.
function codec.objectBox(op, aspect)
    local x, y, w = op.x or 0, op.y or 0, op.w or 1
    local sx, sy = REFERENCE / GRID, REFERENCE / aspect / GRID -- page units per grid step
    if op.kind == 'text' then
        local lines = 1
        for _ in tostring(op.text or ''):gmatch('\n') do lines = lines + 1 end
        local tall = ceil(lines * (op.width or TEXT_MIN) / 8 * 1.3 / sy)
        return x, y, math.min(GRID, x + w), math.min(GRID, y + tall)
    end
    local h = op.h or 1
    if (op.rot or 0) == 0 then return x, y, math.min(GRID, x + w), math.min(GRID, y + h) end
    local r = math.sqrt((w * sx) ^ 2 + (h * sy) ^ 2) / 2
    local cx, cy = x + w / 2, y + h / 2
    return math.max(0, floor(cx - r / sx)), math.max(0, floor(cy - r / sy)), math.min(GRID, ceil(cx + r / sx)), math.min(GRID, ceil(cy + r / sy))
end

-- The grid box an op can paint: its points with half its width around them (an arrow its head), clamped to the page.
-- aspect: page width / height (a width is drawn in px of the page width). clear covers the page; del/undel nothing.
function codec.bbox(op, aspect)
    local spec = type(op) == 'table' and SPEC[op.kind]
    if not spec then return nil end
    if spec.body == 'mask' then -- the box's cells on the grid, one more around
        local m = op.mask
        if type(m) ~= 'table' or not (int(m.cols, 1, MAX_CELLS) and int(m.rows, 1, MAX_CELLS) and int(m.x, 0, MAX_CELLS)
            and int(m.y, 0, MAX_CELLS) and int(m.w, 1, MAX_CELLS) and int(m.h, 1, MAX_CELLS)) then return nil end
        local cols, rows, x, y, w, h = toint(m.cols), toint(m.rows), toint(m.x), toint(m.y), toint(m.w), toint(m.h)
        return math.max(0, (x * GRID) // cols - 1), math.max(0, (y * GRID) // rows - 1),
            math.min(GRID, -((-(x + w) * GRID) // cols) + 1), math.min(GRID, -((-(y + h) * GRID) // rows) + 1)
    end
    if type(aspect) ~= 'number' or aspect ~= aspect then aspect = 1 end
    aspect = math.max(0.1, math.min(10, aspect))
    if spec.body == 'text' or spec.body == 'image' then return codec.objectBox(op, aspect) end
    if spec.body ~= 'points' then
        if op.kind == 'clear' then return 0, 0, GRID, GRID end
        return nil
    end
    local pts = op.points
    if type(pts) ~= 'table' or #pts < 2 then return nil end
    local x0, y0, x1, y1 = pts[1], pts[2], pts[1], pts[2]
    for i = 3, #pts, 2 do
        local x, y = pts[i], pts[i + 1]
        if x < x0 then x0 = x elseif x > x1 then x1 = x end
        if y < y0 then y0 = y elseif y > y1 then y1 = y end
    end
    local half = op.width / 16
    if op.kind == 'arrow' then half = math.max(half, op.width * ARROW_HEAD / 8, ARROW_MIN) end
    local gx = half * 4095 / REFERENCE
    local mx, my = ceil(gx) + 1, ceil(gx * aspect) + 1
    return math.max(0, x0 - mx), math.max(0, y0 - my), math.min(GRID, x1 + mx), math.min(GRID, y1 + my)
end

-- Ramer-Douglas-Peucker on grid points { x, y, ... }: points closer than eps texture px (default 0.5) to the segment
-- between the kept ones go. w, h: the raster the page is drawn at (default 2048 x 2048). Repeats go first.
function codec.simplify(points, eps, w, h)
    eps, w, h = eps or 0.5, w or 2048, h or 2048
    local xs, ys, n = {}, {}, 0
    for i = 1, #points - 1, 2 do
        local x, y = points[i], points[i + 1]
        if n == 0 or x ~= xs[n] or y ~= ys[n] then
            n = n + 1
            xs[n], ys[n] = x, y
        end
    end
    local keep = { [1] = true, [n] = true }
    if n > 2 then
        local sx, sy, limit = w / 4095, h / 4095, eps * eps
        local stack, top = { 1, n }, 2
        while top > 0 do
            local i, j = stack[top - 1], stack[top]
            top = top - 2
            local ax, ay = (xs[j] - xs[i]) * sx, (ys[j] - ys[i]) * sy
            local len2 = ax * ax + ay * ay
            local best, at = -1, nil
            for k = i + 1, j - 1 do
                local px, py = (xs[k] - xs[i]) * sx, (ys[k] - ys[i]) * sy
                local dot = px * ax + py * ay
                local d2
                if dot <= 0 then
                    d2 = px * px + py * py
                elseif dot >= len2 then
                    local qx, qy = px - ax, py - ay
                    d2 = qx * qx + qy * qy
                else
                    local cross = ax * py - ay * px
                    d2 = cross * cross / len2
                end
                if d2 > best then best, at = d2, k end
            end
            if at and best > limit then
                keep[at] = true
                stack[top + 1], stack[top + 2], stack[top + 3], stack[top + 4] = i, at, at, j
                top = top + 4
            end
        end
    end
    local out = {}
    for i = 1, n do
        if keep[i] then
            out[#out + 1] = xs[i]
            out[#out + 1] = ys[i]
        end
    end
    return out
end

local function copy(op, extra)
    local out = {}
    for k, v in pairs(op) do out[k] = v end
    for k, v in pairs(extra) do out[k] = v end
    return out
end

-- An op that may be too long, as ops that fit: a stroke in pieces of <= 4096 points and 12 KB, each next one starting
-- at the last point of the one before and flagged CONT; del/undel in lists of <= 256 targets. Or nil and the reason.
function codec.split(op)
    local spec = type(op) == 'table' and SPEC[op.kind]
    if not spec then return nil, 'kind' end
    if spec.body == 'targets' then
        if (op.seqs ~= nil and type(op.seqs) ~= 'table') or (op.cks ~= nil and type(op.cks) ~= 'table') then return nil, 'targets' end
        local all = {}
        for _, s in ipairs(op.seqs or {}) do all[#all + 1] = { s } end
        for _, ck in ipairs(op.cks or {}) do all[#all + 1] = { nil, ck } end
        local out = {}
        for first = 1, math.max(1, #all), MAX_TARGETS do
            local seqs, cks = {}, {}
            for i = first, math.min(#all, first + MAX_TARGETS - 1) do
                if all[i][2] then cks[#cks + 1] = all[i][2] else seqs[#seqs + 1] = all[i][1] end
            end
            out[#out + 1] = copy(op, { seqs = seqs, cks = cks })
        end
        for _, part in ipairs(out) do
            local reason = codec.check(part)
            if reason then return nil, reason end
        end
        return out
    end
    if spec.body ~= 'points' or spec.shape then
        local reason = codec.check(op)
        if reason then return nil, reason end
        return { copy(op, {}) }
    end
    local pts = op.points
    if type(pts) ~= 'table' or #pts < 2 or #pts % 2 ~= 0 then return nil, 'count' end
    for i = 1, #pts do
        if not int(pts[i], 0, GRID) then return nil, 'coord' end
    end
    local total = #pts // 2
    local out, start = {}, 1
    while true do
        local count, deltas, i = 1, 0, start
        while i < total do
            local step = vsize(zigzag(pts[i * 2 + 1] - pts[i * 2 - 1])) + vsize(zigzag(pts[i * 2 + 2] - pts[i * 2]))
            if count + 1 > MAX_POINTS or 13 + vsize(count + 1) + deltas + step > MAX_RAW then break end
            count, deltas, i = count + 1, deltas + step, i + 1
        end
        local piece = table.move(pts, start * 2 - 1, i * 2, 1, {})
        local flags = #out == 0 and (op.flags or 0) or ((op.flags or 0) | F.CONT)
        out[#out + 1] = copy(op, { points = piece, flags = flags })
        if i >= total then break end
        start = i
    end
    for _, part in ipairs(out) do
        local reason = codec.check(part)
        if reason then return nil, reason end
    end
    return out
end

Ink.codec = codec
return codec
