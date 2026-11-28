#!/usr/bin/env bash

# Installs Homebrew and nushell, then hands over to ../bootstrap.nu which
# installs everything from ../.manifest.yaml.
# All arguments are forwarded, see `./bootstrap.sh --help`.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

load_brew() {
  for prefix in /opt/homebrew /usr/local; do
    if [ -x "$prefix/bin/brew" ]; then
      eval "$("$prefix/bin/brew" shellenv)"
      return
    fi
  done
}

command -v brew >/dev/null 2>&1 || load_brew

if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  load_brew
fi

command -v nu >/dev/null 2>&1 || brew install nushell

exec nu "$root/../bootstrap.nu" "$@"
