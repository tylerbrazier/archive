I had bought the [NASB mp3 CD][1] and there's one mp3 per chapter but the files
don't contain the book or chapter in the filename or in the meta on the tag.
So I made some scripts to go through the files and rename + retag them.

1. First create some directory `DIR` with five subdirectories `disk1`...`disk5`
   and copy the files from the CDs into those subdirectories.
2. Run `npm install` in this repository.
3. Then modify the constant vars at the top of `fix.js` according to which disk
   directory you want to fix files in, then run `node fix.js`.
4. Repeat step 3 for each disk (you'll have to run the script five times,
   once for each disk directory).

[1]: https://biblegateway.christianbook.com/the-nasb-bible-on-mp-3/9781482998405/pd/998405?p=1172293
