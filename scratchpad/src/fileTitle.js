$(document).on({
  'file:loaded': (event, fileName) => $('title').text(fileName),
  'file:saved': (event, fileName) => $('title').text(fileName),
})
