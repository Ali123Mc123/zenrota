/* Student Phone SDK for apps other resources add (AddApp). Load it in the app's page:
   <script src="https://cfx-nui-daddy_studentphone/web/dist/sdk.js"></script>
   Every call returns a promise; a call the server refuses rejects with an Error whose message is the reason
   ('rate_limited', 'no_permission', 'app_error'...). window.phone.on(event, fn) hears 'message' (SendAppMessage),
   'theme' ('light' | 'dark'), 'lang' ('en', 'tr'...), 'open' ({ route }: the data of the app's notification the player
   tapped, Notify export), 'orientation' ('landscape' or 'portrait'; an app added with orientation = 'any' turns with the
   phone), and in a widget 'widget:init' ({ size, theme, editing }) and 'widget:editing' (true while the home screen is
   edited). Text fields stop the game keys while they have focus, and Esc goes back, as in the phone's own apps. */
;(function () {
  var seq = 0
  var waiting = {}
  var listeners = {}
  var root = document.documentElement

  function ask(method, args) {
    return new Promise(function (resolve, reject) {
      var id = ++seq
      waiting[id] = { resolve: resolve, reject: reject }
      parent.postMessage({ __phone: 1, id: id, method: method, args: args || {} }, '*')
    })
  }

  // A call nobody waits for (the reply to id 0 is dropped).
  function tell(method, args) {
    parent.postMessage({ __phone: 1, id: 0, method: method, args: args || {} }, '*')
  }

  // Only the phone around the page speaks to it.
  window.addEventListener('message', function (e) {
    var msg = e.data
    if (e.source !== parent || !msg || msg.__phone !== 1) return
    if (msg.event) {
      if (msg.event === 'theme') root.dataset.theme = msg.data
      if (msg.event === 'lang') root.lang = msg.data
      if (msg.event === 'widget:init') root.dataset.theme = msg.data.theme
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

  // A field the player types in: an input that takes text, a text area or editable content.
  var NOT_TEXT = /^(checkbox|radio|button|submit|reset|range|color|file|image)$/
  function field(el) {
    if (!el || el.nodeType !== 1) return false
    if (el.tagName === 'INPUT') return !NOT_TEXT.test(el.type)
    return el.tagName === 'TEXTAREA' || el.isContentEditable
  }
  document.addEventListener('focusin', function (e) {
    if (field(e.target)) tell('typing', { on: true })
  })
  document.addEventListener('focusout', function (e) {
    if (field(e.target)) tell('typing', { on: false })
  })
  // Esc lets go of a field first, then steps back (the app goes home).
  window.addEventListener('keydown', function (e) {
    if (e.key !== 'Escape') return
    if (field(document.activeElement)) return document.activeElement.blur()
    tell('back')
  })

  window.phone = {
    /** { app, name, theme: 'light'|'dark', lang, orientation, safe: { top, bottom }, widget: { size } | null }; also sets
        <html data-theme> and <html lang>. */
    ready: function () {
      return ask('ready').then(function (info) {
        root.dataset.theme = info.theme
        root.lang = info.lang
        return info
      })
    },
    /** The phone's own alert (up to 3 buttons); resolves with the index of the button pressed (-1 when it went away). Not in widgets. */
    alert: function (title, message, buttons) {
      return ask('alert', { title: title, message: message, buttons: buttons })
    },
    /** An action sheet (up to 8 items); resolves with the index picked, -1 when cancelled. Not in widgets. */
    menu: function (title, items) {
      return ask('menu', { title: title, items: items })
    },
    /** A sheet of text fields: { title, message, fields: [{ key, label, placeholder, value }] } (up to 6). Resolves
        with the values by key ({ drink: 'Mocha' }), or null when the player closed it. Not in widgets. */
    sheet: function (options) {
      return ask('sheet', options || {})
    },
    /** A short note (up to 60 characters) in the phone's toast capsule, like "Saved". Not in widgets. */
    toast: function (text) {
      return ask('toast', { text: text })
    },
    /** A notification that stays in the notification center (needs 'notifications'); resolves true when sent. Not in widgets. */
    notify: function (title, body) {
      return ask('notify', { title: title, body: body })
    },
    /** Not in widgets. */
    openApp: function (id) {
      return ask('openApp', { id: id })
    },
    /** Closes this app (goes home). Not in widgets. */
    close: function () {
      return ask('close')
    },
    /** A light status bar (top) and home indicator (bottom) over a dark page: bars({ top: true, bottom: true }).
        false gives them back to the theme. They reset when the app closes. Not in widgets. */
    bars: function (options) {
      return ask('bars', options || {})
    },
    /** Runs the app's rpc handler on the server: rpc(source, name, data). */
    callServer: function (name, data) {
      return ask('callServer', { name: name, data: data })
    },
    /** Up to 50 string values per player, kept on the server. set(key, null) removes one. */
    storage: {
      get: function (key) {
        return ask('storage.get', { key: key })
      },
      set: function (key, value) {
        return ask('storage.set', { key: key, value: value == null ? null : String(value) })
      },
    },
    /** Asks the player once for a permission the app listed in AddApp: 'contacts.read', 'location', 'notifications',
        'nearby', 'messages.send', 'wallet.read'. Resolves true or false; a refusal stays until the player changes it in
        Settings > Privacy & Security. A widget never asks; it only learns whether the app has the permission. */
    permission: function (perm) {
      return ask('permission', { perm: perm })
    },
    /** [{ name, number }] (needs 'contacts.read'). */
    contacts: function () {
      return ask('contacts')
    },
    /** { x, y, z, heading } (needs 'location'). */
    location: function () {
      return ask('location')
    },
    /** Players close by (needs 'nearby'). */
    nearby: function () {
      return ask('nearby')
    },
    /** The student ID: { name, school, number, program, kind, year, valid } (needs 'wallet.read'). */
    wallet: function () {
      return ask('wallet')
    },
    /** Sends a message as the player (needs 'messages.send'), only while the app is on screen. to: one of the player's
        chats ('class:<name>', 'club:<name>', 'group:<id>') or a citizenid for a direct chat. Resolves true when sent.
        Not in widgets. */
    sendMessage: function (to, text) {
      return ask('sendMessage', { to: to, text: text })
    },
    on: function (event, fn) {
      ;(listeners[event] = listeners[event] || []).push(fn)
    },
  }
})()
