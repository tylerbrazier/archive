#!/usr/bin/env node

var fs = require('fs')
var http = require('http')
var https = require('https')

module.exports = linkifyVerses
linkifyVerses._normalize = normalize // for testing

if (require.main === module) {
  // called from cmd line
  // https://nodejs.org/docs/latest/api/all.html#modules_accessing_the_main_module
  try {
    var file = process.argv[2]
    var text = fs.readFileSync(file, 'utf8')
    linkifyVerses(text, (err, result) => {
      if (err) {
        console.error(err)
        process.exit(1)
      }
      fs.writeFileSync(file, result)
    })
  } catch (e) {
    var thisFile = require('path').basename(__filename)
    console.error(e.message)
    console.error(`Usage: ${thisFile} path/to/file.md`)
    process.exit(1)
  }
}

/**
 * Occurences of bible verses in markdown text surrounded by {{...}}
 * will be converted to reference-style links like [...][]
 * and the reference will be appended at the bottom with a link to
 * the Blue Letter Bible page for that verse.
 * The link will also include a title with the text for that verse.
 *
 * callback in the form of (err, result)
 */
function linkifyVerses (text, callback) {
  if (typeof text !== 'string') return callback(Error('Must be given a string'))

  var verses = {} // normalized verses indexed by their str
  var result = text.replace(/{{(.+?)}}/g, (match, verseText) => {
    var verse = normalize(verseText)
    if (!verse) return console.error(`Unable to parse '${verseText}'`)

    verses[verse.str] = verse
    return `[${verse.str}][]`
  })

  // Look for existing link refs in the text. if we find any, removed them
  // from the map of verse refs to be inserted (since they're already there).
  // Also update the ref key using the normalized text to ensure it matches
  // the text in the doc.
  result = result.replace(/^\s*\[(.+?)\]:\s*http/gm, (match, refKey) => {
    var verse = normalize(refKey)
    if (!verse) return match

    delete verses[verse.str]
    return `[${verse.str}]: http`
  })

  var promises = []
  Object.keys(verses).forEach(str => promises.push(toLinkRef(verses[str])))

  Promise.all(promises)
    .catch(callback)
    .then(linkRefs => {
      // append newline if necessary
      if (result.slice(-1) !== '\n') result += '\n'
      linkRefs.forEach(ref => (result += ref))
      callback(null, result)
    })
}

/**
 * Normalizes a textual verse into a js object like:
 * {
 *   bookNum: '1',  (or empty string)
 *   book: 'Samuel',
 *   chap: '12',
 *   start: '24',
 *   end: '25',  (or empty string)
 *   str: '1 Samuel 12:24-25',
 * }
 * or returns null if we couldn't parse the verse.
 * Note that all the values are strings
 */
function normalize (verseText) {
  if (typeof verseText !== 'string') return null

  var regex = /(\d)?\s*([a-z]+)\s*(\d+)\s*:\s*(\d+)\s*-?\s*(\d+)?/i
  var match = verseText.trim().match(regex)
  if (!match || !match[2] || !match[3] || !match[4]) return null

  // capitalize book
  match[2] = match[2].charAt(0).toUpperCase() + match[2].slice(1)

  return {
    bookNum: match[1] || '',
    book: match[2],
    chap: match[3],
    start: match[4],
    end: match[5] || '',
    str: (match[1] ? match[1] + ' ' : '') +
      match[2] + ' ' +
      match[3] + ':' + match[4] +
      (match[5] ? '-' + match[5] : '')
  }
}

/**
 * Returns a promise that resolves with the text for the markdown
 * reference-style link to be put at the bottom of the file. example:
 * [James 1:6-7]: http://... "But he must ask in faith without any doubting..."
 */
function toLinkRef (verse) {
  return Promise.all([
    fetchBlbUrl(verse),
    fetchLinkTitle(verse)
  ]).then((results) => {
    var [ url, title ] = results
    return `[${verse.str}]: ${url}\n  ${title}\n`
  })
}

/**
 * Returns a promise resolving to the Blue Letter Bible url for the given verse.
 * This function tests the url by making a request to the website. If we don't
 * get a 200 or redirect, the promise will reject.
 */
function fetchBlbUrl (verse) {
  if (process.env.NODE_ENV === 'development') {
    return Promise.resolve('http://example.com')
  }

  var hostname = 'www.blueletterbible.org'
  var path = `/nasb/${verse.bookNum || ''}${verse.book}/${verse.chap}/${verse.start}`
  var opts = { hostname, path, method: 'HEAD' }

  return new Promise((resolve, reject) => {
    var req = https.request(opts, (res) => {
      res.resume() // finish reading res, freeing memory

      var base = 'https://' + hostname
      if (res.statusCode === 200) {
        return resolve(base + path)
      } else if (res.statusCode === 301 && res.headers.location) {
        return resolve(base + res.headers.location)
      } else {
        return reject(Error(`${hostname}${path} responded with ${res.statusCode}`))
      }
    })
    req.on('error', reject)
    req.end()
  })
}

/**
 * Returns a promise resolving with a pre-quoted link title for the given verse.
 * This works by requesting bible.org's NET api. If the request fails
 * the promise will reject.
 * Using the NET bible api because it's simple and doesn't require fussing with
 * api keys and such.
 */
function fetchLinkTitle (verse) {
  if (process.env.NODE_ENV === 'development') return Promise.resolve('"TEST"')

  var url = `http://labs.bible.org/api/?passage=${verse.str.replace(/ /g, '+')}`

  return new Promise((resolve, reject) => {
    http.get(url, (res) => {
      if (res.statusCode !== 200) {
        res.resume() // finish reading res, freeing memory
        return reject(Error(`${url} responded with ${res.statusCode}`))
      }

      var data = ''
      res.setEncoding('utf8')
      res.on('data', chunk => (data += chunk))
      res.on('end', () => {
        if (!data) return reject(Error(`No data returned from ${url}`))
        var title = data.trim().replace(/<.+?>/g, ' ') // remove html tags
        return resolve(`"(NET) ${title}"`)
      })
    }).on('error', reject)
  })
}
