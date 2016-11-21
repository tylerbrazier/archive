$(document).ready( () => {
  var list = $('#list')
  list.html('<p>Loading files...</p>')

  $(document).on({
    'gist:loaded': (event, json) => {
      var ul = $('<ul></ul>')
      Object.keys(json.files).forEach(f => {
        ul.append(`<li><a href="file.html#${f}">${f}</a></li>`)
      })
      list.html(ul)
    },
    'app:error': () => list.html('<p>Failed to load files</p>')
  })
})
