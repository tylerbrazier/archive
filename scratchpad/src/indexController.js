$(document).ready( () => {
  api('GET', null, (err, json) => {
    if (err)
      return $(document).trigger('app:error', err)
    $(document).trigger('gist:loaded', json)
  })
})
