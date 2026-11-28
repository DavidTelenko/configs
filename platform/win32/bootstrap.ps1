# Installs scoop, git and nushell, then hands over to ../bootstrap.nu which
# installs everything from ../.manifest.yaml.
# All arguments are forwarded, see `./bootstrap.ps1 --help`.

$ErrorActionPreference = 'Stop'

if (-not (Get-Command scoop -ErrorAction SilentlyContinue))
{
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
  Invoke-Expression "& { $(Invoke-RestMethod get.scoop.sh) } -RunAsAdmin"
}

foreach ($app in 'git', 'nu')
{
  if (-not (Get-Command $app -ErrorAction SilentlyContinue))
  {
    scoop install $app
  }
}

& nu (Join-Path $PSScriptRoot '..\bootstrap.nu') @args
exit $LASTEXITCODE
