var express = require('express')
var serveIndex = require('serve-index')
var downloadRoute = require('./routes/download.js')
var formRoute = require('./routes/form.js')
var infoRoute = require('./routes/info.js')
var bodyParser = require('body-parser')
var spawn = require('child_process').spawn

var conf = require('./conf.js')
var app = express()

app.set('views', './views')
app.set('view engine', 'ejs')

// check that youtube-dl is installed and executable
spawn('youtube-dl', ['-h']).on('error', function (err) {
  console.error('Make sure youtube-dl is installed', err)
})

app.get('/', (req, res) => res.render('index', { infoMountPoint: conf.infoMountPoint }))

app.use('/download', bodyParser.urlencoded({ extended: true }))
app.post('/download', downloadRoute.post)

app.use('/form', bodyParser.urlencoded({ extended: true }))
app.post('/form', formRoute.post)

// /info
app.use(conf.infoMountPoint, serveIndex(conf.musicDir))
app.get(conf.infoMountPoint + '/*.mp3', infoRoute.get)

// /files
app.use(conf.filesMountPoint, serveIndex(conf.musicDir))
app.use(conf.filesMountPoint, express.static(conf.musicDir))

app.listen(conf.port, function () {
  console.log('Listening on ' + conf.port)
})
