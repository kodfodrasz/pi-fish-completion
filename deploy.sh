#!/usr/bin/env bash
# Install the local pi Fish completion into Fish's standard user completion path.
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
target="${XDG_CONFIG_HOME:-$HOME/.config}/fish/completions/pi.fish"

mkdir -p -- "$(dirname -- "$target")"
install -m 0644 -- "$repo_dir/pi.fish" "$target"
printf 'Installed %s\n' "$target"
