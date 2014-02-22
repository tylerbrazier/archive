Sync or swim - A simple directory synchronizing script
======================================================
Sos is basically a wrapper for rsync with the added idea that a syncronized
directory has one or more other "locations." You can think of a location as
being like a git remote. A location can be local or on a remote server and all
or some remotes can be pushed/pulled to/from in one command. Locations have
properties associated with them that you specify on creation; these properties
save you from having to remember and type out rsync options for commonly
synchronized directories.

How to use
----------

    sos [options...] <action> [locations...]

Options
-------

* `sos -h`  
Help.

* `sos -l`  
List locations and their properties.

* `sos -d <dir> <action>`  
Run for specified `<dir>`. The default is the current working directory.

* `sos -k <key> <action>`  
Run using specified `<key>`. Default is at ~/.ssh/id\_rsa.

* `sos -m <mode> <action>`  
Mode override. Run using specified `<mode>` for pushmode/pullmode.

* `sos -o <opts> <action>`  
Use `<opts>` for rsync options instead of the defaults -vhrtupEl

* `sos -a <opts> <action>`  
Use `<opts>` for rsync options in addition to defaults -vhrtupEl

Actions
-------
* `sos add [location...]`  
Create new location(s). You can add any number of locations and you can name
them whatever you want. sos will prompt you for information about each location
like whether it is a local or remote location, what directory to push/pull
to/from, etc. The script will create a .sos subdirectory (if it doesn't already
exist) and put a _name_.location file for each inside for each newly added
location.

* `sos remove [location...]`  
Removes all locations(s). If none are specified, this will remove them all.

* `sos push [location...]`  
Push to each specified location. If none are specified, push to all of them.
How each location is pushed to depends on the pushmode that was specified when
the location was added (see **Modes** below).

* `sos pull [location...]`  
Pull from each specified location. If none are specified, pull from all of them.
How each location is pulled from depends on the pullmode that was specified when
the location was added (see **Modes** below).

* `sos status [location...]`  
(Or just `sos stat [location...]`) This will cause sos to perform a dry-run push
and dry-run pull for each given location. If none are specified, it runs for all
locations.
                         
Modes
-----
When adding a location, you're asked to specify a pushmode and pullmode. There
are three kinds of each: Soft, Hard, and Ignore.

* Soft: Extra files that are in destination but not in source will *not* be
deleted.
* Hard: Extra files that are in destination but not in source *will* be deleted.
* Ignore: If ignore is chosen for pushmode, this location will never be pushed
to, even when doing operations like `sos push` where no locations are specified
but they are all used. The same is true for pullmode.

TODO
----
* How to handle backups?
* How to handle checkInstalled?
