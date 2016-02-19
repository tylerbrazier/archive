// Returns an object with middleware functions
//   https() - redirect your route to https
//   auth()  - authenticate requests to this route using basic auth;
//             this also adds a user object to the request; e.g.
//             req.user = { _id: 0123, name: 'tb' }

var bcrypt = require('bcrypt'),
    basicAuth = require('basic-auth'),
    User = require('../models/user');


exports.https = function(req, res, next) {
  if (!req.app.locals.conf.https.enabled)
    return next();

  if (!req.secure)
    res.redirect('https://' + req.hostname + req.originalUrl);
  else
    next();
}


exports.auth = function(req, res, next) {
  if (!req.app.locals.conf.auth.enabled)
    return next();

  var creds = basicAuth(req);

  if (!creds) {
    forbid(res);
    return next(new Error('Invalid username:password.'));
  }

  User.findOne({name:creds.name}, function(err, user) {
    if (err) {
      forbid(res);
      return next(err);
    } else if (!user) {
      forbid(res);
      return next(new Error("Username '" + creds.name + "' not found."));
    }

    bcrypt.compare(creds.pass, user.password, function(err, match) {
      if (err) {
        forbid(res);
        return next(err);
      } else if (!match) {
        forbid(res);
        return next(new Error("Bad password."));
      }

      req.user = { _id: user._id, name: user.name };
      next();
    });
  });
}

function forbid(res) {
  var realm = res.app.locals.conf.auth.realm;
  res.status(401).setHeader('WWW-Authenticate', 'Basic realm="'+realm+'"');
}

