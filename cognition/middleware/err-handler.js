// Middleware functions for handling errors.

var statuses = require('http').STATUS_CODES;


// Use this on for web stuff. It just renders a simple error page based on
// the status code, which should be set earlier in the middleware stack.
exports.forHtml = function(err, req, res, next) {
  res.render('error', {
    title: statuses[res.statusCode],
    message: statuses[res.statusCode]
  });
}


// Use this one for the APIs. This middleware will handle setting the status
// code on the response (unless it's already something other than 200) and
// sending the response to the client.
exports.forJson = function(err, req, res, next) {

  // set status on the response based on err
  if (res.statusCode && res.statusCode != 200)
    res.status(res.statusCode);

  else if (!err || !err.name)
    res.status(500);

  else if (err.name === 'ValidationError')  // produced by mongoose validation
    res.status(400);

  else if (err.name === 'MongoError' && err.code === 11000) // unique constr
    res.status(409); //conflict

  else if (err.body && err.status) // produced by body-parser
    res.status(err.status);

  else
    res.status(500);

  // build an array of errors to be sent to the client
  var result = [],
      internalError = { message: 'Something broke :(' };

  if (!err) {
    result.push(internalError);

  } else if (err.name === 'ValidationError') {
    // produced by mongoose validation
    for (var path in err.errors) {
      result.push({
        message: err.errors[path].message,
        field: err.errors[path].path
      });
    }

  } else if (err.name === 'MongoError' && err.code === 11000) {
    var errResponse = { message: err.message };
    if (err.field)
      errResponse.field = err.field;
    result.push(errResponse);

  } else if (err.message) {
    result.push({ message: err.message });

  } else if (statuses[res.statusCode]) {
    result.push({ message: statuses[res.statusCode] });

  } else {
    result.push(internalError);
  }

  res.json(result);
}
