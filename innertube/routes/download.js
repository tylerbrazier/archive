var join = require('path').join
var os = require('os')
var uuidv4 = require('uuid/v4')
var id3 = require('node-id3')
var util = require('util')
var fs = require('fs')
var http = require('http')
var https = require('https')
var exec = util.promisify(require('child_process').exec)
var mkdirp = util.promisify(require('mkdirp'))
var rename = util.promisify(fs.rename)

var conf = require('../conf.js')

module.exports = {
  post: postRoute
}

function postRoute (req, res, next) {
  var meta = req.body

  if (!meta) return next('No body on request')

  if (!meta.url) return sendErr(res, 'url is required')
  if (!meta.title) return sendErr(res, 'title is required')
  if (meta.track && isNaN(parseInt(meta.track))) {
    return sendErr(res, 'track must be a number')
  }

  // don't include extention here because youtube-dl -o needs '.%(ext)s'
  // also use a unique file name so that concurrent requests don't clash
  var basePath = join(os.tmpdir(), uuidv4())

  var downloadPromises = [
    downloadSong(meta.url, basePath)
  ]

  if (meta.cover) {
    // using .cover as an extension here since we don't know the image type
    downloadPromises.push(downloadCover(meta.cover, basePath + '.cover'))
  }

  Promise.all(downloadPromises)
    .then(() => tagSong(basePath, meta))
    .then(() => moveSong(basePath + '.mp3', meta))
    .then((dest) => {
      console.log('Done. sending response')

      var redirectPath = dest.replace(conf.musicDir, '') // strip leading dir
      redirectPath = conf.infoMountPoint + redirectPath
      res.redirect(redirectPath)
    })
    .catch(next)
}

// send error response. err object can be Error object or message
function sendErr (res, err) {
  var message = (err && err.message) || 'Error'
  console.error(err)
  res.status(400).send(message)
}

function downloadSong (url, basePath) {
  var cmd = 'youtube-dl -x '
  cmd += '--audio-format mp3 '
  cmd += '--audio-quality 0 '
  cmd += `-o '${basePath}.%(ext)s' `
  cmd += `'${url}'`

  console.log(`Downloading ${url}...`)
  return exec(cmd)
    .then((stdout, stderr) => {
      if (stdout) console.log(stdout)
      if (stderr) console.error(stderr)
    })
}

function downloadCover (url, path) {
  return new Promise((resolve, reject) => {
    var protocol = url.startsWith('https') ? https : http

    console.log('Downloading cover ' + url)
    protocol.get(url, function (res) {
      var file = fs.createWriteStream(path)
      file.on('error', reject)
      res.pipe(file)
      file.on('finish', resolve)
    }).on('error', reject)
  })
}

function tagSong (basePath, meta) {
  var tag = {
    title: meta.title,
    artist: meta.artist,
    album: meta.album,
    trackNumber: meta.track,
    image: basePath + '.cover'
  }

  console.log(`Tagging ${meta.title}...`)

  // util.promisify doesn't seem to work with this
  return new Promise((resolve, reject) => {
    id3.write(tag, basePath + '.mp3', (err) => {
      if (err) return reject(err)
      resolve()
    })
  })
}

function moveSong (path, meta) {
  var dir = conf.musicDir
  var title = sanitize(meta.title) + '.mp3'

  if (meta.artist) {
    dir = join(dir, sanitize(meta.artist))
    if (meta.album) {
      dir = join(dir, sanitize(meta.album))
    }
  }

  return mkdirp(dir)
    .then(() => {
      if (meta.track) title = `${meta.track.padStart(2, '0')}-${title}`

      var dest = join(dir, title)

      console.log(`Moving ${path} -> ${dest}`)
      return rename(path, dest).then(() => dest)
    })
}

// sanitize file names; removes special chars and replaces whitespace with _
function sanitize (name) {
  return name.replace(/[^\w\s.-]/g, '').replace(/\s+/g, '_')
}
