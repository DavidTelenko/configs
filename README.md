# Configs

This repo aims to create single simple source of all necessary system configuration file for all tools I need.

It is constantly updating and is not a place familiar with stability.

The future goal of this repo is to be reproducible on different operating systems. However for now this is not finished nor tested which is why sadly it only supports MS Windows (hence the name).

# What's inside

The main guts of this repo mostly contains configs for `nushell` and `neovim`. As of today windows does not support most of the frequently used shells and I am not really a huge fun of WSL so I decided to use `nushell`. The downside of this approach is that `nushell` does not come with fresh windows system (and we assume this repo is being installed on a fresh system in the first place) so writing a cross-platform `nu` bootstrap script is not an option. Thus this repo only contains the `ps1` bootstrap and init scripts which are simple initialization scripts for downloading and installing all the necessary packages as well as creating all the necessary symlinks to all folders in this directory.

The list of packages to be installed can be found in a [scoopfile](scoop/scoopfile.json)

Here the general list of configured packages:

### Editors:

- [Neovim](https://github.com/neovim/neovim)
- [Helix](https://github.com/helix-editor/helix) (a backup plan editor :D)

### Shells:

- [Nushell](https://github.com/nushell/nushell)
- [PowerShell](https://github.com/PowerShell/PowerShell)

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
> [scoopfile](scoop/scoopfile.json). It is being constantly updated, and
> behaves similar to a living organism

# Installation

To bootstrap the system run the `bootstrap.ps1` script followed by `init.ps1` script with names of tools you wish to link.

It's apparent that's a "chicken and an egg" problem may occur in the case of fresh system because the scoop is not yet installed however we need git in order to clone repo and run the bootstrap script.

The simple solution is to first just download the script manually (or via web request) then run it and it will do all dirty typing for us (_The Chicken method_).

This method can be run like this

```powershell
iex "& { $(iwr -useb https://raw.githubusercontent.com/DavidTelenko/win-configs/main/.scripts/windows/bootstrap.ps1) } -All"
```

> [!NOTE]
> If you want to skip some packages you can combine `-All` option with the name of the package you want to skip installing configs for e.g `-Pwsh` skips the powershell config completely.

> [!NOTE]
> If you want to only install some packages configs remove `-All` option and invoke the script with only the names of the packages you want to configure e.g passing only `-Pwsh` will configure only the powershell config for you.

Another solution is to manually install scoop, clone repo and run bootstrap with
a `-SkipScoop` parameter this will effectively do the same.

The names of the parameters for the [bootstrap.ps1](bootstrap.ps1) is the following:

- `-All`
- `-Pwsh` or `-PowerShell`
- `-Nvim` or `-Neovim`
- `-Helix`
- `-Lazygit`
- `-Winterm` or `-WindowsTerminal`
- `-Rio`
- `-Wezterm`
- `-Nushell`
- `-Alacritty`
- `-Broot`
- `-Mpv`
- `-Ttyper`
- `-Vencord`
- `-Musikcube`
- `-Keymapper`
- `-Kanata`

If you left with some questions please take a look at a [bootstrap.ps1](bootstrap.ps1) documentation by invoking this command in powershell `help bootstrap.ps1` and `help bootstrap.ps1 -examples`

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
