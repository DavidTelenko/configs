use './dirs.nu' *
const core = [$modules, core.nu] | path join

use $core *

def read-lines [path: string] {
  [$configDir $path]
  | path join
  | if ($in | path exists) {
    $in
    | open --raw
    | lines
    | where { $in !~ '^ *#.+$' }
    | uniq
    # remove inline comments here
  }
}

def try-init [util, cmd] {
  if not (which $util | is-empty) {
    do $cmd
    return
  }

  $"($util) failed to run, try to install this util with cargo or package manager"
}

def get-prompt-dir [] {
  $env.PWD | path split | if (
    $in | zip ($nu.home-dir | path split) | all { $in.0 == $in.1 }
  ) {
    $env.PWD | str replace $nu.home-dir "~" | path split
  } else { $in } | if (
    ($in | length) > 2
  ) {
    $in | select 0 (($in | length) - 1) | [$in.0 '..' $in.1]
  } else { $in } | path join
}

$env.config = (
  $env.config?
  | default {}
  | upsert hooks { default {} }
  | upsert hooks.env_change { default {} }
  | upsert hooks.env_change.PWD { default [] }
)

$env.PROMPT_COMMAND = {||
  let duration = $env.CMD_DURATION_MS | into int | into duration --unit ms

  [
    $"(ansi green)@(whoami) "
    $"(ansi magenta)nu "
    $"(ansi yellow)(get-prompt-dir) "
    $"(ansi white)($duration)"
    $"(char newline)"
    $"(ansi light_blue)> "
  ] | str join
}

$env.PROMPT_COMMAND_RIGHT = {||
  let time_segment = [
    (ansi green)
    (date now | format date '%I:%M:%S %p')
  ]

  let last_exit_code = if ($env.LAST_EXIT_CODE != 0) {([
    (ansi rb)
    ($env.LAST_EXIT_CODE)
  ])} else { "" }

  [
    $last_exit_code (char space)
    # $time_segment
  ] | flatten | str join
}

$env.PROMPT_INDICATOR = {|| "" }
$env.PROMPT_INDICATOR_VI_INSERT = {|| "" }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "" }
$env.PROMPT_MULTILINE_INDICATOR = {|| "" }

$env.TRANSIENT_PROMPT_COMMAND = {|| "> " }
$env.TRANSIENT_PROMPT_INDICATOR = {|| "" }
$env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = {|| "" }
$env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = {|| "" }
$env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = {|| "" }
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = {|| "" }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
# The default for this is $nu.default-config-dir/scripts
$env.NU_LIB_DIRS = [
  ($nu.default-config-dir | path join 'scripts') # add <nushell-config-dir>/scripts
]

# Directories to search for plugin binaries when calling register
# The default for this is $nu.default-config-dir/plugins
$env.NU_PLUGIN_DIRS = [
  ($nu.default-config-dir | path join 'plugins') # add <nushell-config-dir>/plugins
]

# Load local config .env file, git ignored, machine local
read-lines '.env' | if not ($in | is-empty) {
  $in
  | each { split row '=' | { $in.0: $in.1 } }
  | reduce { |it| merge $it }
  | load-env
}

if not (is-windows) {
  # Assume apple silicon
  let HOMEBREW_PREFIX = if (is-macos) {
    '/opt/homebrew'
  } else {
    '/home/linuxbrew/.linuxbrew'
  }

  $env.PATH ++= [
    $'($HOMEBREW_PREFIX)/bin',
    $'($HOMEBREW_PREFIX)/sbin',
  ]

  if not (which brew | is-empty) {
    $env.HOMEBREW_PREFIX = $HOMEBREW_PREFIX
    $env.HOMEBREW_REPOSITORY = [$HOMEBREW_PREFIX, Homebrew] | path join
    $env.HOMEBREW_CELLAR = [$HOMEBREW_PREFIX, Cellar] | path join
  }

  # nvim linux integration
  $env.EDITOR = 'nvim'
  $env.MANPAGER = 'nvim +Man!'

  $env.PATH ++= [
    '/usr/local/bin',
    $'($env.HOME)/bin',
    $'($env.HOME)/.local/bin',
    $'($env.HOME)/.bun/bin',
    $'($env.HOME)/.cargo/bin',
    $'($env.HOME)/.spicetify',
    $'($env.HOME)/.zvm/self',
    $'($env.HOME)/.zvm/bin',
    $'($env.HOME)/go/bin',
    # (read-lines '.path') # for now disable
  ]
}

if (is-windows) {
  $env.TERM = 'xterm-256color'
  $env.Path = ($env.Path | split row (char esep)
    | prepend (read-lines '.path')
    | uniq
  )
}

try-init vivid {
  $env.LS_COLORS = (vivid generate gruvbox-dark-soft | str trim)
}

try-init zoxide {
  zoxide init nushell | save -f ([$autoload, zoxide.nu] | path join)
}

# fnm env hook
if not (which fnm | is-empty) {
  fnm env --json | from json | load-env

  $env.PATH ++= [(
    $env.FNM_MULTISHELL_PATH | path join (if (is-windows) {
      ''
    } else {
      'bin'
    })
  )]

  $env.config.hooks.env_change.PWD = (
    $env.config.hooks.env_change.PWD | append {
      condition: {
        ['.nvmrc' '.node-version', 'package.json']
        | any { path exists }
      }
      code: {
        fnm use --install-if-missing --silent-if-unchanged
      }
    }
  )
}

# zellij tab name env hook
if (is-zellij) {
  def branch-or-dir [] {
    if ('.git' | path exists) {
      return (git rev-parse --abbrev-ref HEAD)
    }
    return (get-prompt-dir)
  }

  let action = { branch-or-dir | zellij action rename-tab $in }

  $env.config.hooks.env_change.PWD = (
    $env.config.hooks.env_change.PWD | append $action
  )

  $env.config.hooks.pre_execution = (
    $env.config.hooks.pre_execution | append $action
  )
}

# oh-my-posh + wezterm integration
$nu.vendor-autoload-dirs | each {
  [$in, oh-my-posh.nu] | path join | rm -f $in
}

if not (is-wezterm) and not (is-zellij) and not (is-nvim) {
  try-init oh-my-posh {
    const theme = [$configDir, oh-my-posh, themes, my.omp.toml] | path join
    oh-my-posh init nu --eval --config $theme
  }
}
