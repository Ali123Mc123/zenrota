/* Photo mode in the garage family's look: a column on the right (lens, filter, scene, photos) and a low bar (the filter
   on the arrow keys, the hints). Pictures come straight from the game's frame (never the page), go to Fivemanage
   through a one-time address from the server, and the server checks them before keeping them. */
'use strict'

const inGame = typeof window.GetParentResourceName === 'function'
const RESOURCE = inGame ? window.GetParentResourceName() : 'daddy_photocam'
const stageEl = document.getElementById('stage')
const flashEl = document.getElementById('flash')

const ICONS = {
  camera: '<path class="f" d="M3 9a2 2 0 0 1 2-2h2.5L9 4.5h6L16.5 7H19a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><path d="M3 9a2 2 0 0 1 2-2h2.5L9 4.5h6L16.5 7H19a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><circle cx="12" cy="13" r="3.5"/>',
  grid: '<rect x="3.5" y="3.5" width="7" height="7" rx="1.5"/><rect x="13.5" y="3.5" width="7" height="7" rx="1.5"/><rect x="3.5" y="13.5" width="7" height="7" rx="1.5"/><rect x="13.5" y="13.5" width="7" height="7" rx="1.5"/>',
  hide: '<path d="M3 3l18 18"/><path d="M10.6 10.6a2 2 0 0 0 2.8 2.8"/><path d="M16.7 16.7A8.7 8.7 0 0 1 12 18c-3.6 0-6.6-2-9-6 1.3-2.1 2.7-3.7 4.3-4.7m2.9-1.1A9 9 0 0 1 12 6c3.6 0 6.6 2 9 6-.7 1.1-1.4 2.1-2.1 2.9"/>',
}
const icon = (name, size = 20) => `<svg class="p-ico" viewBox="0 0 24 24" width="${size}" height="${size}">${ICONS[name]}</svg>`
const LR = '<svg class="p-ico" viewBox="0 0 30 12" width="17" height="7"><path d="M6 2 2 6l4 4M2 6h9M24 2l4 4-4 4M28 6h-9"/></svg>'
const key = (k) => `<span class="key">${k === 'lr' ? LR : esc(k)}</span>`
// A mouse on a keycap, the part to use filled: 'right' (right button) or 'wheel'.
const MOUSE_PART = {
  right: '<path class="hot" d="M12 3a5.5 5.5 0 0 1 5.5 5.5V10H12z"/>',
  wheel: '<rect class="hot" x="10.4" y="5" width="3.2" height="5" rx="1.6"/>',
}
const mouse = (part) => `<span class="key mouse-key"><svg class="p-ico" viewBox="0 0 24 24" width="19" height="19">${MOUSE_PART[part]}<path d="M6.5 8.5a5.5 5.5 0 0 1 11 0v7a5.5 5.5 0 0 1-11 0z"/><path d="M6.5 10h11"/><path d="M12 3v7"/></svg></span>`

const state = {
  open: false, shown: false, tab: 'lens', busy: false,
  locale: {}, filters: [], weathers: [], phone: false, tiltKeys: ['R', 'F'],
  cam: { fov: 50, roll: 0, dof: 0, minFov: 25, maxFov: 90, maxRoll: 45 },
  filter: 'none', strength: 1, weather: null, hour: null,
  photos: [], selected: null,
}

function t(path, ...args) {
  let node = state.locale
  for (const part of path.split('.')) node = node && node[part]
  if (typeof node !== 'string') return ''
  let i = 0
  return node.replace(/%%|%[sd]/g, (m) => (m === '%%' ? '%' : String(args[i++] ?? '')))
}

function esc(s) {
  return String(s).replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`)
}

async function nui(name, data = {}) {
  if (!inGame) return {}
  try {
    const res = await fetch(`https://${RESOURCE}/${name}`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(data) })
    const text = await res.text()
    return text ? JSON.parse(text) : {}
  } catch {
    return {}
  }
}

