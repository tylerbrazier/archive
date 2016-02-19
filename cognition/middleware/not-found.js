module.exports = function(req, res, next) {
  res.status(404);
  next(new Error('Nothing here'));
}
