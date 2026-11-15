/* Paint surface DUI page. Lua posts messages; only those with this page's nonce are accepted. */
(function () {
  var NONCE = location.hash.slice(1)
  var REFERENCE_WIDTH = 680
  var SOFT_DEFAULTS = { brush: 0.45, marker: 0.85 }

  var surface = document.getElementById('surface')
  var preview = document.getElementById('preview')
  var ctx = surface.getContext('2d')
  var previewCtx = preview.getContext('2d')
  var background = '#ffffff'
  var strokes = []
  var replayToken = 0
  var replaying = false
  var pending = []

  var Paint = (window.Paint = { text: {} })

  function clamp01(v) { return v < 0 ? 0 : v > 1 ? 1 : v }

  function size(width, height) {
    surface.width = preview.width = Math.max(1, width | 0)
    surface.height = preview.height = Math.max(1, height | 0)
    ctx = surface.getContext('2d')
    previewCtx = preview.getContext('2d')
  }

  /* The board's colour is the page's own background under a canvas that stays transparent: media shows through
     without a redraw, and the eraser always cuts back to whatever is underneath. */
  function backdrop(on) {
    document.body.style.background = on && background && background !== 'transparent' ? background : 'transparent'
  }
  Paint.backdrop = backdrop

  function paintBackground() {
    ctx.clearRect(0, 0, surface.width, surface.height)
  }

  function opacityOf(stroke) { return clamp01(Math.max(0.05, typeof stroke.opacity === 'number' ? stroke.opacity : 1)) }

  function hardnessOf(stroke) {
    if (typeof stroke.hardness === 'number') return clamp01(stroke.hardness)
    return SOFT_DEFAULTS[stroke.tool] || 1
  }

  function style(target, stroke) {
    target.lineCap = 'round'
    target.lineJoin = 'round'
    if (stroke.tool === 'eraser') {
      target.globalAlpha = 1
      target.globalCompositeOperation = 'destination-out'
      target.strokeStyle = target.fillStyle = '#000'
      return
    }
    var alpha = opacityOf(stroke)
    if (stroke.tool === 'marker') alpha = Math.min(alpha, 0.45)
    if (stroke.tool === 'brush') alpha = Math.min(alpha, 0.72)
    target.globalCompositeOperation = 'source-over'
    target.strokeStyle = target.fillStyle = stroke.color || '#1f2229'
    target.globalAlpha = alpha
  }

  function px(point) {
    return { x: point[0] * surface.width, y: point[1] * surface.height, p: typeof point[2] === 'number' ? point[2] : 0.5 }
  }

  function dot(target, x, y, radius) {
    target.beginPath()
    target.arc(x, y, Math.max(0.5, radius), 0, Math.PI * 2)
    target.fill()
  }

  /* Soft brushes stamp fading layers along the path. */
  function stamp(target, x, y, radius, hardness) {
    var layers = Math.max(1, Math.round(3 + (1 - hardness) * 5))
    var alpha = target.globalAlpha
    for (var i = layers; i >= 1; i--) {
      var t = i / layers
      target.globalAlpha = alpha * (hardness * 0.55 + (1 - t) * (1 - hardness) * 0.85)
      dot(target, x, y, radius * (0.35 + t * 0.65))
    }
    target.globalAlpha = alpha
  }

  function polyline(target, stroke, soft) {
    var scale = surface.width / REFERENCE_WIDTH
    var hardness = hardnessOf(stroke)
    var points = stroke.points
    if (points.length === 1) {
      var only = px(points[0])
      var r = stroke.width * (0.72 + Math.max(0.05, only.p) * 0.36) * scale * 0.5
      return soft ? stamp(target, only.x, only.y, r, hardness) : dot(target, only.x, only.y, r)
    }
    for (var i = 1; i < points.length; i++) {
      var a = px(points[i - 1])
      var b = px(points[i])
      var width = stroke.width * (0.72 + Math.max(0.05, b.p) * 0.36) * scale
      if (!soft) {
        target.beginPath()
        target.moveTo(a.x, a.y)
        target.lineTo(b.x, b.y)
        target.lineWidth = width
        target.stroke()
        continue
      }
      var steps = Math.max(1, Math.ceil(Math.hypot(b.x - a.x, b.y - a.y) / Math.max(1.5, width * (0.25 + hardness * 0.35))))
      for (var s = 0; s <= steps; s++) {
        var t = s / steps
        stamp(target, a.x + (b.x - a.x) * t, a.y + (b.y - a.y) * t, width * 0.5, hardness)
      }
    }
  }

  function shape(target, stroke) {
    var a = px(stroke.points[0])
    var b = px(stroke.points[stroke.points.length - 1])
    target.lineWidth = Math.max(1, stroke.width * surface.width / REFERENCE_WIDTH)
    target.beginPath()
    if (stroke.tool === 'line') {
      target.moveTo(a.x, a.y)
      target.lineTo(b.x, b.y)
    } else if (stroke.tool === 'rect') {
      target.rect(Math.min(a.x, b.x), Math.min(a.y, b.y), Math.abs(b.x - a.x), Math.abs(b.y - a.y))
    } else {
      target.ellipse((a.x + b.x) / 2, (a.y + b.y) / 2, Math.max(0.5, Math.abs(b.x - a.x) / 2), Math.max(0.5, Math.abs(b.y - a.y) / 2), 0, 0, Math.PI * 2)
    }
    target.stroke()
  }

  function render(target, stroke) {
    if (!stroke || !stroke.points || !stroke.points.length) return
    target.save()
    if (stroke.tool === 'fill') {
      target.globalAlpha = opacityOf(stroke)
      target.fillStyle = stroke.color || '#1f2229'
      target.fillRect(0, 0, surface.width, surface.height)
    } else {
      style(target, stroke)
      if (stroke.tool === 'line' || stroke.tool === 'rect' || stroke.tool === 'circle') shape(target, stroke)
      else polyline(target, stroke, stroke.tool === 'brush')
    }
    target.restore()
  }

  function clearPreview() { previewCtx.clearRect(0, 0, preview.width, preview.height) }

  /* Long lists replay in 4 ms slices so the page never stalls. */
  function replay() {
    var token = ++replayToken
    var index = 0
    var list = strokes.slice()
    replaying = true
    pending = []
    paintBackground()
    clearPreview()
    function slice() {
      if (token !== replayToken) return
      var started = performance.now()
      while (index < list.length && performance.now() - started < 4) render(ctx, list[index++])
      if (index < list.length) return requestAnimationFrame(slice)
      replaying = false
      var queued = pending
      pending = []
      for (var i = 0; i < queued.length; i++) render(ctx, queued[i])
    }
    requestAnimationFrame(slice)
  }

  function append(stroke) {
    strokes.push(stroke)
    if (replaying) pending.push(stroke)
    else render(ctx, stroke)
  }

  Paint.redraw = replay
  Paint.size = function () { return { width: surface.width, height: surface.height } }

  var handlers = {
    init: function (m) {
      size(m.width, m.height)
      background = m.background || 'transparent'
      backdrop(true)
      Paint.text = m.text || {}
      strokes = Array.isArray(m.strokes) ? m.strokes.slice() : []
      if (Paint.onInit) Paint.onInit(m)
      replay()
    },
    append: function (m) { append(m.stroke) },
    commit: function (m) { clearPreview(); append(m.stroke) },
    replace: function (m) { strokes = Array.isArray(m.strokes) ? m.strokes.slice() : []; replay() },
    preview: function (m) {
      if (m.kind !== 'append') clearPreview()
      if (m.kind === 'append' || m.kind === 'set') render(previewCtx, m.stroke)
    },
  }

  window.addEventListener('message', function (event) {
    var m = event.data
    if (!m || m.nonce !== NONCE || typeof m.type !== 'string') return
    if (handlers[m.type]) return handlers[m.type](m)
    if (Paint.onMessage) Paint.onMessage(m)
  })

  size(1024, 1024)
  paintBackground()
})()
