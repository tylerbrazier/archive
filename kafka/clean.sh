#!/bin/bash
set -e -u
trap 'echo "Press [Enter] to close"; read' EXIT

clear  # clear git MOTD

echo "WARNING! This will remove all docker containers and images."
echo "This script is intended to be used in case docker is behaving badly."
echo "You'll need to run setup.sh afterwords to rebuild the images and "
echo "reconfigure the system."
echo "This will not delete any data stored in the shared folders."
echo "Press ctrl-C to cancel or [Enter] to continue."
read

echo
echo "Loading configuration.txt..."
cd "$(dirname "$0")"
source ./configuration.txt
echo

echo "Starting Boot2docker..."
cd "$b2d_dir"
./boot2docker.exe start
echo

cmd='
echo "Stopping all containers..."
docker kill $(docker ps -q) >/dev/null 2>&1

echo "Removing all containers..."
docker rm -f $(docker ps -aq) >/dev/null 2>&1

echo "Removing all images..."
docker rmi -f $(docker images -aq) >/dev/null 2>&1

echo "Verifying..."
[ -z $(docker ps -aq) ] && echo "All containers were successfully removed." \
                        || echo "Some container(s) were not removed."
[ -z $(docker images -aq) ] && echo "All images were successfully removed." \
                            || echo "Some image(s) were not removed."
'

./boot2docker.exe ssh "$cmd"
echo
