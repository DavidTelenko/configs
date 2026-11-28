# Configs

A single source of all the configuration files for the tools I use, together with a bootstrap that installs the packages and links the configs into place on Linux, macOS and Windows.

It is constantly updating and is not a place familiar with stability.

# Layout

```
configs/             config files, one directory per app
platform/
  .manifest.yaml     packages to install and configs to mount
  .manifest.schema.json
  bootstrap.nu       installs packages and mounts configs from the manifest
  linux/             bootstrap.sh entry script + helper scripts
  darwin/            bootstrap.sh entry script
  win32/             bootstrap.ps1 entry script + helper scripts
```

# Installation

Every platform has a small entry script that does the same thing:

1. installs the package manager (Homebrew on macOS, scoop on Windows) if it is missing
2. installs git and [nushell](https://github.com/nushell/nushell) if they are missing
3. clones the repo to `~/.configs` when the script is run outside of it (e.g. straight from the web)
4. hands over to [bootstrap.nu](platform/bootstrap.nu), forwarding all arguments

| Platform | Entry script                                                 | Package manager  |
| -------- | ------------------------------------------------------------ | ---------------- |
| Linux    | [platform/linux/bootstrap.sh](platform/linux/bootstrap.sh)   | pacman, dnf, apt |
| macOS    | [platform/darwin/bootstrap.sh](platform/darwin/bootstrap.sh) | Homebrew         |
| Windows  | [platform/win32/bootstrap.ps1](platform/win32/bootstrap.ps1) | scoop            |

The repo is expected to live in `~/.configs`, some configs (PowerShell profile, kitty sessions) reference files there directly.

### From scratch

The entry scripts can be fetched and run directly, no git or clone needed:

```sh
# Linux
bash -c "$(curl -fsSL https://raw.githubusercontent.com/davidtelenko/configs/main/platform/linux/bootstrap.sh)"

# macOS
bash -c "$(curl -fsSL https://raw.githubusercontent.com/davidtelenko/configs/main/platform/darwin/bootstrap.sh)"
```

```powershell
# Windows
iex "& { $(iwr -useb https://raw.githubusercontent.com/davidtelenko/configs/main/platform/win32/bootstrap.ps1) }"
```

Arguments go after the script, e.g. `bash -c "$(curl ...)" bootstrap mount nvim` (the first word is the script name) or `iex "& { $(iwr ...) } mount nvim"`.

### From the repo

```sh
git clone https://github.com/davidtelenko/configs ~/.configs
~/.configs/platform/linux/bootstrap.sh
```

Without arguments it installs every package available on the system and mounts all configs of the platform. Every step can also be run on its own:

```sh
bootstrap.sh                      # install everything, then mount everything
bootstrap.sh install              # install all packages
bootstrap.sh install neovim tmux  # install only some packages
bootstrap.sh mount                # link all configs
bootstrap.sh mount nvim nushell   # link only some configs
bootstrap.sh unmount nvim         # remove links created by mount
bootstrap.sh --help               # full usage
```

Common flags:

- `-n, --dry-run` - print the plan without changing anything
- `-s, --system <name>` - use a system profile instead of detecting it (`arch`, `fedora`, `ubuntu`, `macos`, `windows`)
- `-p, --prefer <manager>` - try this package manager first for every package
- `-m, --manifest <path>` - read another manifest

Both `install` and `mount` are idempotent: already installed packages and already mounted configs are skipped. `mount` replaces whatever is at the target location, `unmount` only removes links it owns.

> [!NOTE]
> Run the bootstrap as a regular user, `sudo` is used where needed. On Windows file symlinks need Developer Mode or an elevated shell, directories are linked with junctions.

# Manifest

Everything the bootstrap does is described in [platform/.manifest.yaml](platform/.manifest.yaml), its fields are documented in [platform/.manifest.schema.json](platform/.manifest.schema.json):

- `platforms` - per OS shell, `PATH` additions, a `prepare` step and the default config directory
- `systems` - distro detection (`/etc/os-release`) and the ordered list of package managers to use
- `managers` - how to set up a manager, install packages with it and enable extra repos (copr, ppa, scoop buckets, ...)
- `packages` - which manager provides each package and under which name, with optional `prefer` and post-install `hooks`
- `mounts` - where each `configs/<name>` goes per platform: `true` for `<config dir>/<name>`, a path, a `{ source, target, mode }` mapping (`link` or `copy`), or custom `check` / `run` / `undo` commands

Supported systems:

- **Arch** (and Endeavour, Manjaro, CachyOS, Garuda, Artix) - pacman, yay, am, cargo, go, asdf
- **Fedora** (and Nobara, Ultramarine) - dnf, am, cargo, go, asdf
- **Ubuntu** (and Pop!\_OS, Mint, elementary, Zorin, Neon) - apt, am, cargo, go, asdf
- **macOS** - brew, cask, cargo, go, asdf
- **Windows** - scoop, winget

# What's inside

Configs mounted by the bootstrap (L - Linux, M - macOS, W - Windows):

### Editors

| Config                                         | L   | M   | W   |
| ---------------------------------------------- | --- | --- | --- |
| [Neovim](https://github.com/neovim/neovim)     | ✓   | ✓   | ✓   |
| [Helix](https://github.com/helix-editor/helix) | ✓   | ✓   | ✓   |

### Shells and multiplexers

| Config                                                 | L   | M   | W   |
| ------------------------------------------------------ | --- | --- | --- |
| [Nushell](https://github.com/nushell/nushell)          | ✓   | ✓   | ✓   |
| [PowerShell](https://github.com/PowerShell/PowerShell) |     |     | ✓   |
| [Tmux](https://github.com/tmux/tmux)                   | ✓   | ✓   |     |
| [Zellij](https://github.com/zellij-org/zellij)         | ✓   | ✓   |     |

### Terminal emulators

| Config                                                    | L   | M   | W   |
| --------------------------------------------------------- | --- | --- | --- |
| [Ghostty](https://github.com/ghostty-org/ghostty)         | ✓   | ✓   |     |
| [Kitty](https://sw.kovidgoyal.net/kitty/)                 | ✓   | ✓   |     |
| [Wezterm](https://wezfurlong.org/wezterm/index.html)      | ✓   | ✓   | ✓   |
| [Alacritty](https://github.com/alacritty/alacritty)       | ✓   |     | ✓   |
| [Foot](https://codeberg.org/dnkl/foot)                    | ✓   |     |     |
| [Rio](https://github.com/raphamorim/rio)                  |     |     | ✓   |
| [Windows Terminal](https://github.com/microsoft/terminal) |     |     | ✓   |

### Desktop (Wayland)

| Config                                          | L   | M   | W   |
| ----------------------------------------------- | --- | --- | --- |
| [Hyprland](https://hyprland.org/)               | ✓   |     |     |
| [Waybar](https://github.com/Alexays/Waybar)     | ✓   |     |     |
| [Rofi](https://github.com/davatorium/rofi)      | ✓   |     |     |
| [Dunst](https://github.com/dunst-project/dunst) | ✓   |     |     |

The Hyprland config also covers hypridle, hyprlock, hyprsunset and a few helper scripts (screenshots, media player, battery, cheatsheet).

### Keyboard

| Config                                                                 | L   | M   | W   |
| ---------------------------------------------------------------------- | --- | --- | --- |
| [Keyd](https://github.com/rvaiya/keyd)                                 | ✓   |     |     |
| [Karabiner-Elements](https://karabiner-elements.pqrs.org/)             |     | ✓   |     |
| [Kanata](https://github.com/jtroo/kanata)                              |     |     | ✓   |
| [Keymapper](https://github.com/houmain/keymapper)                      |     |     | ✓   |
| [PowerToys](https://github.com/microsoft/PowerToys) (keyboard manager) |     |     | ✓   |

### Media

| Config                                            | L   | M   | W   |
| ------------------------------------------------- | --- | --- | --- |
| [Mpv](https://mpv.io/)                            | ✓   | ✓   | ✓   |
| [Cmus](https://github.com/cmus/cmus)              | ✓   | ✓   |     |
| [Musikcube](https://github.com/clangen/musikcube) |     | ✓   | ✓   |

### Tools

| Config                                            | L   | M   | W   |
| ------------------------------------------------- | --- | --- | --- |
| [Git](https://git-scm.com/)                       | ✓   | ✓   | ✓   |
| [Ttyper](https://github.com/max-niederman/ttyper) | ✓   | ✓   | ✓   |
| [Tuicr](https://github.com/agavra/tuicr)          | ✓   | ✓   |     |
| [Broot](https://github.com/Canop/broot)           |     | ✓   | ✓   |
| [Asdf](https://github.com/asdf-vm/asdf)           | ✓   | ✓   |     |
| [VCMI](https://vcmi.eu/)                          | ✓   |     |     |

Configs kept in the repo but not mounted:

- [Oh My Posh](https://github.com/jandedobbeleer/oh-my-posh) theme, loaded from `~/.configs` by the PowerShell profile
- [Vimium C](https://github.com/gdh1995/vimium-c) settings
- [Telegram](https://desktop.telegram.org/) gruvbox theme
- GitHub user style
- KeePassXC database

Besides the configs the manifest installs a bunch of cli tools (fzf, zoxide, ripgrep, fd, bat, eza, delta, ...), languages, fonts (Roboto Mono Nerd Font), apps and games. See the `packages` section of the [manifest](platform/.manifest.yaml) for the full list.

# Notes

- **Git** - the config is not linked, `mount` adds `configs/git/.gitconfig` to `include.path` of the global git config, so machine specific settings stay out of the repo.

- **Keyd** - keyd reads its config from `/etc/keyd`, so the config is copied there with `sudo` and the service is restarted instead of linking.

- **Windows Terminal** - the settings are copied rather than linked, the terminal rewrites its config and some stuff tends to diverge between computers, so the repo only keeps the most general settings.

- **PowerToys** - only the keyboard manager mappings are mounted, everything else goes through its own backup system.

- **Vimium** - it does not support any automated backup mechanic, so the settings have to be imported manually.

- **Ghostty** - see [configs/ghostty/README.md](configs/ghostty/README.md) for disabling the GTK input method keybindings on Linux.
