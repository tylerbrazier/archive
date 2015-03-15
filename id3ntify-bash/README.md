id3ntify
========
*Note that although this has the same as another project in this archive repo,
they weren't really intended be the same project written in different languages.
I just reused the name because I thought it was clever and the other project is
dead anyway.*

This is a quick and dirty bash script that goes thru your music library and
tags your mp3s based on the directory structure of the library.

When id3ntify updates a file, it adds that file name to a cache so that
the same mp3s won't be rewritten every time the library is updated.

Install
-------
id3ntify uses [eyeD3](http://eyed3.nicfit.net/) for the heavy lifting so you'll
need to install that first. Then,

    make install

Usage
-----
Make sure to edit `/etc/id3ntify.conf` before running.

If `id3ntify` is executed without any arguments, it reads the configuration
from `/etc/id3ntify.conf`. You can call `id3ntify CONF` and it will read
configuration from `CONF` instead of the default location.

Currently, the way that mp3s are tagged is based on a specific library
directory structure:

    lib_root/genre/artist/album/N-title.mp3

Where `N` is the track number.
Underscores in the path will be replaced with spaces in the tag.
Maybe I'll make this path configurable later.

TODO
----

* instructions for setting up cron job
* maybe make an inverse tool for adding files to the library based on the tags,
  prompting for changes to be made - this would probably be faster than always
  renaming many files manually.
