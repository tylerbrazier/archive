module.exports = function(conf) {

  var express = require('express'),
      app = express(),
      mongoose = require('mongoose'),
      favicon = require('serve-favicon'),
      apiRouter = require('./routes/api'),
      webRouter = require('./routes/web')(app);

  app.locals.conf = conf;
  app.set('x-powered-by', false); // don't send "X-Powered-By: Express" header

  mongoose.connect(conf.db, function(err) {

    app.use(favicon(__dirname + '/web/resources/img/cog.ico'));

    app.use('/api', apiRouter);
    app.use('/', webRouter);

  });

  return app;
}
