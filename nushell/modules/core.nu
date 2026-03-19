export def symlink [
  link_name: path, # The name of the symlink
  existing: path,  # The existing file
] {
  let link_name = ($link_name | path expand)
  let existing = ($existing | path expand -s)

  if $nu.os-info.family != 'windows' {
    ln -s $existing $link_name | ignore
    return
  }

  if ($existing | path type) == 'dir' {
    mklink /D $link_name $existing
    return
  }

  mklink $link_name $existing
}

export def retry [
  blk: closure,
  --retries(-r): number = 5,
] {
  for _ in 0..<$retries {
    try {
      do $blk
      break
    }
  }
}

export def is-wezterm [] {
  $env.TERM_PROGRAM? == 'WezTerm'
}

export def is-kitty [] {
  "KITTY_WINDOW_ID" in $env
}

export def is-zellij [] {
  "ZELLIJ" in $env
}

export def is-windows [] {
  $nu.os-info.family == "windows"
}

export def is-macos [] {
  $nu.os-info.name == "macos"
}
