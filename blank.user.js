// ==UserScript==
// @match https://www.youtube.com/*
// ==/UserScript==

// Blank out youtube videos. Useful if you want to just listen to audio at work.
// To install in chrome, go to the extensions page and drop the file in.
// More info: https://www.chromium.org/developers/design-documents/user-scripts

// This runs on an interval because youtube uses ajax to navigate the page,
// inserting new video elements into the DOM. This script will not get reloaded
// when navigating to new videos so we have to periodically check for new
// video elements.

if (confirm('Blank videos?'))
  setInterval(blank, 1000)

function blank() {
  var vids = document.getElementsByTagName('video')
  if (!vids)
    return
  for (var i = 0; i < vids.length; i++)
    vids[i].style.height = '0'
}
