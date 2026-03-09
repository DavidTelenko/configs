# For now implemented only to work for windows, however all necessary
# mechanisms were put into this module to work seamlessly on any platform and
# to be semi-easily configurable

# Runs arbitury powershell command assuming it's installed on the system and
# mounted into Path env variable
def powershell_run [command] {
  powershell -NoProfile -Command $command
}

def load_win_impl [moduleName: string] {
  [$nushellDir, modules, impl, windows, $moduleName]
  | path join
  | open -r $in
  | return $in
}

# Implementation detail, acts like a switch between platform functions, it's
# not recommended to use this function outside the module
def impl [f, ...rest] {
  let platform = (
    $nu.os-info.family
    | if $in == 'windows' {{
      hibernate: {
        rundll32.exe powrprof.dll,SetSuspendState Hibernate
      }
      sleep: {
        rundll32.exe powrprof.dll,SetSuspendState Sleep
      }
      reboot: {
        shutdown.exe -r -t 00
      }
      bios: {
        shutdown.exe -r -fw -t 00
      }
      shutdown: {
        shutdown.exe -s -t 00
      }
      snooze: {
        "snooze.ps1" | load_win_impl $in | powershell_run $in | ignore
      }
      volume_set: { |val, pid|
        let win_volume = "volume.ps1" | load_win_impl $in

        if ($pid != null) {
          powershell_run $"($win_volume) [audio]::Volume = ($val)"
          return
        }

        powershell_run $"($win_volume) [audio]::Volume = ($val)"
      }
      volume_mute: {
        let win_volume = "volume.ps1" | load_win_impl $in
        powershell_run $"($win_volume) [audio]::Mute = $true"
      }
      volume_unmute: {
        let win_volume = "volume.ps1" | load_win_impl $in
        powershell_run $"($win_volume) [audio]::Mute = $false"
      }
      env_add: { |name, value|
        powershell_run $"[System.Environment]::SetEnvironmentVariable\(
        \"($name)\",
        \"($value)\",
        [System.EnvironmentVariableTarget]::User # Machine
        \)"
      }
      env_remove: { |name|
        powershell_run $"[System.Environment]::SetEnvironmentVariable\(
        \"($name)\",
        $null,
        [System.EnvironmentVariableTarget]::User # Machine
        \)"
      }
      path_add: { |path|
        powershell_run $"
        $currentPath = [System.Environment]::GetEnvironmentVariable\(
        'Path',
        [System.EnvironmentVariableTarget]::User
        \)

        if \($currentPath -split ';' -contains '($path)'\) {
        Write-Host -ForegroundColor 'Red' 'Path already present'
        return
        }

        [System.Environment]::SetEnvironmentVariable\(
        'Path',
        $currentPath + '($path)' + ';',
        [System.EnvironmentVariableTarget]::User # Machine
        \)

        Write-Host -ForegroundColor 'Green' 'Path successfully added'
        "
      }
      path_remove: { |path|
        powershell_run $"
        $currentPath = [System.Environment]::GetEnvironmentVariable\(
        'Path',
        [System.EnvironmentVariableTarget]::User
        \)

        $updatedPath = \($currentPath -split ';' | Where-Object {
        $_ -ne '($path)'
        }\) -join ';'

        [System.Environment]::SetEnvironmentVariable\(
        'Path',
        $updatedPath,
        [System.EnvironmentVariableTarget]::User # Machine
        \)

        Write-Host -ForegroundColor 'Green' 'Path successfully removed'
        "
      }
      path_list: {
        powershell_run $"
        $currentPath = [System.Environment]::GetEnvironmentVariable\(
        'Path',
        [System.EnvironmentVariableTarget]::User
        \)

        $currentPath -split ';' | ForEach-Object {
        Write-Host $_ -ForegroundColor 'Green'
        }
        "
      }
    }} else if $in == 'unix' {{
      hibernate: {
        systemctl hibernate
      }
      sleep: {
        systemctl suspend
      }
      reboot: {
        systemctl reboot
      }
      soft-reboot: {
        systemctl soft-reboot
      }
      bios: {
        systemctl reboot --firmware-setup
      }
      shutdown: {
        systemctl poweroff
      }
      volume_set: { |val, pid|
      }
      volume_mute: {
        amixer set Master toggle
      }
    }} else {{}}
  )

  do ($platform | get $f) ...$rest
}

# Puts computer to hibernation state if possible
export def hibernate [] { impl hibernate }

# Puts computer to sleep state if possible
export def sleep [] { impl sleep }

# Reboots computer
export def reboot [] { impl reboot }

# restart alias computer
export def soft-reboot [] { impl soft-reboot }

# Reboot alias
export def restart [] { impl reboot }

# Turns off computer
export def shutdown [] { impl shutdown }

# Turns off monitor(s)
export def snooze [] { impl snooze }

# Restars computer to bios
export def bios [] { impl bios }

# Sends notification
export def notify [
  message: string
] {
  use speak.nu;
  use std;

  speak $message

  (
    ffplay
    -autoexit
    -fs
    -loglevel quiet
    -loop 10
    -nodisp
    -volume 30
    $env.NOTIFICATION_AUDIO
  )
}

# Sets volume to desired value
export def "volume set" [
  value: float,
  --pid: int,
] {
  impl volume_set $value $pid
}

export def "volume mute" [] { impl volume_mute }

export def "volume unmute" [] { impl volume_unmute }

# Adds env variable
export def "env add" [
  name: string,
  value: string,
] {
  impl env_add $name $value
}

# Removes env variable
export def "env remove" [name: string] { impl env_remove $name }

# Adds value to PATH env variable
export def "path add" [path: string] { impl path_add $path }

# Removes value from PATH env variable
export def "path remove" [path: string] { impl path_remove $path }

# Lists all paths in PATH env variable
export def "path list" [] { impl path_list }

# Alias for sys
export def main [] {
  sys
}
