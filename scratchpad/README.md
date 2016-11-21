Scratchpad
==========
A small webapp for taking quick notes (to do list, groceries, etc.) backed by
[gist.github.com][0] and hosted at [*username*.github.io/scratchpad][1].

**No longer maintained**: I really like the idea of this app because it's
very lightweight and leverages github for hosting and for backend storage.
The only reason I stopped working on it is because I found out that every edit
made to a gist adds another entry to the `history` field returned by the API;
the json responses get larger every time you take a note, adding lots of
unnecessary bandwidth and there doesn't seem to be a way to filter out these
unwanted fields. I'm going to archive this app for now because I like how it's
been designed (see below) and I can probably use some of the same ideas in other
web apps.

The app is fully functional but there's a few improvements listed in TODO.md
that could still be made.

Design
------
Components on the page such as buttons and fields should not update other
components. Instead, there's a controller that listens for events on components
and triggers custom events on the `document` which the other components can
listen for. For example, on the file page, when the name or content fields are
changed, the save button is colored differently to indicate unsaved changes.
Rather than having the fields update the color of the button or have the button
listen for changes on the fields, the controller listens for field changes and
fires a `file:modified` event on the document; the button listens for this event
and updates its own state.

The controller holds no state; instead, relevant data is passed to the listeners
when events fire. If a component needs to hold onto that data, that's up to
them. For example: Since files can be renamed, when the user changes the file
name field, we need to store the original file name somewhere so that when the
file is saved, we can tell the API that this is a rename and not a create.
Additionally, when the file is saved, we need to update the `originalFileName`
to the new name. Instead of keeping this data in some global variable or in the
controller, the custom `file:loaded` and `file:saved` events pass `fileName` as
an extra parameter that the name field can hold on to; thus the state of the
file's original and current name is contained within the field component. The
controller listens for a click event on the save button and when it fires, it's
up to the controller to collect the file name data from the field to send along
with the `file:saved` event.

The controller is also in charge of interacting with externals such as APIs and
localStorage.

This design works well because:

- single responsibility: since components are only allowed to update themselves,
  the state of each component is predictable and control remains isolated.
- it's scaleable: new components can be added to the page and be listening for
  the same events without having to know how they were triggered.
- components don't need to know about other components on the page; they only
  need to listen for events on `document`; there no spaghetti dependency mess.
  The controller is the only thing that has knowledge of all of the components.

Building/devloping
------------------

    npm install         # install dev deps
    npm run gulp watch  # rebuild on change
    npm start           # serve at localhost:8080

After committing, run the following to push built files in `dist/` to the
remote `gh-pages` branch for hosting (see [this][2] for more info).

    npm run deploy


[0]: https://help.github.com/articles/about-gists/
[1]: https://tylerbrazier.github.io/scratchpad
[2]: https://help.github.com/categories/github-pages-basics/
