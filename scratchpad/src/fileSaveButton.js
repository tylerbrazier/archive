$(document).ready( () => {
  var button = $('#fileSave')

  $(document).on({
    'file:modified': () => {
      setButtonStyle('warning')
    },
    'file:saving': () => {
      // disable to prevent user from sending many requests
      button.prop('disabled', true)
    },
    'file:saved': () => {
      setButtonStyle('success')
      button.prop('disabled', false)
    },
    'app:error': () => {
      // re-enable the button in case the api responded with an error
      button.prop('disabled', false)
    },
  })

  // style should be either 'success' or 'warning'
  function setButtonStyle(style) {
    button.removeClass('btn-success btn-warning').addClass('btn-'+style)
  }
})
