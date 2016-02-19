#!/usr/bin/env node

var http = require('http'),
    https = require('https'),
    fs = require('fs'),
    conf = require('../.default.conf.js');
    root = __dirname + '/..'; // project root

try {
  conf = require('../conf.js');
} catch (err) {
  console.log('Creating conf.js with default settings');
  fs.writeFileSync(root + '/conf.js',
      fs.readFileSync(root + '/.default.conf.js'));
}

var app = require('../app')(conf);

http.createServer(app).listen(conf.http.port, conf.http.address, function() {
  process.stdout.write('Listening for http traffic on ');
  process.stdout.write(conf.http.address ? conf.http.address + ':' : '');
  process.stdout.write(conf.http.port.toString() + '\n');
});

if (conf.https.enabled) {
  https.createServer({
    key: fs.readFileSync(root + '/tls/' + conf.https.key),
    cert: fs.readFileSync(root + '/tls/' + conf.https.cert)
  }, app).listen(conf.https.port, conf.https.address, function() {
    process.stdout.write('Listening for https traffic on ');
    process.stdout.write(conf.https.address ? conf.https.address + ':' : '');
    process.stdout.write(conf.https.port.toString() + '\n');
  });
}
