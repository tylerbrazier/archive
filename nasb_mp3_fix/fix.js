// disk 1: Genesis 1 - Judges 3
// disk 2: Judges 4 - Nehemiah 11
// disk 3: Nehemiah 12 - Jeremiah 49
// disk 4: Jeremiah 50 - Luke 13
// disk 5: Luke 14 - Revelation 22

var DIR = '/somewhere' // this is the directory containing subdirs disk1...disk5
var START_BOOK_INDEX = 0 // 0=Genesis, 6=Judges, 15=Nehemiah, 23=Jeremiah, 41=Luke
var START_CHAPTER = 1
var DISK = 1
var COVER = 'cover.jpg'

var books = require('./books.json')
var id3 = require('node-id3')
var fs = require('fs')
var join = require('path').join

var files = fs.readdirSync(join(DIR, 'disk' + DISK))
var bookIndex = START_BOOK_INDEX
var chapter = START_CHAPTER

files.forEach((f) => {
  // skip over processed files
  if (!f.startsWith('7613-')) {
    nextChapter()
    return
  }

  var book = books[bookIndex].name
  var path = join(DIR, 'disk' + DISK, f)

  tag(path, book, chapter)
  rename(path, book, chapter)

  nextChapter()

  // Psalm 119 spans two mp3s so stay on that chapter for the first set of verses
  if (f === '7613-D03-173.mp3') chapter--
})

function nextChapter () {
  chapter++
  if (chapter > books[bookIndex].chapters) {
    bookIndex++ // next book
    chapter = 1 // start at chapter 1
  }
}

function tag (path, book, chap) {
  var track = id3.read(path).trackNumber // preserve the track
  var tag = {
    title: `${book} ${chapter}`,
    artist: 'Dale McConachie',
    album: 'NASB',
    trackNumber: track,
    image: COVER
  }

  // Psalm 119 spans two mp3s so tag them specially
  if (path.endsWith('D03-173.mp3')) tag.title += ':1-93'
  if (path.endsWith('D03-174.mp3')) tag.title += ':94-176'

  console.log(`Tagging ${path}: ${JSON.stringify(tag, null, 2)}`)
  id3.write(tag, path)
}

function rename (path, book, chap) {
  // pad the chapter (Psalms has 150 chapters so it needs extra padding)
  var len = (book === 'Psalms' ? 3 : 2)
  var pChap = String(chap).padStart(len, '0')

  // Psalm 119 spans two mp3s so name them specially
  if (path.endsWith('D03-173.mp3')) pChap += '_1-93'
  if (path.endsWith('D03-174.mp3')) pChap += '_94-176'

  var dest = path
    .replace('7613-', '') // no idea why they start with this
    .replace(/\.mp3/, `-${book.replace(/\s/g, '_')}-${pChap}.mp3`)

  console.log(`${path} -> ${dest}`)
  fs.renameSync(path, dest)
}
