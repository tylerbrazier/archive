// The purpose of this guy is to interact with the backend api and fire events
// so that the buttons and fields and such don't need to know about each other
// and we don't have everybody making api calls.

// The controller triggers the following events on the document object, which
// the other components can listen for:
// - file:loaded   with extra params fileName and fileContent
// - file:modified when the file name or content has changed
// - file:saving   when the user clicks Save and the request is being sent
// - file:saved    with extra param fileName when save request was successful
// - app:error     with an extra param message string
$(document).ready( () => {

  bindListeners()
  fetchFile()

  function bindListeners() {
    $('.field').on('change keyup paste', () => trigger('file:modified') )

    $('#fileSave').on('click', () => trigger('file:saving') )

    $('#fileDelete').on('click', () => deleteFile() )

    $(document).on({
      'file:saving': () => saveFile(),
      'file:saved': (event, fileName) => location.hash = '#' + fileName,
    })
  }

  function fetchFile() {
    var fileName = location.hash.substring(1)
    if (!fileName)
      return // must be creating a new file; nothing to fetch

    api('GET', null, (err, json) => {
      if (err)
        return trigger('app:error', err)

      var fileObj = json.files[fileName]
      if (!fileObj)
        return trigger('app:error', fileName + ' not found')

      trigger('file:loaded', fileName, fileObj.content)
    })
  }

  function saveFile() {
    var data = { files:{} }
    var nameField = $('#fileName')
    var fileName = nameField.val()
    var originalName = nameField.attr('data-originalName') || fileName
    var content = $('#fileContent').val()

    if (!fileName)
      return trigger('app:error', 'No file name')
    if (!content)
      return trigger('app:error', 'No content')

    data.files[originalName] = { 
      filename: fileName,
      content: content,
    }

    api('PATCH', data, (err, json) => {
      if (err)
        return trigger('app:error', err)
      trigger('file:saved', fileName)
    })
  }

  function deleteFile() {
    var fileName = $('#fileName').attr('data-originalName')
    if (!fileName)
      return trigger('app:error', "This file hasn't been saved yet")

    if (!confirm('Delete this file?'))
      return

    var data = { files:{} }
    data.files[fileName] = null

    api('PATCH', data, (err, json) => {
      if (err)
        return trigger('app:error', err)
      location.href = 'index.html'
    })
  }

  function trigger(eventType, ...params) {
    $(document).trigger(eventType, params)
  }
})
