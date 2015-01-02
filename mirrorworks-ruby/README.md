Mirrorworks
===========

*NOTE:* I am no longer going to do any more development for this tool. At this
point, it's stable and has really good features but I've decided to use Git
for file sync/backup since it has better history and I'm already using it for
development anyway. If you're looking for more features or changes, feel free
to fork the project and hack away :)

A handy rsync wrapper cli tool.

This is a dead-simple script that lets you easily set up pairs of files or
directories - called 'reflections' - and sync them locally or over the network
with commands like  
`$ mirrorworks push [reflection...]`  
and  
`$ mirrorworks pull [reflection...]`

Installation and Configuration
------------------------------
For Windows users, install [cygwin](http://www.cygwin.com/).

Make sure you have rsync and ruby installed.

Install the gem with  
`$ gem install mirrorworks`

Mirrorworks reads a configuration file at ~/.mirrorworksrc.json.
To create an example config file run:  
`$ mirrorworks setup`

This file contains some underlying rsync runtime options as well as a set of
'reflections'. Reflections are pairs files or directories that you want to have
synchronized. Each consists of a name, a local file/dir, and a remote file/dir.
There are a few things to remember when setting up your reflections:

* The name of each reflection should be unique and should not include spaces.
* Directory paths should end in a slash /.
* You can use '$HOME' or '~' to refer to your home directory.
* On windows, use cygwin style paths; for example, '/cygdrive/c/...'

Using Mirrorworks
-----------------
The script is very straightforward. For usage, run  
`$ mirrorworks --help`

Pushmodes/Pullmodes
-------------------
Since version 0.2.0, each reflection can optionally have a `pushmode` and a
`pullmode`. The value of each mode can be `soft`, `hard`, or `ignore`.

If a mode isn't included in the reflection, it will default to `soft`, which
does not delete any extra files when transferring (unless overridden with `-x`).

Using `hard` is the equivalent of supplying `-x` when running the command;
extra files on the destination that are not on the source will be deleted.

Providing `ignore` for a mode disables transfer for that mode. For example,
`"pushmode": "ignore"` would cause mirrorworks to always skip pushing that
reflection.

Development
-----------
For bug reports and feature requests, feel free to open an issue or make a
pull request on [github](https://github.com/tylerbrazier/mirrorworks).
