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

# Load local config .env file, git ignored, machine local
export def user-env [root: string = $configDir] {
  [$root '.env'] | path join | read-lines $in | if not ($in | is-empty) {
    $in
    | where not ($it | is-empty)
    | each { split row --number 2 '=' | { $in.0: $in.1 } }
    | reduce { |it| merge $it }
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

export def is-nvim [] {
  "NVIM" in $env
}