/* ---- the game's frame (WebGL texture FiveM fills with the last game frame; the page is never in it) ---- */
let gl = null
let glCanvas = null
function setupGl() {
  if (gl) return true
  glCanvas = document.createElement('canvas')
  gl = glCanvas.getContext('webgl', { preserveDrawingBuffer: true, alpha: false })
  if (!gl) return false
  const compile = (type, src) => { const s = gl.createShader(type); gl.shaderSource(s, src); gl.compileShader(s); return s }
  const program = gl.createProgram()
  gl.attachShader(program, compile(gl.VERTEX_SHADER, 'attribute vec2 p;varying vec2 uv;void main(){uv=vec2(p.x*.5+.5,p.y*.5+.5);gl_Position=vec4(p,0.,1.);}'))
  gl.attachShader(program, compile(gl.FRAGMENT_SHADER, 'precision mediump float;uniform sampler2D g;varying vec2 uv;void main(){gl_FragColor=vec4(texture2D(g,uv).rgb,1.);}'))
  gl.linkProgram(program)
  gl.useProgram(program)
  gl.bindBuffer(gl.ARRAY_BUFFER, gl.createBuffer())
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([-1, -1, 1, -1, -1, 1, 1, 1]), gl.STATIC_DRAW)
  const at = gl.getAttribLocation(program, 'p')
  gl.enableVertexAttribArray(at)
  gl.vertexAttribPointer(at, 2, gl.FLOAT, false, 0, 0)
  // The wrap mode set clamp, mirrored, repeat binds the game's frame (rows bottom up, which this quad reads upright).
  gl.bindTexture(gl.TEXTURE_2D, gl.createTexture())
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR)
  gl.texParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.CLAMP_TO_EDGE)
  gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGB, 1, 1, 0, gl.RGB, gl.UNSIGNED_BYTE, new Uint8Array(3))
  gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.CLAMP_TO_EDGE)
  gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.MIRRORED_REPEAT)
  gl.texParameterf(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT)
  return true
}

function draw(width, height) {
  glCanvas.width = width
  glCanvas.height = height
  gl.viewport(0, 0, width, height)
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4)
}

// The very first read of a session is black until the game starts copying frames: wait for a lit one.
async function litFrame() {
  for (let i = 0; i < 30; i++) {
    draw(16, 9)
    const px = new Uint8Array(16 * 9 * 4)
    gl.readPixels(0, 0, 16, 9, gl.RGBA, gl.UNSIGNED_BYTE, px)
    let sum = 0
    for (let p = 0; p < px.length; p += 4) sum += px[p] + px[p + 1] + px[p + 2]
    if (sum / (16 * 9 * 3) > 1) return true
    await new Promise((r) => setTimeout(r, 100))
  }
  return false
}

function toJpeg(width, height, quality) {
  draw(width, height)
  return glCanvas.toDataURL('image/jpeg', quality)
}

function thumbOf(width, height) {
  for (const q of [0.7, 0.55, 0.4]) {
    const data = toJpeg(width, height, q)
    if (data.length <= 24000) return data
  }
  return toJpeg(Math.round(width / 2), Math.round(height / 2), 0.6)
}

function dataBlob(data) {
  const bin = atob(data.split(',')[1])
  const out = new Uint8Array(bin.length)
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i)
  return new Blob([out], { type: 'image/jpeg' })
}

