#!/usr/bin/env node

var assert = require('assert')
var mod = require('./index.js')

process.env.NODE_ENV = 'development'

console.log('--- Test normalize ---')

var tests = {
  'John 3:16': {
    bookNum: '',
    book: 'John',
    chap: '3',
    start: '16',
    end: '',
    str: 'John 3:16'
  },
  'john 3:16-': {
    bookNum: '',
    book: 'John',
    chap: '3',
    start: '16',
    end: '',
    str: 'John 3:16'
  },
  ' John 3 : 16 ': {
    bookNum: '',
    book: 'John',
    chap: '3',
    start: '16',
    end: '',
    str: 'John 3:16'
  },
  '1 Samuel 12:24-25': {
    bookNum: '1',
    book: 'Samuel',
    chap: '12',
    start: '24',
    end: '25',
    str: '1 Samuel 12:24-25'
  },
  '1samuel 12:24 - 25': {
    bookNum: '1',
    book: 'Samuel',
    chap: '12',
    start: '24',
    end: '25',
    str: '1 Samuel 12:24-25'
  },
  'fail': null,
  'NoVerses 5': null,
  'NoVerses 5:': null,
  '1 NoVerses 5': null,
  'NoChapter :12-14': null,
  'NoStart 1:-14': null,
  'NotANumber a:b': null
}
Object.keys(tests).forEach(input => {
  assert.deepStrictEqual(mod._normalize(input), tests[input])
})

console.log('--- Test linkifyVerses ---')

var lt = 'http://example.com\n  "TEST"\n' // expected link and title
tests = {
  // basic test
  '{{James 1:5-6}}': '[James 1:5-6][]\n[James 1:5-6]: ' + lt,

  // test newline
  '{{James 1:5-6}}\n':
  '[James 1:5-6][]\n[James 1:5-6]: ' + lt,
  '{{James 1:5-6}} {{John 3:16}}\n': '[James 1:5-6][] [John 3:16][]\n' +
  `[James 1:5-6]: ${lt}[John 3:16]: ${lt}`,

  // test duplicate
  'a {{hebrews 11:1}}\n b {{Hebrews 11 : 1}}':
  'a [Hebrews 11:1][]\n b [Hebrews 11:1][]\n[Hebrews 11:1]: ' + lt,

  // test existing link ref
  '{{Luke 17:6}}\n[Luke 17:6]: http://example.com\n  "TEST"\n':
  '[Luke 17:6][]\n[Luke 17:6]: ' + lt,

  // test updating existing link ref
  '{{mark9:22}}\n[mark9:22]: http://example.com\n  "TEST"\n':
  '[Mark 9:22][]\n[Mark 9:22]: ' + lt
}

Object.keys(tests).forEach(input => {
  mod(input, function (err, result) {
    // try/catch here so any errors aren't handled by a Promise.catch()
    // in the module
    try {
      assert(!err, err)
      assert.equal(result, tests[input])
    } catch (e) {
      console.error(e)
      process.exit(1)
    }
  })
})
