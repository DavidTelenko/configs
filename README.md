# Configs

This repo aims to create single simple source of all necessary system configuration file for all tools I need.

It is constantly updating and is not a place familiar with stability.

The future goal of this repo is to be reproducible on different operating systems. However for now this is not finished nor tested which is why sadly it only supports MS Windows (hence the name).

# What's inside

The main guts of this repo mostly contains configs for `nushell` and `neovim`. As of today windows does not support most of the frequently used shells and I am not really a huge fun of WSL so I decided to use `nushell`. The downside of this approach is that `nushell` does not come with fresh windows system (and we assume this repo is being installed on a fresh system in the first place) so writing a cross-platform `nu` bootstrap script is not an option. Thus this repo only contains the `ps1` bootstrap and init scripts which are simple initialization scripts for downloading and installing all the necessary packages as well as creating all the necessary symlinks to all folders in this directory.

The list of packages to be installed can be found in the [manifest](platform/.manifest.yaml)

Here the general list of configured packages:

### Editors:

- [Neovim](https://github.com/neovim/neovim)
- [Helix](https://github.com/helix-editor/helix) (a backup plan editor :D)

### Shells:

- [Nushell](https://github.com/nushell/nushell)
- [PowerShell](https://github.com/PowerShell/PowerShell)

### Terminal multiplexers:

- [Zellij](https://github.com/zellij-org/zellij)
- [Tmux](https://github.com/tmux/tmux)

### Terminal emulators:

- [Windows Terminal](https://github.com/microsoft/terminal)
- [Alacritty](https://github.com/alacritty/alacritty)
- [Kitty](https://sw.kovidgoyal.net/kitty/)
- [Wezterm](https://wezfurlong.org/wezterm/index.html)
- [Rio](https://github.com/raphamorim/rio)
- [Ghostty](https://github.com/ghostty-org/ghostty)

### Crucial for me Tools:

- [Fzf](https://github.com/junegunn/fzf)
- [Oh My Posh](https://github.com/jandedobbeleer/oh-my-posh)
- [Power Toys](https://github.com/microsoft/PowerToys)
- [Spicetify](https://github.com/spicetify) + [SpotX](https://github.com/SpotX-Official/SpotX)
- [Ttyper](https://github.com/max-niederman/ttyper)
- [Vimium](https://github.com/gdh1995/vimium-c) browser extension (that's just a simple little piece of backup)
- [Zoxide](https://github.com/ajeetdsouza/zoxide)

### Media:

- [Cmus](https://github.com/cmus/cmus)
- [Mpv](https://mpv.io/)
- [Musikcube](https://github.com/clangen/musikcube)

### Other tools:

- [Broot](https://github.com/Canop/broot)
- [Kanata](https://github.com/jtroo/kanata)
- [Keymapper](https://github.com/houmain/keymapper)
- [Lazygit](https://github.com/jesseduffield/lazygit)
- [Roboto Mono NF Font](https://www.nerdfonts.com/)
- [Vencord](https://vencord.dev/)

> [!NOTE]
> This is not a comprehensive list of all the packages in a
> [manifest](platform/.manifest.yaml). It is being constantly updated, and
> behaves similar to a living organism

# Installation

Every platform has a small entry script that installs nushell and hands over to [bootstrap.nu](platform/bootstrap.nu), which installs the packages and mounts (links) the configs described in the [manifest](platform/.manifest.yaml):

- Linux: `platform/linux/bootstrap.sh`
- macOS: `platform/darwin/bootstrap.sh`
- Windows: `platform/win32/bootstrap.ps1`

Without arguments it installs everything and mounts all configs of the platform. The steps can also be run separately, e.g. `bootstrap.sh install neovim`, `bootstrap.sh mount nvim nushell` or `bootstrap.sh unmount nvim`, add `-n` to see the plan without changing anything.

It's apparent that's a "chicken and an egg" problem may occur in the case of fresh system because the scoop is not yet installed however we need git in order to clone repo and run the bootstrap script.

The simple solution is to first just download the script manually (or via web request) then run it and it will do all dirty typing for us (_The Chicken method_).

This method can be run like this

```powershell
iex "& { $(iwr -useb https://raw.githubusercontent.com/DavidTelenko/win-configs/main/platform/win32/scripts/bootstrap.ps1) }"
```

> [!NOTE]
> If you want to only mount some configs pass their names with `-Mount`, e.g `-Mount nvim, nushell`. The names are the keys of `mounts` in the [manifest](platform/.manifest.yaml).

Another solution is to manually install scoop, clone repo and run bootstrap with
a `-SkipScoop` parameter this will effectively do the same.

If you left with some questions please take a look at a [bootstrap.ps1](platform/win32/scripts/bootstrap.ps1) documentation by invoking this command in powershell `help bootstrap.ps1` and `help bootstrap.ps1 -examples`

# Notes

- **Power Toys** - cannot be adequately configured using symlinks to its config files so we just use their own manual system of backing up stuff

- **Windows Terminal** - its better not to sym or hard link config file to the file in the config directory, after all its the terminal emulator and some stuff tends to diverge in different computers, so this repo only contains most general settings of my liking

- **Vimium** - it does not support any type of automated backup mechanic (as far as I know) so it's the same as with powertoys - manual import.

# Linux related configs

Still under construction, I have a [todo](https://github.com/DavidTelenko/markdowned/blob/main/todo/linux.md) which I just follow manually. At some point, I'll spend a day or two cooking up a single `init.sh` working for both arch and fedora based distros and OS windows.

- [Dunst](https://github.com/dunst-project/dunst)
- [Rofi](https://github.com/davatorium/rofi)
- [Waybar](https://github.com/Alexays/Waybar)
- [Hyprland](https://hyprland.org/)
- [Keyd](https://github.com/rvaiya/keyd)
- [Ghostty](https://github.com/mitchellh/ghostty)
- [Swww](https://github.com/LGFae/swww)
