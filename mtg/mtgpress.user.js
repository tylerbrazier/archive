// ==UserScript==
// @match http://mtgpress.net/build
// ==/UserScript==

/*
 * On mtgpress.net, after choosing the cards to print, this script will let
 * you change the set of every card on the page to a single set - much easier
 * than doing one by one.
 *
 * When adding cutlines, this will also prompt for custom css for the borders
 * so you can have thicker card borders of any color to fit better in sleeves;
 * 3px is a good size, #333 is good for black borders, #fff for white
 *
 * To use this, install greasemonkey on firefox
 * https://addons.mozilla.org/en-Us/firefox/addon/greasemonkey/
 * and drag the file from your explorer onto the Manage User Scripts page.
 */

$(function() {

  promptToChangeSet();

  function promptToChangeSet() {
    var setName = prompt('Set name (empty to cancel)', getSetSuggestion());
    if (!setName)
      return;
    saveSetSuggestion(setName);
    try {
      var selects = $('select');
      for (var i = 0; i < selects.length; i++) {
        setSelectText(selects[i], setName);
      }
      selects.trigger('onchange');
    } catch(e) {
      console.error(e);
      alert(e);
    }
  }

  function getSetSuggestion() {
    var defaultSet = 'Limited Edition Beta';
    var store = window.localStorage;
    if (!store || !store.getItem('set'))
      return defaultSet;
    return store.getItem('set');
  }

  function saveSetSuggestion(setName) {
    if (window.localStorage && setName)
      window.localStorage.setItem('set', setName);
  }

  function setSelectText(select, choice) {
    var opts = select.options;
    for (var i = 0; i < opts.length; i++) {
      var text = opts[i].text;
      if (text === choice) {
        select.selectedIndex = i;
        return;
      }
    }
    // not a very helpful message but at least we know something went wrong
    throw new Error("wasn't able to select '"+choice+"' on at least one card");
  }

  function getCutlineCss() {
    var defaultCss = '1px solid #666666';
    var store = window.localStorage;
    if (!store || !store.getItem('css'))
      return defaultCss;
    return store.getItem('css');
  }

  function saveCutlineCss(css) {
    if (window.localStorage && css)
      window.localStorage.setItem('css', css);
  }

  $('#cutlines').on('change', function() {
    if (this.checked) {
      var message = 'cutline css\n'
        + '3px solid #333 is good for black borders\n'
        + '3px solid #fff is good for white borders\n'
        + '1px solid #666 is the default';
      var cutlineCss = prompt(message, getCutlineCss());
      $('.carddiv.cutlines').css('border', cutlineCss);
      saveCutlineCss(cutlineCss);
    }
  });

});
