$OutputEncoding = [Console]::InputEncoding = [Console]::OutputEncoding = New-Object System.Text.UTF8Encoding

Import-Module Microsoft.PowerShell.Utility

oh-my-posh init pwsh --config "~/.configs/oh-my-posh/themes/my.omp.toml" | Invoke-Expression

Set-PSReadlineOption -EditMode vi

$env:PYTHONIOENCODING='utf-8'

iex (& { (zoxide init powershell | Out-String) })

# Remove-Alias -fo @("where", "pwd", "rm", "ls", "mv", "cp")
