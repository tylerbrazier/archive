$(document).on('gist:loaded', (event, json) => {
  $('title, #heading').text(json.description)
})
