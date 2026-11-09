#!/bin/sh
# Install the local pi Fish completion into Fish's standard user completion path.
set -eu

repo_dir=$(CDPATH='' cd -P "$(dirname "$0")" && pwd)
target="${XDG_CONFIG_HOME:-$HOME/.config}/fish/completions/pi.fish"

mkdir -p -- "$(dirname -- "$target")"
install -m 0644 -- "$repo_dir/pi.fish" "$target"
printf 'Installed %s\n' "$target"
