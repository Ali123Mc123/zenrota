/* Loads the page's files (data-load) with the page's own ?v= stamp, so CEF never runs an old copy.
   This file is never versioned itself: change it only by giving it a new name. */
(function () {
  var stamp = encodeURIComponent((location.search.match(/[?&]v=([^&#]+)/) || [])[1] || '0')
  var files = (document.currentScript.getAttribute('data-load') || '').split(/\s+/)
  for (var i = 0; i < files.length; i++) {
    if (!files[i]) continue
    var url = files[i] + '?v=' + stamp
    if (/\.css$/.test(files[i])) document.write('<link rel="stylesheet" href="' + url + '" />')
    else document.write('<script src="' + url + '"><\/script>')
  }
})()
