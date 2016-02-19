$(document).ready(function() {

  var curDoc = null;
  var $name = $('#name');
  var $body = $('#body');

  var toggleList = function() {
    var $l = $('#list');
    $l.toggleClass('open');
    $span = $('#toggle-list-button > span');
    if ($l.hasClass('open')) {
      $l.animate({ left: '0px' }); // open it
      // change icon on menu button
      $span.removeClass('glyphicon-menu-hamburger')
           .addClass('glyphicon-menu-left');
    } else {
      $l.animate({ left: -$l.width() }); // close it
      // change icon on menu button
      $span.removeClass('glyphicon-menu-left')
           .addClass('glyphicon-menu-hamburger');
    }
  };
  $('#toggle-list-button').click(function(e) {
    e.preventDefault();
    toggleList();
  });


  var updateList = function() {
    // remove existing
    $('.doc-list-item').remove();

    // add the new ones
    $.ajax('/api/docs', {
      dataType: 'json',
      success: function(data) {
        $.each(data, function(i, doc){
          addToList(doc);
        });
      },
      error: function(jqXhr, textStatus, err) {
        showErr(jqXhr.responseText);
      }
    });

    var addToList = function(doc) {
      var $deleteIcon = $('<span>')
                          .addClass('glyphicon glyphicon-remove');
      var $deleteBtn = $('<a>')
                         .attr('href', '#')
                         .addClass('ghost-button btn btn-default btn-sm')
                         .addClass('delete-btn')
                         .append($deleteIcon)
                         .click(function(event) {
                           event.preventDefault();
                           deleteDoc(doc.name);
                         });
      var $a = $('<a>')
                 .attr('href', '#')
                 .addClass('doc-link')
                 .text(doc.name)
                 .click(function(event) {
                   event.preventDefault();
                   loadDoc(doc.name);
                 });
      var $li = $('<li>')
                  .addClass('list-group-item')
                  .addClass('doc-list-item')
                  .append($deleteBtn)
                  .append($a);
      $('#list').append($li);
    }
  }


  // load the name and body into the fields
  var loadDoc = function(name) {
    $.ajax('/api/docs/' + name, {
      dataType: 'json',
      success: function(data) {
        curDoc = data.name;
        $name.val(data.name);
        $body.val(data.body);
        $body.focus();
        // TODO don't hard code this
        if ($(window).width() < 1050) {
          toggleList();
        }
      },
      error: function(jqXhr) {
        showErr(jqXhr.responseText);
        updateList();
      }
    });
  }


  // prompt and delete the named doc
  var deleteDoc = function(name) {
    if (confirm('Delete ' + name + '?')) {
      $.ajax('/api/docs/' + name, {
        dataType: 'json',
        method: 'DELETE',
        error: function(jqXhr) {
          showErr(jqXhr.responseText);
        },
        success: function() {
          updateList();
          if (name === curDoc) {
            $name.val('');
            $body.val('');
            curDoc = null;
          }
        }
      });
    }
  }


  /**** Create stuff ****/
  var $createLi = $('#create-li'),
      $createField = $('#create-field'),
      createDoc = function() {
        var newDocName = $createField.val();
        if (!newDocName) {
          $createField.focus();
        } else {
          $.ajax('/api/docs', {
            method: 'POST',
            dataType: 'json',
            data: JSON.stringify({
              name: newDocName
            }),
            error: function(jqXhr) {
              showErr(jqXhr.responseText);
            },
            success: function() {
              updateList();
              $createField.val('');
              loadDoc(newDocName);
            }
          });
        }
      }
  // bind to add button and when enter is pressed in the field
  $('#create-btn').click(function(e) {
    e.preventDefault();
    createDoc();
  });
  $createField.keyup(function(e) {
    e.preventDefault();
    if (e.keyCode == 13)
      createDoc();
  });


  /**** Save button stuff ****/
  var $save = $('#save');

  // save button looks different if doc is modified and not saved
  var setModified = function(modified) {
    if (modified) {
      $save.removeClass('btn-success').addClass('btn-warning')
        .find('span')
          .removeClass('glyphicon-ok').addClass('glyphicon-floppy-disk');
    } else {
      $save.removeClass('btn-warning').addClass('btn-success')
        .find('span')
          .removeClass('glyphicon-floppy-disk').addClass('glyphicon-ok');
    }
  }
  $name.on('input', function() {
    setModified(true);
  });
  $body.on('input', function() {
    setModified(true);
  });
  setModified(false);

  $save.click(function(e) {
    e.preventDefault();
    if (!curDoc) {
      return showErr('No doc selected');
    }
    $.ajax('/api/docs/' + curDoc, {
      dataType: 'json',
      method: 'PUT',
      data: JSON.stringify({
        name: $name.val(),
        body: $body.val()
      }),
      error: function(jqXhr) {
        showErr(jqXhr.responseText);
      },
      success: function(jqXhr) {
        setModified(false);
        curDoc = jqXhr.name;
      },
      complete: updateList
    });
  });


  // error handling stuff

  var $err = $('#error'),
      $errMsg = $('#err-msg');
  $err.hide(); // initially hidden

  var showErr = function(message) {
    try {
      $errMsg.text(JSON.parse(message)[0].message);
    } catch (err) {
      $errMsg.text(message);
    }
    $err.show();
  }

  $('#close-err-btn').click(function(e) {
    e.preventDefault();
    $err.hide();
  });



  updateList();
  toggleList();



});
