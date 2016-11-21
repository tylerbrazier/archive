// logic related to the save button on the settings page
$(document).ready( () => {

  var tokenField = $('#tokenField')
  var gistField = $('#gistField')
  var button = $('#saveSettings')

  //when the fields change, recolor the save button to indicate unsaved changes
  tokenField.on('change keyup paste', (event) => setButtonStyle('warning'))
  gistField.on('change keyup paste', (event) => setButtonStyle('warning'))

  button.on('click', (event) => {
    localStorage.setItem('token', tokenField.val())
    localStorage.setItem('gistId', extractIdFromGistField())
    setButtonStyle('success')
  })

  // style should be either 'success' or 'warning'
  function setButtonStyle(style) {
    button.removeClass('btn-success btn-warning').addClass('btn-'+style)
  }

  // user can paste the gist url in the field but we just want the id
  function extractIdFromGistField() {
    var text = gistField.val()
    return (!text ? '' : text.substring(text.lastIndexOf('/')+1))
  }
})
