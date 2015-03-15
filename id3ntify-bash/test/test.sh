#!/usr/bin/env bash
set -e

tmp=/tmp/id3ntify

# setup
cd $(dirname "$0")
rm -rf $tmp
mkdir -p $tmp
cp -r lib_root $tmp
touch $tmp/cache

../id3ntify.sh test.conf

echo "TEST: running again - tagging should be skipped due to cache"
../id3ntify.sh test.conf
