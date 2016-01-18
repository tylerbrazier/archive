#!/bin/bash

# This script simply restarts carbon and apache in order to work around a bug
# we are facing described in https://github.com/gdbtek/setup-graphite/issues/2.
# The only argument to this script is the name of user who should run the
# carbon-cache deamon. Make sure to run this as root.

sudo -u $1 /opt/graphite/bin/carbon-cache.py stop
sudo -u $1 /opt/graphite/bin/carbon-cache.py start
service apache2 restart
sleep 1
sudo -u $1 /opt/graphite/bin/carbon-cache.py stop
sudo -u $1 /opt/graphite/bin/carbon-cache.py start
service apache2 restart
