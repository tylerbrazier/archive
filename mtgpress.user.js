// ==UserScript==
// @match http://mtgpress.net/build
// ==/UserScript==

/*
 * On mtgpress.net, after choosing the cards to print, this script will let
 * you change the set of every card on the page to a single set - much easier
 * than doing one by one.
 *
 * When adding cutlines, this will also prompt for custom css for the borders
 * so you can have thicker card borders of any color to fit better in sleeves.
 *
 * To use this, install greasemonkey on firefox
 * https://addons.mozilla.org/en-Us/firefox/addon/greasemonkey/
 * and drag the file from your explorer onto the Manage User Scripts page.
 */

$(function() {

  promptToChangeSet();

  function promptToChangeSet() {
    var defaultSet = 'Limited Edition Beta';
    var setName = prompt('Set name (empty to cancel)', defaultSet);
    if (!setName)
      return;
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

  $('#cutlines').on('change', function() {
    if (this.checked) {
      var cutlineCss = prompt('cutline css', '1px solid #666666');
      $('.carddiv.cutlines').css('border', cutlineCss);
    }
  });

});
