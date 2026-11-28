#!/usr/bin/env bash

# Installs nushell with the native package manager, then hands over to
# scripts/bootstrap.nu which installs everything from .manifest.yaml.
# All arguments are forwarded, see `./bootstrap.sh --help`.

set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

install_nushell() {
  . /etc/os-release
  local ids=" ${ID:-} ${ID_LIKE:-} "

  case "$ids" in
  *" arch "*)
    sudo pacman -Sy --needed --noconfirm nushell
    ;;
  *" fedora "*)
    sudo dnf install -y nushell
    ;;
  *" ubuntu "* | *" debian "*)
    sudo apt-get update
    sudo apt-get install -y curl gpg
    curl -fsSL https://apt.fury.io/nushell/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/fury-nushell.gpg
    echo "deb [signed-by=/usr/share/keyrings/fury-nushell.gpg] https://apt.fury.io/nushell/ /" | sudo tee /etc/apt/sources.list.d/fury-nushell.list
    sudo apt-get update
    sudo apt-get install -y nushell
    ;;
  *)
    echo "unsupported distro: ${ID:-unknown}" >&2
    exit 1
    ;;
  esac
}

command -v nu >/dev/null 2>&1 || install_nushell

exec nu "$root/scripts/bootstrap.nu" "$@"
