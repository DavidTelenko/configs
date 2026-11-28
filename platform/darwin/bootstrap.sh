#!/usr/bin/env bash

# Installs Homebrew, git and nushell, clones the repo to ~/.configs when run
# outside of it (e.g. straight from the web), then hands over to
# ../bootstrap.nu which installs everything from ../.manifest.yaml.
# All arguments are forwarded, see `./bootstrap.sh --help`.

set -euo pipefail

repo_url="https://github.com/davidtelenko/configs"
repo_dir="$HOME/.configs"

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

# /usr/bin/git is a stub until the command line tools are installed
git --version >/dev/null 2>&1 || brew install git
command -v nu >/dev/null 2>&1 || brew install nushell

root="$(dirname "${BASH_SOURCE[0]:-}")/.."
if [ ! -f "$root/bootstrap.nu" ]; then
  [ -d "$repo_dir" ] || git clone "$repo_url" "$repo_dir"
  root="$repo_dir/platform"
fi

exec nu "$root/bootstrap.nu" "$@"
