const m = require('./main.js')
const assert = require('assert')
global.atob = (str) => Buffer.from(str, 'base64').toString('binary')

// test extractHtml
assert(m.extractHtml, 'No extractHtml')
assert.throws(() => m.extractHtml('not json'), /unable to parse/i)
assert.throws(() => m.extractHtml(mock()), /no content/i)
assert.throws(() => m.extractHtml(mock('not html')), /no <dl> tag/i)
assert.equal(m.extractHtml(mock('<DL><p>asdf</DL></p>')), '<DL>asdf</DL>')
assert.equal(m.extractHtml(mock('<P>\n<dl>asdf\n</dl></P>')), '<dl>asdf</dl>')
assert.equal(m.extractHtml(mock('<DL><p><dl>a</DL></dl>')), '<DL><dl>a</DL></dl>')
// mock response from github's content api
function mock(content) {
  return JSON.stringify({
    content: Buffer.from(content || '').toString('base64')
  })
}