async function shoot() {
  if (state.busy || !state.open || !inGame) return
  if (!setupGl()) return nui('failed', { err: 'upload' })
  state.busy = true
  render()
  try {
    const sheet = await nui('presign')
    if (!sheet.ok) return
    if (!(await litFrame())) return nui('failed', { err: 'empty' })
    const ratio = window.innerHeight / window.innerWidth
    const w = Math.min(sheet.width || 1920, window.innerWidth)
    const h = Math.round(w * ratio)
    const full = toJpeg(w, h, sheet.quality || 0.92)
    const thumb = thumbOf(256, Math.round(256 * ratio))
    flashEl.classList.add('on')
    requestAnimationFrame(() => requestAnimationFrame(() => flashEl.classList.remove('on')))
    const form = new FormData()
    form.append('file', dataBlob(full), 'photo.jpg')
    form.append('path', sheet.folder)
    form.append('metadata', sheet.meta)
    const res = await fetch(sheet.url, { method: 'POST', body: form }).then((r) => r.json()).catch(() => null)
    const url = res && res.data && res.data.url
    if (typeof url !== 'string') return nui('failed', { err: 'upload' })
    const saved = await nui('saved', { id: res.data.id, url, thumb, w, h })
    if (saved.ok && saved.photo) {
      state.photos.unshift(saved.photo)
      state.selected = saved.photo.id
    }
  } finally {
    state.busy = false
    render()
  }
}

/* ---- the column ---- */
const pct = (v, min, max) => `${((v - min) / (max - min)) * 100}%`
const clock = (h) => `${String(Math.floor(h)).padStart(2, '0')}:${String(Math.round((h % 1) * 60)).padStart(2, '0')}`

function slider(name, label, value, min, max, stepSize, shown, mid) {
  return `<div class="field"><div class="top"><span class="lbl">${esc(label)}</span><b class="num" data-out="${name}">${esc(shown)}</b></div>
    <input type="range" class="${mid ? 'mid' : ''}" data-key="${name}" min="${min}" max="${max}" step="${stepSize}" value="${value}" style="--fill:${pct(value, min, max)}"></div>`
}

function lensPane() {
  const c = state.cam
  return slider('fov', t('ui.fov'), c.maxFov + c.minFov - c.fov, c.minFov, c.maxFov, 0.5, `${(50 / c.fov).toFixed(1)}×`)
    + slider('roll', t('ui.roll'), c.roll, -c.maxRoll, c.maxRoll, 0.5, `${Math.round(c.roll)}°`, true)
    + slider('dof', t('ui.dof'), c.dof, 0, 1, 0.01, `${Math.round(c.dof * 100)}%`)
    + `<button class="ghost" data-act="lens-reset">${esc(t('ui.reset'))}</button>`
}

function filterPane() {
  const rows = state.filters.map((f) => `<button class="row" data-on="${state.filter === f.id}" data-filter="${esc(f.id)}">${esc(t('filters.' + f.id) || f.id)}</button>`).join('')
  const strength = state.filter === 'none' ? '' : slider('strength', t('ui.strength'), state.strength, 0, 1, 0.01, `${Math.round(state.strength * 100)}%`)
  return strength + `<div class="rows">${rows}</div>`
}

function scenePane() {
  const chip = (value, label) => `<button class="chip" data-on="${state.weather === value}" data-weather="${value === null ? '' : esc(value)}">${esc(label)}</button>`
  const weathers = chip(null, t('ui.server')) + state.weathers.map((w) => chip(w, t('weathers.' + w) || w)).join('')
  const hour = state.hour === null ? 12 : state.hour
  return `<p class="note">${esc(t('ui.world_note'))}</p>
    <div class="field"><span class="lbl">${esc(t('ui.weather'))}</span><div class="chips">${weathers}</div></div>
    ${slider('hour', t('ui.time'), hour, 0, 23.75, 0.25, state.hour === null ? t('ui.server') : clock(hour))}
    <button class="ghost" data-act="world-reset">${esc(t('ui.reset'))}</button>`
}

function photosPane() {
  if (!state.photos.length) return `<div class="empty">${icon('grid', 32)}${esc(t('ui.empty'))}</div>`
  const grid = state.photos.map((p) => `<button class="shot" data-on="${state.selected === p.id}" data-photo="${p.id}" style="background-image:url('${esc(p.thumb || p.url)}')"></button>`).join('')
  const pick = state.photos.find((p) => p.id === state.selected)
  const acts = pick ? `<div class="acts"><button class="ghost" data-act="copy">${esc(t('ui.copy'))}</button>${state.phone ? `<button class="ghost" data-act="phone">${esc(t('ui.phone'))}</button>` : ''}</div>` : ''
  return `<div class="grid">${grid}</div>${acts}`
}

