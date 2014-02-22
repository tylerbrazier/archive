#!/usr/bin/env bash

# Recursively convert spaces to underscores and remove '[](): characters.
# It also replaces all cases of '_-_' with '-'
# Keep in mind that it does NOT prompt for overwrite.

[[ -z $1 ]] && { echo "Needs directory argument"; exit 0; }

find "$1" -depth -name '*' | while read file ; do
    dir=$(dirname "$file")
    old=$(basename "$file")
    new=$(echo "$old" | tr " " "_" | tr -d "'[]():" | sed "s/_-_/-/g")
    if [[ "$old" != "$new" ]]; then
        echo "Renaming $dir/$old"
        echo "To ----> $dir/$new"
        mv "$dir/$old" "$dir/$new"
        echo
    fi
done
echo "Done"

