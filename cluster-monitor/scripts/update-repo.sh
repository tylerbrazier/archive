#!/bin/bash

# This is meant to be run from a machine with access to official deb repos.
# It downloads debs (specified in the 'packages' array) and their dependencies
# and adds them to ../packages/debs dir.
# Then it creates a Packages.gz file which contains metadata for the repo.
# Just make sure the sources.list file points to the debs dir.

# You might want to run `sudo aptitude update` before running this script to
# get the latest packages.

# To skip downloading packages from official repos just comment out each
# package in the 'packages' array.

# NOTE that for whatever reason, some packages fail to download but everything
# works fine when installing on client. Maybe those packages come with the base
# debian, I don't know.

# The nodejs-legacy package is just a wrapper around the nodejs package that
# adds a `/usr/bin/node` symlink which points to `/usr/bin/nodejs`.
# The `node` executable is needed for npm.
# nodejs-legacy requires the following in sources.list when running this script:
# 'deb http://ftp.us.debian.org/debian wheezy-backports main'

#set -e -u 

# These will be downloaded and added to custom repo
packages=(
sudo
git
puppet
openssh-client
openssh-server
python2.7-dev
python-pip
nodejs-legacy
python-cairo
)
script_dir=$(cd $(dirname $0); pwd)
debs_dir=$(readlink -f ${script_dir}/../packages/debs)

if ! type "dpkg-scanpackages" > /dev/null; then
    echo "This script requires 'dpkg-scanpackages' of package 'dpkg-dev' to run"
    exit 1
fi
if ! type "apt-rdepends" > /dev/null; then
    echo "This script requires 'apt-rdepends' to run"
    exit 1
fi

cd $debs_dir
for package in ${packages[@]}; do
  for depend in $(apt-rdepends $package | grep -v Depends); do
    aptitude download ${depend}
  done
done

dpkg-scanpackages . | gzip -9c > Packages.gz
