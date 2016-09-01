vim-collapse
============
Better indent folding.

Toggling fold on a line will fold everything below it with greater indent.
It stops folding before it reaches a line with indent equal to or less
than the current line or before whitespace (empty) line(s) preceding a
line with equal or less indent.

Many thanks to [@sjl][0] for the [meat of the code][1].
I only turned it into a plugin.

This plugin also sets `foldtext` to exclude the `X lines:` part from the fold.

[0]: https://github.com/sjl
[1]: http://learnvimscriptthehardway.stevelosh.com/chapters/49.html
