// Router for web/html stuff

module.exports = function(app) {

  var express = require('express'),
      router = express.Router(),
      serveIndex = require('serve-index'),
      secure = require('../middleware/secure'),
      notFound = require('../middleware/not-found'),
      errHandler = require('../middleware/err-handler'),
      indexOpts = { icons: true, view: 'details' },
      web = __dirname+'/../web';

  app.set('views', web);
  app.set('view engine', 'ejs');

  router.use('/private',
      secure.https,
      secure.auth,
      serveIndex(web + '/private', indexOpts));

  router.use('/public',
      serveIndex(web + '/public', indexOpts));

  router.use('/docs',
      secure.https,
      secure.auth);

  router.use('/',
      express.static(web),
      notFound,
      errHandler.forHtml);

  return router;
}
