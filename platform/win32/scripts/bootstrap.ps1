<#
.SYNOPSIS
    Bootstraps the system to this config snapshot

.DESCRIPTION
    This script is intended to be installed from this api request or manually
    and run as a starting point to clone the configs repository, install all
    the packages, and symlink the configs to appropriate configuration
    locations. There is a lot of other flags which all signify whether the
    targeted package config should be installed, for example if passed the
    -Nvim flag this script will install the config for neovim in dedicated
    directory as a symlink, if you want to work the other way around, you can
    pass the -All flag, and then pass any other flags to signify the need to
    omit this package configs from installation.

.PARAMETER SkipScoop
    Specifies whether the script should skip installing scoop. If you've
    manually installed scoop package manager and cloned the configuration
    repository, you can run this script with -NoScoop flag, which will skip
    several steps of the installation process and just proceed to package
    installation and configuration

.EXAMPLE
    iex "& { $(iwr -useb https://raw.githubusercontent.com/DavidTelenko/win-configs/master/bootstrap.ps1) } -All"
    Request script from web, install packages and configure all available in configs

.EXAMPLE
    bootstrap.ps1 -All -Keymapper
    Run script from local environment, configure all packages except keymapper
#>

param (
  [Switch] $SkipScoop = $false,
  [Switch] $All = $false,

  [Switch] $Alacritty = $false,
  [Switch] $Broot = $false,
  [Switch] $Git = $false,
  [Switch] $Helix = $false,
  [Switch] $Kanata = $false,
  [Switch] $Keymapper = $false,
  [Switch] $Mpv = $false,
  [Switch] $Musikcube = $false,
  [Switch] $Nushell = $false,
  [Alias("Neovim")]
  [Switch] $Nvim = $false,
  [Switch] $Powertoys = $false,
  [Alias("PowerShell")]
  [Switch] $Pwsh = $false,
  [Switch] $Rio = $false,
  [Switch] $Spotify = $false,
  [Switch] $Ttyper = $false,
  [Switch] $Wezterm = $false,
  [Alias("WindowsTerminal")]
  [Switch] $Winterm = $false
)

# If we start from scratch and got this script from web call we need to install
# scoop package manager first
if (!$SkipScoop)
{
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  Invoke-Expression "& { $(Invoke-RestMethod get.scoop.sh) } -RunAsAdmin"
}

# Once scoop is in our system we can proceed with git installation and clone
# all our configs
scoop install git
git clone https://github.com/DavidTelenko/win-configs.git ~/.configs

# installing all packages from scoopfile
scoop import ~/.configs/scoop/scoopfile.json

# installing configs respecting the users options
& ~/.configs/init.ps1 `
  -All `
  -Alacritty `
  -Broot `
  -Git `
  -Helix `
  -Kanata `
  -Keymapper `
  -Mpv `
  -Musikcube `
  -Nushell `
  -Nvim `
  -Powertoys `
  -Pwsh `
  -Rio `
  -Spotify `
  -Ttyper `
  -Wezterm `
  -Winterm
