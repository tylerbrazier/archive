var id3 = require('node-id3')
var conf = require('../conf.js')

module.exports = {
  get: getRoute
}

function getRoute (req, res, next) {
  var path = req.path.replace(conf.infoMountPoint, '') // strip mountpoint
  var link = conf.filesMountPoint + path
  var file = conf.musicDir + path

  id3.read(file, (err, tags) => {
    if (err) return next(err)

    var cover = ''
    if (tags.image) {
      cover += 'data:image/' + tags.image.mime
      cover += ';base64,' + tags.image.imageBuffer.toString('base64')
    }

    delete tags.image
    delete tags.raw

    var data = { tags, cover, link }
    res.render('info', data)
  })
}
