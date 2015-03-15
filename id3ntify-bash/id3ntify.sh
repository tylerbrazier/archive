#!/usr/bin/env bash
set -e

fail() {
  echo "$1" >&2
  exit 1
}

# set defaults
conf=/etc/id3ntify.conf
lib_root=/var/music
cache=/var/cache/id3ntify.cache

(( $# > 0 )) && conf="$1"

type eyeD3 >/dev/null 2>&1 || fail "eyeD3 isn't installed"
source "$conf" 2>/dev/null || fail "Unable to read conf at $conf"
[[ ! -d "$lib_root" ]] && fail "Library $lib_root doesn't exist"
[[ ! -r "$cache" ]] && fail "Unable to read cache file $cache"

IFS=$'\n'  # in case path contains spaces
for f in $(find "$lib_root" -name '*.mp3'); do
  # it would probably be more performant to hold cache in mem...
  if grep "$f" "$cache" >/dev/null; then
    echo "Skipping cached $f"
  else
    echo "Updating $f"
    path=$(realpath "$f")
    base=$(basename "$path" ".mp3")

    title="${base#*-}"
    track="${base%%-*}"
    album=$(basename $(dirname "$path"))
    artist=$(basename $(realpath $(dirname "$path")/..))
    genre=$(basename $(realpath $(dirname "$path")/../..))

    eyeD3 "${eyeD3_opts[@]}" \
      --title="${title/_/ }" \
      --track="$track" \
      --album="${album/_/ }" \
      --artist="${artist/_/ }" \
      --genre="${genre/_/ }" \
      "$f"

    echo "$f" >> "$cache"
  fi
done
