var join = require('path').join
var os = require('os')

module.exports = {
  port: 8080,
  musicDir: join(os.homedir(), 'web', 'music'),
  infoMountPoint: '/info',
  filesMountPoint: '/files'
}
