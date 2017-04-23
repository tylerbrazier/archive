I wanted to build a [cube][] using one set but didn't want to have to buy every
card that I don't already have. I decided to just buy a cheap [printer][] and
[cutter][] and print the missing cards using [mtgpress.net][]. The printed
cards can slipped into sleeves and backed by some real card for stiffness. It
worked out really well. I found a 7th edition cardlist [here][7th cardlist] and
used a few vim commands to trim out everything besides the card names and saved
the [new list](7th_edition.txt).

Mtgpress has a couple of problems: you have to manually select the set for each
card and the printed cards lack borders so they don't quite fit perfectly.
I made a [script](mtgpress.user.js) that solves both of these issues. Use
[greasemonkey][] on firefox to run it. The script has more info in the comments
at the top of the file.


[cube]: http://magic.wizards.com/en/articles/archive/how-build/building-your-first-cube-2016-05-19
[printer]: https://www.amazon.com/gp/product/B013SKI4QA/ref=oh_aui_detailpage_o05_s00?ie=UTF8&psc=1
[cutter]: https://www.amazon.com/gp/product/B003SLC3IU/ref=oh_aui_detailpage_o06_s00?ie=UTF8&psc=1
[mtgpress.net]: http://mtgpress.net/
[7th cardlist]: http://www.wizards.com/magic/generic/cardlists/7e_checklist.txt
[greasemonkey]: https://addons.mozilla.org/en-Us/firefox/addon/greasemonkey/
