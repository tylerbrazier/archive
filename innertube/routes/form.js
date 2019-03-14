// Given a youtube url, check if it's a song or playlist and get meta info.
// Respond with a form filled with as much meta as possible.

var util = require('util')
var exec = require('child_process').exec

module.exports = {
  post: postRoute
}

function postRoute (req, res, next) {
  if (!req.body) return next('No body on request')

  var url = req.body.url

  if (!url) return res.status(400).send('url is required')

  var cmd = 'youtube-dl -J ' + url

  console.log(`Getting metadata for ${url}...`)
  exec(cmd, (err, stdout, stderr) => {
    if (err) return next(err)

    try {
      var json = JSON.parse(stdout)
      if (!json) return next('JSON parse returned empty: ' + json)

      if (json._type === 'playlist') respondPlaylist(res, url, json.entries)
      else respondSong(res, url, json)
    } catch (err) {
      return next(err)
    }
  })
}

function respondSong (res, url, meta) {
  var data = {
    url: url,
    title: meta.track || '',
    artist: meta.artist || '',
  }

  res.render('songForm', data)
}

function respondPlaylist (res, url, metaEntries) {
  res.render('playlistForm', {})
}
