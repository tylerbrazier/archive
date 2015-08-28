#!/bin/bash

echo "Loading configuration.txt..."
cd "$(dirname "$0")"
source ./configuration.txt
echo

echo "Stopping Boot2docker..."
cd "$b2d_dir"
./boot2docker.exe stop

echo
