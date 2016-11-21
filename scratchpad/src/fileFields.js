$(document).ready( () => {
  var nameField = $('#fileName')
  var contentField = $('#fileContent')

  $(document).on({
    'file:loaded': (event, fileName, fileContent) => {
      nameField.val(fileName).attr('data-originalName', fileName)
      contentField.val(fileContent)
    },
    'file:saving': () => {
      // don't allow user to change things while the request is in flight
      $('.field').prop('disabled', true)
    },
    'file:saved app:error': () => {
      // re-enable the fields after the request came back
      $('.field').prop('disabled', false)
    },
    'file:saved': (event, fileName) => {
      // update originalName
      nameField.attr('data-originalName', fileName)
    },
  })
})
