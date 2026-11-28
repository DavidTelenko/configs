# Installs scoop, git and nushell, clones the repo to ~/.configs when run
# outside of it (e.g. straight from the web), then hands over to
# ../bootstrap.nu which installs everything from ../.manifest.yaml.
# All arguments are forwarded, see `./bootstrap.ps1 --help`.

$ErrorActionPreference = 'Stop'

$repoUrl = 'https://github.com/davidtelenko/configs'
$repoDir = Join-Path $HOME '.configs'

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

$root = if ($PSScriptRoot) { Join-Path $PSScriptRoot '..' } else { '' }
if (-not $root -or -not (Test-Path (Join-Path $root 'bootstrap.nu')))
{
  if (-not (Test-Path $repoDir))
  {
    git clone $repoUrl $repoDir
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
  }
  $root = Join-Path $repoDir 'platform'
}

& nu (Join-Path $root 'bootstrap.nu') @args
exit $LASTEXITCODE
