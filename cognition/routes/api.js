// Router for APIs

var router = require('express').Router(),
    secure = require('../middleware/secure'),
    notFound = require('../middleware/not-found'),
    errHandler = require('../middleware/err-handler');

router.use(secure.https, secure.auth);

router.use('/docs', require('./docs'));

router.use(notFound, errHandler.forJson);

module.exports = router;
