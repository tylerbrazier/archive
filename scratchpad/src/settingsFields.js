$(document).ready( () => {
  var token = localStorage.getItem('token')
  if (token)
    $('#tokenField').val(token)

  var gistId = localStorage.getItem('gistId')
  if (gistId)
    $('#gistField').val(gistId)
})
