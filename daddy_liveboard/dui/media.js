/* The media layer of a board page: a picture (or a video's cover) under the drawing, and a card for "finished", an
   error or a slow connection. Videos and sounds play in the media page (web/dist/dui/media.html), drawn 3 mm behind
   this one: then this page only turns see-through ('clear'). Lua sends the layer; texts come from the locale. */
(function () {
  var Paint = window.Paint
  var host = document.getElementById('media')
  var card = document.getElementById('media-status')
  var ink = [document.getElementById('surface'), document.getElementById('preview')]
  var img = null
  var layer = { mode: 'none' }

  function text(key) { return (key && Paint.text[key]) || '' }

  /* The picture keeps its own aspect on a texture that follows the board (cover fills it, stretch ignores it). */
  function layout() {
    if (!img) return
    var size = Paint.size()
    img.style.opacity = String(typeof layer.opacity === 'number' ? layer.opacity : 1)
    if (layer.fit === 'stretch' || !(img.naturalWidth > 0)) {
      img.style.left = img.style.top = '0px'
      img.style.width = size.width + 'px'
      img.style.height = size.height + 'px'
      return
    }
    var aspect = img.naturalWidth / img.naturalHeight
    var wider = aspect > size.width / size.height
    var w, h
    if (layer.fit === 'cover' ? !wider : wider) { w = size.width; h = size.width / aspect } else { h = size.height; w = size.height * aspect }
    img.style.width = Math.round(w) + 'px'
    img.style.height = Math.round(h) + 'px'
    img.style.left = Math.round((size.width - w) / 2) + 'px'
    img.style.top = Math.round((size.height - h) / 2) + 'px'
  }

  function picture(url) {
    if (img && img.getAttribute('src') === url) return layout()
    if (img && img.parentNode) img.parentNode.removeChild(img)
    img = null
    if (!url) return
    img = document.createElement('img')
    img.decoding = 'async'
    img.referrerPolicy = 'no-referrer'
    img.onload = layout
    img.onerror = function () { showCard({ key: 'image_failed' }) }
    host.insertBefore(img, card)
    img.src = url
  }

  /* { key, title }: the key's text, the item's name under it. */
  function showCard(c) {
    var line = c ? text(c.key) : ''
    var title = c && c.title ? String(c.title) : ''
    card.textContent = ''
    if (line) card.appendChild(document.createTextNode(line))
    if (title) {
      var small = document.createElement('small')
      small.textContent = title
      card.appendChild(small)
    }
    card.classList.toggle('on', !!(line || title))
  }

  /* none: the board's colour; image: a picture on it; clear: see-through, the media page shows from behind.
     hideInk: the strokes alone hide (the screen's ink is off, or a player that allows nothing over it runs behind);
     the picture and the card stay. */
  function apply(next) {
    layer = next && typeof next === 'object' ? next : { mode: 'none' }
    if (Paint.backdrop) Paint.backdrop(layer.mode !== 'clear')
    for (var i = 0; i < ink.length; i++) if (ink[i]) ink[i].style.visibility = layer.hideInk ? 'hidden' : ''
    picture(layer.mode === 'image' ? layer.url : null)
    layout()
    showCard(layer.card)
  }

  Paint.onInit = function (m) { apply(m.layer) }
  Paint.onMessage = function (m) {
    if (m.type === 'media:layer') apply(m.layer)
  }
})()
