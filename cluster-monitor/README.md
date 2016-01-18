Cluster-monitor
===============
An abandoned project from work that never went into production. The idea was to
be able to collect data with statsd and display it with graphite. The whole
project was to be distributed as a bundle and everything would be set up
automatically by calling a puppet script.

Note that key.pem and cert.pem have been removed from the `configs/` dir in
case they are still being used somewhere else at work.

--------------------------------------------

Important note for when cloning this repo!:
Since statsd is a submodule, you'll have to run `git submodule init` and
`git submodule update` in order to get the sources for statsd. You'll also
need to run `git submodule update` if we ever pull from statsd upstream.
This page explains submodules really well:
http://git-scm.com/book/en/Git-Tools-Submodules

Run `sudo puppet apply configure.pp` on a base vm to turn it into a cluster
monitor. To distribute a self-installing script including everything, look at
the README in the selfinstall/ folder. Note that the script used to create the
installer follows symlinks in the payload; there are some important points about
this:

1. Firstly, the reason for this is so that we can simply link to the necessary
files in this project instead of having to copy them over.
2. This also means that if you add something new to the root of this project
you'll have to link to it in the payload.
3. It also means that if you put any other symlinks in this project outside of
the payload, they will be followed and the real contents will be archived.

The database for users is stored in /opt/graphite/storage/graphite.db.
Applying the puppet script will create this database if it doesn't exist and
set the default user:pass of admin:r3jDMVY5n5ftKpS. The users credentials stored
in this database are used for basic auth login to the graphite site and also for
login within the site to save graphs. You can add more users by running
`sudo -u clusmon python /opt/graphite/webapp/graphite/manage.py createsuperuser`
You'll be prompted to enter the new user's information. Applying the puppet
script will not delete this user. However, any changes made to the default user
will be reset when the puppet script is run again.

A note for the devs: In case you *do* want to set up a different default
user:pass, there's a few things that need to change after the script has been
run at least once (probably on a dev machine). You should probably stop all
services (see Services section) before running these commands.
I've encountered locking bugs when doing this, namely:
https://github.com/gdbtek/setup-graphite/issues/2

    cd /opt/graphite
    rm storage/graphite.db
    sudo -u clusmon python webapp/graphite/manage.py syncdb --no-initial-data
    sudo chown www-data storage/graphite.db
    sudo chmod 0664 storage/graphite.db
    cd webapp/graphite
    python manage.py dumpdata --indent=2 auth > fixtures/initial_data.json

This initial_data.json fixture is what puppet uses when ensuring graphite.db
is present. Just put this file in configs/, make relevant changes to
local_settings.py under DATABASES, and commit. Note that apache and carbon
should be restarted after making this change to avoid the db locking issues.

To wipe/clean out the whisper database, just delete the files in
/opt/graphite/storage/whisper.
http://stackoverflow.com/questions/9587161

Used info from the following sites to set up iptables:

* https://help.ubuntu.com/community/IptablesHowTo
* https://wiki.archlinux.org/index.php/Simple_stateful_firewall

The `update-repo.sh` can be used to turn a local directory into a debian repo.

A note about timezones: It may be necessary to change the timezone in
local_settings.py if the cluster monitor is at a location which is not in
the America/Chicago timezone.

A note about permissions; Currently, things are set up so that there are two
users: `insites` is a sudo user for maintenance and changing files; `clusmon`
is an unprivileged user for running the statsd and carbon daemons. These users
both belong to a common group for cases were both need (write) access to some
resources such as the /opt/graphite/storage directory.

Services
--------
Applying the puppet script will ensure that the four main services
(collectd, statsd, carbon, and the graphite web app) are running.

If you need to manually start/stop statsd, there is a wrapper script in
the scripts/ dir of this project:
`sudo -u clusmon statsd_service.sh <start|stop|staus>`

If you need to manually start/stop/status carbon:
`sudo -u clusmon python /opt/graphite/bin/carbon-cache.py <start|stop|status>`

If you need to manually start/stop/status apache:
`sudo service apache2 <start|stop|status>`

To manually start/stop/status collectd:
`sudo service collectd <start|stop|status>`

TODO
----
Are we able to perform well enough without memcache and carbon relay/aggregator?
