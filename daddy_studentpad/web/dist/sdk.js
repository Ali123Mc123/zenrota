/* Student Tablet SDK for apps other resources add (AddApp). Load it in the app's page:
   <script src="https://cfx-nui-daddy_studentpad/web/dist/sdk.js"></script>
   Every call returns a promise; a call the server refuses rejects with an Error whose message is the reason
   ('rate_limited', 'app_error'...). window.tablet.on(event, fn) hears 'message' (SendAppMessage), 'theme'
   ('light' | 'dark') and 'lang' ('en', 'tr'...). Esc in the page goes back to the home screen. */
;(function () {
  var seq = 0
  var waiting = {}
  var listeners = {}
  var root = document.documentElement

  function ask(method, args) {
    return new Promise(function (resolve, reject) {
      var id = ++seq
      waiting[id] = { resolve: resolve, reject: reject }
      parent.postMessage({ __tablet: 1, id: id, method: method, args: args || {} }, '*')
    })
  }

  // Only the tablet around the page speaks to it.
  window.addEventListener('message', function (e) {
    var msg = e.data
    if (e.source !== parent || !msg || msg.__tablet !== 1) return
    if (msg.event) {
      if (msg.event === 'theme') root.dataset.theme = msg.data
      if (msg.event === 'lang') root.lang = msg.data
      ;(listeners[msg.event] || []).forEach(function (fn) {
        fn(msg.data)
      })
      return
    }
    var w = waiting[msg.id]
    if (!w) return
    delete waiting[msg.id]
    if (msg.error) w.reject(new Error(msg.error))
    else w.resolve(msg.result)
  })

  // Esc lets go of a text field first, then goes home.
  window.addEventListener('keydown', function (e) {
    if (e.key !== 'Escape') return
    var el = document.activeElement
    if (el && (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA' || el.isContentEditable)) return el.blur()
    ask('back')
  })

  window.tablet = {
    /** { app, name, theme: 'light'|'dark', lang }; also sets <html data-theme> and <html lang>. */
    ready: function () {
      return ask('ready').then(function (info) {
        root.dataset.theme = info.theme
        root.lang = info.lang
        return info
      })
    },
    /** The tablet's own alert with one or two buttons; resolves with the index pressed (-1 when it went away). */
    alert: function (title, message, buttons) {
      return ask('alert', { title: title, message: message, buttons: buttons })
    },
    /** A short note (up to 60 characters) in the tablet's toast capsule. */
    toast: function (text) {
      return ask('toast', { text: text })
    },
    /** Closes this app (goes home). */
    close: function () {
      return ask('close')
    },
    /** Runs the app's rpc handler on the server: rpc(source, name, data); resolves with what it returns. */
    callServer: function (name, data) {
      return ask('callServer', { name: name, data: data })
    },
    on: function (event, fn) {
      ;(listeners[event] = listeners[event] || []).push(fn)
    },
  }
})()
