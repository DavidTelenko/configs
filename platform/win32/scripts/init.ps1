param (
  [Switch] $All = $false,

  [Switch] $Alacritty = $false,
  [Switch] $Broot = $false,
  [Switch] $Helix = $false,
  [Switch] $Git = $false,
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

$Pwsh = $All -xor $Pwsh
$Powertoys = $All -xor $Powertoys
$Nvim = $All -xor $Nvim
$Helix = $All -xor $Helix
$Git = $All -xor $Git
$Winterm = $All -xor $Winterm
$Rio = $All -xor $Rio
$Wezterm = $All -xor $Wezterm
$Nushell = $All -xor $Nushell
$Alacritty = $All -xor $Alacritty
$Broot = $All -xor $Broot
$Mpv = $All -xor $Mpv
$Ttyper = $All -xor $Ttyper
$Musikcube = $All -xor $Musikcube
$Keymapper = $All -xor $Keymapper
$Kanata = $All -xor $Kanata
$Spotify = $All -xor $Spotify

$curr = "$env:userprofile/.configs"
$scoop = "$env:userprofile/scoop/persist"

function Link
{
  param (
    [String] $Target,
    [String] $Existing
  )
  if (Test-Path -Path $Existing -PathType Container)
  {
    Remove-Item -r -fo $Target
    New-Item -i Junction -fo $Target -ta $Existing
    Write-Output "Linked: $Target -> $Existing"
  } elseif (Test-Path -Path $Existing -PathType Leaf)
  {
    Remove-Item -fo $Target
    New-Item -i SymbolicLink -fo $Target -ta $Existing
    Write-Output "Linked: $Target -> $Existing"
  }
}

function CopyContent
{
  param (
    [String] $Existing,
    [String] $Target
  )
  if (Test-Path -Path $Target -PathType Leaf)
  {
    $RawFile = Get-Content -Raw $Existing
    $Utf8Encoded = New-Object System.Text.UTF8Encoding $False
    [System.IO.File]::WriteAllLines($Target, $RawFile, $Utf8Encoded)
    Write-Output "Copied: $Existing > $Target"
  }
}

if ($Powertoys)
{
  Link `
    -t "$env:localappdata/Microsoft/PowerToys/Keyboard Manager/default.json" `
    -e "$curr/powertoys/keyboard-manager.json"
}
if ($Pwsh)
{
  Link -t $profile -e $curr/powershell/profile.ps1
}
if ($Alacritty)
{
  Link -t $env:appdata/alacritty -e $curr/alacritty
}
if ($Rio)
{
  Link -t $env:localappdata/rio -e $curr/rio
}
if ($Nvim)
{
  Link -t $env:localappdata/nvim -e $curr/nvim
}
if ($Helix)
{
  Link -t $env:appdata/helix -e $curr/helix
}
if ($Nushell)
{
  Link -t $env:appdata/nushell -e $curr/nushell
}
if ($Wezterm)
{
  Link -t $env:homepath/.config/wezterm -e $curr/wezterm
}
if ($Broot)
{
  Link -t $env:appdata/dystroy/broot -e $curr/broot
}
if ($Mpv)
{
  Link -t $scoop/mpv/portable_config -e $curr/mpv
}
if ($Ttyper)
{
  Link -t $env:appdata/ttyper -e $curr/ttyper
}
if ($Musikcube)
{
  Link -t $env:appdata/musikcube -e $curr/musikcube
}
if ($Keymapper)
{
  Link -t $env:appdata/keymapper -e $curr/keymapper
}
if ($Kanata)
{
  Link -t $env:appdata/kanata -e $curr/kanata
}

# NOTE: you don't need to turn off winterm in order to run this option, it will hot reload as of latest version
if ($Winterm)
{
  CopyContent -e $curr/windows-terminal/winterm.json -t $scoop/windows-terminal-preview/settings/settings.json
}

if ($Git)
{
  git config --global --add include.path "$curr\git\.gitconfig"
  git config --local --add include.path "..\.gitconfig"
}

# separate spicetify+spotx install
if ($Spotify)
{
  Invoke-Expression "& { $(Invoke-WebRequest -useb 'https://raw.githubusercontent.com/SpotX-Official/spotx-official.github.io/main/run.ps1') } -confirm_uninstall_ms_spoti -confirm_spoti_recomended_over -podcasts_off -block_update_on -start_spoti -new_theme -adsections_off -lyrics_stat spotify"
  Invoke-WebRequest -useb https://raw.githubusercontent.com/spicetify/spicetify-cli/master/install.ps1 | Invoke-Expression
  Invoke-WebRequest -useb https://raw.githubusercontent.com/spicetify/spicetify-marketplace/main/resources/install.ps1 | Invoke-Expression
}
