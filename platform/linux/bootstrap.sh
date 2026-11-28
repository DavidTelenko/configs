#!/usr/bin/env bash

# Installs git and nushell with the native package manager, clones the repo to
# ~/.configs when run outside of it (e.g. straight from the web), then hands
# over to ../bootstrap.nu which installs everything from ../.manifest.yaml.
# All arguments are forwarded, see `./bootstrap.sh --help`.

set -euo pipefail

repo_url="https://github.com/davidtelenko/configs"
repo_dir="$HOME/.configs"

install() {
  . /etc/os-release
  local ids=" ${ID:-} ${ID_LIKE:-} "

  case "$ids" in
  *" arch "*)
    sudo pacman -Sy --needed --noconfirm "$@"
    ;;
  *" fedora "*)
    sudo dnf install -y "$@"
    ;;
  *" ubuntu "* | *" debian "*)
    sudo apt-get update
    if [[ " $* " == *" nushell "* ]]; then
      sudo apt-get install -y curl gpg
      curl -fsSL https://apt.fury.io/nushell/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/fury-nushell.gpg
      echo "deb [signed-by=/usr/share/keyrings/fury-nushell.gpg] https://apt.fury.io/nushell/ /" | sudo tee /etc/apt/sources.list.d/fury-nushell.list
      sudo apt-get update
    fi
    sudo apt-get install -y "$@"
    ;;
  *)
    echo "unsupported distro: ${ID:-unknown}" >&2
    exit 1
    ;;
  esac
}

missing=()
command -v git >/dev/null 2>&1 || missing+=(git)
command -v nu >/dev/null 2>&1 || missing+=(nushell)
[ ${#missing[@]} -eq 0 ] || install "${missing[@]}"

root="$(dirname "${BASH_SOURCE[0]:-}")/.."
if [ ! -f "$root/bootstrap.nu" ]; then
  [ -d "$repo_dir" ] || git clone "$repo_url" "$repo_dir"
  root="$repo_dir/platform"
fi

exec nu "$root/bootstrap.nu" "$@"
