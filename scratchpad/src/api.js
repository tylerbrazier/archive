// data should be a json object or null
// callback is in the form (err, json) where err is just a string
function api(method, data, callback) {
  var token = localStorage.getItem('token')
  if (!token)
    return callback('First set your API token on the settings page')

  var gistId = localStorage.getItem('gistId')
  if (!gistId)
    return callback('First set your gist on the settings page')

  var ajaxSettings = {
    url: 'https://api.github.com/gists/' + gistId,
    method: method,
    headers: { Authorization: 'token ' + token },
    dataType: 'json',
    error: handleErr,
    success: (data) => callback(null, data),
  }

  if (method === 'GET')
    ajaxSettings.cache = false

  if (data) {
    ajaxSettings.data = JSON.stringify(data)
    ajaxSettings.contentType = 'application/json'
  }

  $.ajax(ajaxSettings)

  function handleErr(jqXHR, textStatus, err) {
    var msg = `Error ${jqXHR.status}: `
    if (jqXHR.responseJSON && jqXHR.responseJSON.message)
      msg += jqXHR.responseJSON.message
    else
      msg += err
    callback(msg);
  }
}
