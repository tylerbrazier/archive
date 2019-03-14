markdown-linkify-verses
=======================
Turn Bible verse references in a markdown document into links.
Surround the verses you want linkified in `{{  }}`.
The link's title will be set to the text of the verse so in the browser you can
hover over the link to read it.

For example,
```
Paul points out the source of faith in {{Romans 10:17}}.
```
would become
```
Paul points out the source of faith in [Romans 10:17][].
[Romans 10:17]: https://www.blueletterbible.org/nasb/rom/10/17/
  "(NET)  10:17  Consequently faith comes from what is heard, and what is heard comes through the preached word of Christ."
```

Thanks to [bible.org][] for the API, and [Blue Letter Bible][blb] for a great
place to point the links at.


Usage
-----
`npm install -g markdown-linkify-verses` to install. Then to convert a file:
```
linkify-verses file.md
```
Keep in mind the file will be overwritten! Back it up beforehand if needed.

To use as a node module:
```javascript
var linkifyVerses = require('markdown-linkify-verses');
var text = 'Paul points out the source of faith in {{Romans 10:17}}';

linkifyVerses(text, function(err, result) {
  if (err)
    return console.error(err);
  console.log(result);
});
```

Development
-----------
- `npm run lint` to lint
- `npm test` to test


TODO
----
- Add more tests.
- Consider limiting length of a link's title, maybe with ellipsis


License
-------
MIT license for the code here.
Your use of Bible verses fetched from [bible.org][] are still
subject to their [copyright][].


[bible.org]: http://labs.bible.org/api_web_service
[blb]: https://www.blueletterbible.org/
[copyright]: https://bible.org/copyright#cpyrt