const PANES = { lens: lensPane, filter: filterPane, world: scenePane, photos: photosPane }

function filterName() {
  return t('filters.' + state.filter) || state.filter
}

function render() {
  const scroll = stageEl.querySelector('.body')?.scrollTop || 0
  const words = Object.keys(PANES).map((k) => `<button data-on="${state.tab === k}" data-tab="${k}">${esc(t('ui.tab_' + k))}</button>`).join('')
  stageEl.innerHTML = `
    <div class="col">
      <div class="head">
        <span class="mark">${icon('camera', 24)}</span>
        <div class="who"><b class="caps">${esc(t('ui.title'))}</b><small class="lbl">${esc(t('ui.path'))}</small></div>
        <div class="tools">
          <button data-act="hide">${icon('hide')}${key('H')}</button>
          <button data-act="close">${key('ESC')}</button>
        </div>
      </div>
      <div class="words">${words}</div>
      <div class="body">${PANES[state.tab]()}</div>
      <div class="foot">
        <button class="go" data-act="shoot" data-dim="${state.busy}"><b>${esc(state.busy ? t('ui.shooting') : t('ui.shoot'))}</b>${key('ENTER')}</button>
      </div>
    </div>
    <div class="bar">
      <div class="look">
        <button data-act="filter-prev">${key('lr')}</button>
        <div class="name"><span class="lbl">${esc(t('ui.tab_filter'))}</span><b class="caps">${esc(filterName())}</b></div>
      </div>
      <div class="hints">
        <span>${mouse('right')}${esc(t('ui.hint_look'))}</span>
        <span>${mouse('wheel')}${esc(t('ui.fov'))}</span>
        <span>${key('WASD')}${esc(t('ui.hint_move'))}</span>
        <span>${key('E')}${key('Q')}${esc(t('ui.hint_up'))}</span>
        <span>${key(state.tiltKeys[0])}${key(state.tiltKeys[1])}${esc(t('ui.roll'))}</span>
      </div>
    </div>`
  const body = stageEl.querySelector('.body')
  if (body) body.scrollTop = scroll
}

function fit() {
  const scale = Math.min(window.innerWidth / 1920, window.innerHeight / 1080)
  stageEl.style.transform = `scale(${scale})`
}
window.addEventListener('resize', fit)

function setShown(shown) {
  state.shown = shown
  stageEl.classList.toggle('on', shown && state.open)
}

async function loadPhotos() {
  const res = await nui('photos')
  if (res && res.ok) state.photos = res.photos || []
  render()
}

function setFilter(id) {
  state.filter = id
  nui('set', { key: 'filter', value: id, strength: state.strength })
  render()
}

function stepFilter(dir) {
  const list = state.filters
  if (!list.length) return
  const at = list.findIndex((f) => f.id === state.filter)
  setFilter(list[(at + dir + list.length) % list.length].id)
}

/* ---- input ---- */
stageEl.addEventListener('input', (e) => {
  const el = e.target
  if (el.type !== 'range') return
  const v = parseFloat(el.value)
  const k = el.dataset.key
  const out = stageEl.querySelector(`[data-out="${k}"]`)
  el.style.setProperty('--fill', pct(v, parseFloat(el.min), parseFloat(el.max)))
  if (k === 'fov') {
    state.cam.fov = state.cam.maxFov + state.cam.minFov - v
    nui('set', { key: 'fov', value: state.cam.fov })
    out.textContent = `${(50 / state.cam.fov).toFixed(1)}×`
  } else if (k === 'roll') {
    state.cam.roll = v
    nui('set', { key: 'roll', value: v })
    out.textContent = `${Math.round(v)}°`
  } else if (k === 'dof' || k === 'strength') {
    if (k === 'dof') { state.cam.dof = v; nui('set', { key: 'dof', value: v }) }
    else { state.strength = v; nui('set', { key: 'filter', value: state.filter, strength: v }) }
    out.textContent = `${Math.round(v * 100)}%`
  } else if (k === 'hour') {
    state.hour = v
    nui('set', { key: 'scene', weather: state.weather, hour: v })
    out.textContent = clock(v)
  }
})

