param(
    [string]$NirCmd = "nircmd.exe"
)

$taskbar = "Shell_TrayWnd"

# Read current opacity from a state file
$stateFile = Join-Path $env:TEMP "taskbar-opacity.state"

if (Test-Path $stateFile) {
    $opacity = [int](Get-Content $stateFile)
} else {
    $opacity = 255
}

$newOpacity = if ($opacity -eq 255) { 0 } else { 255 }

& $NirCmd win trans class $taskbar $newOpacity

Set-Content $stateFile $newOpacity
