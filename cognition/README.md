Cognition
=========
A simple web service for storing and fetching information and records.

I started this project because I'm not completely comfortable storing all of
my personal stuff "in the cloud" on someone else's server. I would rather host
it myself - which means I can build it how I'd like it to be and also learn
something as I go.

Currently, there's just a simple /api/docs API for keeping generic documents.

Setup
-----
I've only run this myself on Arch linux but the steps should be similar for
other distros. Install [node][node] v0.10~v0.12 and [mongodb][mongo] v2.5+.
You'll also need `gcc`, `make`, and `python2` for node-gyp. On Arch (as root):

    pacman -Sy --needed nodejs npm mongodb gcc make python2
    systemctl start mongodb
    systemctl enable mongodb

Clone the project and install dependencies:

    git clone https://github.com/tylerbrazier/cognition
    cd cognition
    npm config set python /usr/bin/python2
    npm install
    npm run gulp

Testing
-------
Edit `test/tools/conf.js` and run `npm test` from the project root directory.

Run it
------

    npm start

This creates a `conf.js` with the default settings for development.

Browse to `http://localhost:8080`.

Configuration
-------------
The default configuration is set up for development.

Before running this in production, you should definitely get or
[generate your own][ssl/tls] TLS key and cert, put them in the `tls/` directory,
and refer to them in the `https` settings in `conf.js`.

Basic auth is disabled by default. To use it, enable it in `conf.js` and create
a user with the `mkauth.js` script:

    bin/mkauth.js user:pass mongodb://localhost/db

This will add `user` to the `db` database with a hashed `pass`.
This user should now be able to log in to any routes requiring basic auth.

For security, you should not run the server as root. However, without root,
you won't be able to listen on ports 80 and 443. You can use
[iptables][iptables-wiki] to redirect traffic on 80 and 443 to higher ports.
[This][iptables-guide] doc outlines how to do that.

TODO
----
- Upgrade to node 4. Then use css minification in the gulpfile and reference the
  minified css in html files.
- In bin/server.js: drop permissions to a configurable user; this would allow
  the server to be started as root so that certs could be readable only by
  privileged users and there would be no need to redirect ports with iptables.
  https://thomashunter.name/blog/drop-root-privileges-in-node-js/
- Properly disconnect mongoose on SIGINT.
  http://theholmesoffice.com/mongoose-connection-best-practice/
- Consider doing something like `/docs/#Todo` in the UI so that specific docs
  can be bookmarked.
- Use ids in the api. These can be the string version of mongo's ObjectIds.
  Then allow the user to look up something by supplying the start of the id
  (like how git and docker do it), returning a 400 or something if there are
  multiple matches.
- Limit the name length on docs.
- Error objects in a json response don't need to include the field. It just adds
  complexity and isn't really that useful. The message should be enough to know
  what went wrong.
- Make an error response be a single object instead of array of them.
- Make the favicon smaller to conform to the spec. Can use png.
- There's currently a bug that's preventing the creation of more than one user.
  I believe this can be fixed by having a sparse index on the doc schema for the
  compound uniqueness between doc name and user; make sure to test using the
  same doc name for a doc with a user and for a doc with no (null) user.
- Add a `?select=` param to the API so that populating the list of docs in the
  UI doesn't also need to grab the body.
- Add/change tests for these new features/changes.


[node]:             http://nodejs.org/
[mongo]:            http://www.mongodb.org/
[iptables-wiki]:    https://wiki.archlinux.org/index.php/iptables
[iptables-guide]:   https://github.com/tylerbrazier/linux/blob/master/docs/iptables.md
[ssl/tls]:          https://github.com/tylerbrazier/linux/blob/master/docs/server.md#ssltls-certs
