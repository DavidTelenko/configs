<#
.SYNOPSIS
    Bootstraps the system to this config snapshot

.DESCRIPTION
    This script is intended to be installed from this api request or manually
    and run as a starting point to clone the configs repository, install all
    the packages from the manifest, and mount the configs to appropriate
    configuration locations. Pass -Mount with config names to mount only those
    configs, all configs of the platform are mounted otherwise.

.PARAMETER SkipScoop
    Specifies whether the script should skip installing scoop. If you've
    manually installed scoop package manager and cloned the configuration
    repository, you can run this script with -SkipScoop flag, which will skip
    several steps of the installation process and just proceed to package
    installation and configuration

.PARAMETER Mount
    Names of the configs to mount, see `mounts` in platform/.manifest.yaml

.EXAMPLE
    iex "& { $(iwr -useb https://raw.githubusercontent.com/DavidTelenko/win-configs/master/bootstrap.ps1) }"
    Request script from web, install packages and mount all configs

.EXAMPLE
    bootstrap.ps1 -SkipScoop -Mount nvim, nushell
    Run script from local environment, install packages and mount only neovim and nushell configs
#>

param (
  [Switch] $SkipScoop = $false,
  [string[]] $Mount = @()
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

# installing all packages from the manifest
& ~/.configs/platform/win32/bootstrap.ps1 install

# mounting configs respecting the users options
& ~/.configs/platform/win32/bootstrap.ps1 mount @Mount