stageEl.addEventListener('click', (e) => {
  const el = e.target.closest('button')
  if (!el) return
  const d = el.dataset
  if (d.tab) { state.tab = d.tab; if (d.tab === 'photos') loadPhotos(); return render() }
  if (d.filter) return setFilter(d.filter)
  if (d.weather !== undefined) { state.weather = d.weather || null; nui('set', { key: 'scene', weather: state.weather, hour: state.hour }); return render() }
  if (d.photo) { state.selected = Number(d.photo); return render() }
  const pick = state.photos.find((p) => p.id === state.selected)
  switch (d.act) {
    case 'shoot': return shoot()
    case 'close': return nui('close')
    case 'hide': setShown(false); return nui('panel', { shown: false })
    case 'filter-prev': return stepFilter(1)
    case 'copy': return pick && nui('copy', { url: pick.url })
    case 'phone': return pick && nui('phone', { id: pick.id })
    case 'lens-reset':
      Object.assign(state.cam, { roll: 0, dof: 0, fov: 50 })
      for (const [name, value] of [['roll', 0], ['dof', 0], ['fov', 50]]) nui('set', { key: name, value })
      return render()
    case 'world-reset':
      state.weather = null; state.hour = null
      nui('set', { key: 'scene', weather: null, hour: null })
      return render()
  }
})

// Right mouse on the game turns the camera; the wheel zooms.
const overUi = (target) => !!(target.closest && target.closest('.col, .bar'))
window.addEventListener('contextmenu', (e) => e.preventDefault())
window.addEventListener('mousedown', (e) => {
  if (e.button === 2 && state.open && !overUi(e.target)) nui('look')
})
window.addEventListener('wheel', async (e) => {
  if (!state.open || overUi(e.target)) return
  const res = await nui('zoom', { delta: e.deltaY > 0 ? 2 : -2 })
  if (res && typeof res.fov === 'number') { state.cam.fov = res.fov; if (state.tab === 'lens') render() }
})
window.addEventListener('keydown', (e) => {
  if (!state.open || !state.shown || e.repeat) return
  if (e.key === 'Escape') nui('close')
  else if (e.key === 'h' || e.key === 'H') { setShown(false); nui('panel', { shown: false }) }
  else if (e.key === 'Enter') { e.preventDefault(); shoot() }
  else if (e.key === 'ArrowLeft') stepFilter(-1)
  else if (e.key === 'ArrowRight') stepFilter(1)
})

/* ---- Lua messages ---- */
window.addEventListener('message', (e) => {
  const m = e.data || {}
  switch (m.action) {
    case 'open':
      Object.assign(state, { open: true, tab: 'lens', busy: false, filter: 'none', strength: 1, weather: null, hour: null, selected: null })
      state.locale = m.locale || {}
      state.filters = m.filters || []
      state.weathers = m.weathers || []
      state.phone = !!m.phone
      if (Array.isArray(m.tiltKeys)) state.tiltKeys = m.tiltKeys
      state.cam = Object.assign(state.cam, m.cam || {})
      if (typeof m.accent === 'string') document.documentElement.style.setProperty('--ac', m.accent)
      document.documentElement.lang = m.language || 'en'
      fit()
      render()
      setShown(!!m.shown)
      break
    case 'panel': setShown(!!m.shown); break
    case 'fov': state.cam.fov = m.value; if (state.shown && state.tab === 'lens') render(); break
    case 'roll': state.cam.roll = m.value; if (state.shown && state.tab === 'lens') render(); break
    case 'filter': stepFilter(m.dir); break
    case 'shoot': shoot(); break
    case 'close':
      state.open = false
      setShown(false)
      break
  }
})
