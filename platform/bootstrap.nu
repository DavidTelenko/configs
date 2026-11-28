#!/usr/bin/env nu

# Installs packages and mounts configs described in `platform/.manifest.yaml`
# for the current system.

const repo = path self ..
const default_manifest = path self .manifest.yaml

const entry_fields = [name repo check run]
const mount_fields = [source target mode check run undo]

def info [message: string] {
  print $"(ansi green_bold)==>(ansi reset) (ansi default_bold)($message)(ansi reset)"
}

def warn [message: string] {
  print $"(ansi yellow_bold)warning:(ansi reset) ($message)"
}

def as-list []: any -> list {
  let value = $in
  match ($value | describe) {
    "nothing" => []
    "string" => [$value]
    _ => $value
  }
}

def is-record []: any -> bool {
  $in | describe | str starts-with "record"
}

def is-list []: any -> bool {
  $in | describe | str starts-with "list"
}

def index-of [value: any]: list -> int {
  $in | enumerate | where item == $value | get -o 0.index | default (-1)
}

# Replaces `{key}` placeholders with values from the record.
def fill [values: record]: any -> any {
  let template = $in
  if $template == null {
    return null
  }
  $values | transpose key value | reduce --fold $template {|it, acc| $acc | str replace --all $"{($it.key)}" $it.value }
}

# Runs a command in the platform shell with its output attached to the terminal.
def run [shell: list<string>, command: string]: nothing -> bool {
  try { ^($shell | first) ...($shell | skip 1) $command; true } catch { false }
}

# Runs a command in the platform shell silently, used for `check` commands.
def succeeds [shell: list<string>, command: string]: nothing -> bool {
  try { (^($shell | first) ...($shell | skip 1) $command | complete).exit_code == 0 } catch { false }
}

def os-release []: nothing -> record {
  if not ("/etc/os-release" | path exists) {
    return {}
  }
  open /etc/os-release
  | lines
  | where $it =~ '^[A-Z_]+='
  | parse '{key}={value}'
  | reduce --fold {} {|it, acc| $acc | upsert $it.key ($it.value | str trim --char '"') }
}

def detect-system [manifest: record] {
  let platform = $nu.os-info.name
  if $platform not-in ($manifest.platforms | columns) {
    error make --unspanned { msg: $"unsupported platform `($platform)`, pass --system explicitly" }
  }

  let candidates = $manifest.systems | transpose name spec | where spec.platform == $platform
  if ($candidates | length) == 1 and ($candidates.0.spec.match? | as-list | is-empty) {
    return $candidates.0.name
  }

  let os = os-release
  let ids = [($os.ID? | default "")] ++ ($os.ID_LIKE? | default "" | split row " ") | where $it != ""
  for id in $ids {
    let found = $candidates | where {|system| $id in ($system.spec.match? | as-list) }
    if ($found | is-not-empty) {
      return $found.0.name
    }
  }

  error make --unspanned { msg: $"unsupported ($platform) system \(ID: ($ids | str join ', ')\), pass --system explicitly" }
}

# Managers without `install` only run commands, so a string entry is the command.
def normalize-entry [package: string, entry: any, command_only: bool]: nothing -> record {
  let spec = match ($entry | describe) {
    "bool" => ({})
    "string" => (if $command_only { {run: $entry} } else { {name: $entry} })
    _ => $entry
  }

  {
    name: ($spec.name? | default $package)
    repos: ($spec.repo? | as-list)
    check: $spec.check?
    run: $spec.run?
  }
}

# A hook is a command for every platform or a mapping of platform to command.
def platform-command [platform: string]: any -> any {
  let value = $in
  if ($value | is-record) { $value | get -o $platform } else { $value }
}

def unknown-fields [path: string, value: any, allowed: list<string>]: nothing -> list<string> {
  if not ($value | is-record) {
    return [$"($path): expected a mapping"]
  }
  $value | columns | where $it not-in $allowed | each {|field| $"($path): unknown field `($field)`" }
}

def validate-command [path: string, value: any, platforms: list<string>]: nothing -> list<string> {
  if ($value | describe) == "string" {
    return []
  }
  if not ($value | is-record) {
    return [$"($path): expected a command or a mapping of platform to command"]
  }
  $value | transpose platform command | each {|it|
    if $it.platform not-in $platforms {
      $"($path): unknown platform `($it.platform)`"
    } else if ($it.command | describe) != "string" {
      $"($path).($it.platform): expected a command"
    }
  } | compact
}

def validate-mount [path: string, name: string, item: any, platform: record]: nothing -> list<string> {
  let type = $item | describe
  if $type == "bool" and $item != true {
    return [$"($path): only `true` is allowed, remove the entry instead"]
  }
  if $type != "bool" and $type != "string" and not ($item | is-record) {
    return [$"($path): expected `true`, a target path or a mapping"]
  }
  let spec = match $type {
    "bool" => ({})
    "string" => {target: $item}
    _ => $item
  }

  mut errors = unknown-fields $path $spec $mount_fields
  let mode = $spec.mode? | default "link"
  if $mode not-in [link copy] {
    $errors = $errors | append $"($path): unknown mode `($mode)`, expected `link` or `copy`"
  }
  if $spec.run? != null {
    return $errors
  }

  for field in [check undo] {
    if ($spec | get -o $field) != null {
      $errors = $errors | append $"($path): `($field)` only applies together with `run`"
    }
  }
  let source = $repo | path join configs ($spec.source? | default $name)
  if not ($source | path exists) {
    $errors = $errors | append $"($path): source `($source)` does not exist"
  } else if $mode == "copy" and ($source | path type) != "file" {
    $errors = $errors | append $"($path): `copy` mode only supports files"
  }
  if $spec.target? == null and $platform.config? == null {
    $errors = $errors | append $"($path): the platform has no `config` directory for the default target"
  }
  $errors
}

def validate [manifest: record]: nothing -> list<string> {
  let platforms = $manifest.platforms? | default {} | columns
  let managers = $manifest.managers? | default {} | columns
  let systems = $manifest.systems? | default {} | columns
  let packages = $manifest.packages? | default {} | columns
  mut errors = unknown-fields "manifest" $manifest [platforms systems managers packages mounts]

  for platform in ($manifest.platforms? | default {} | transpose name spec) {
    $errors = $errors ++ (unknown-fields $"platforms.($platform.name)" $platform.spec [shell prepare path config])
    if ($platform.spec.shell? | as-list | is-empty) {
      $errors = $errors | append $"platforms.($platform.name): `shell` is empty"
    }
  }

  for system in ($manifest.systems? | default {} | transpose name spec) {
    let path = $"systems.($system.name)"
    $errors = $errors ++ (unknown-fields $path $system.spec [platform match managers])
    let platform = $system.spec.platform?
    if $platform not-in $platforms {
      $errors = $errors | append $"($path): unknown platform `($platform)`"
    }
    let siblings = $manifest.systems | values | where platform? == $platform | length
    if $siblings > 1 and ($system.spec.match? | as-list | is-empty) {
      $errors = $errors | append $"($path): `match` is required when several systems share platform `($platform)`"
    }
    for manager in ($system.spec.managers? | as-list) {
      if $manager not-in $managers {
        $errors = $errors | append $"($path): unknown manager `($manager)`"
      }
    }
  }

  for manager in ($manifest.managers? | default {} | transpose name spec) {
    $errors = $errors ++ (unknown-fields $"managers.($manager.name)" $manager.spec [install requires check setup refresh repos])
    for required in ($manager.spec.requires? | as-list) {
      if $required not-in $packages {
        $errors = $errors | append $"managers.($manager.name): requires unknown package `($required)`"
      }
    }
    for repo in ($manager.spec.repos? | default {} | transpose name spec) {
      $errors = $errors ++ (unknown-fields $"managers.($manager.name).repos.($repo.name)" $repo.spec [run check])
      if $repo.spec.run? == null {
        $errors = $errors | append $"managers.($manager.name).repos.($repo.name): `run` is missing"
      }
    }
  }

  for package in ($manifest.packages? | default {} | transpose name spec) {
    let path = $"packages.($package.name)"

    if not ($package.spec | is-record) {
      $errors = $errors | append $"($path): must be a mapping of managers"
      continue
    }

    for key in ($package.spec | columns) {
      let value = $package.spec | get $key

      if $key == "prefer" {
        let preferred = if ($value | is-record) {
          for system in ($value | columns) {
            if $system not-in $systems {
              $errors = $errors | append $"($path).prefer: unknown system `($system)`"
            }
          }
          $value | values | each { as-list } | flatten
        } else {
          $value | as-list
        }
        for manager in $preferred {
          if $manager not-in $managers {
            $errors = $errors | append $"($path).prefer: unknown manager `($manager)`"
          }
        }
        continue
      }

      if $key == "platforms" {
        for platform in ($value | as-list) {
          if $platform not-in $platforms {
            $errors = $errors | append $"($path).platforms: unknown platform `($platform)`"
          }
        }
        continue
      }

      if $key == "hooks" {
        $errors = $errors ++ (unknown-fields $"($path).hooks" $value [pre post])
        if ($value | is-record) {
          for hook in ($value | transpose name command) {
            $errors = $errors ++ (validate-command $"($path).hooks.($hook.name)" $hook.command $platforms)
          }
        }
        continue
      }

      if $key not-in $managers {
        $errors = $errors | append $"($path): unknown manager `($key)`"
        continue
      }

      let type = $value | describe
      if $type == "bool" and $value != true {
        $errors = $errors | append $"($path).($key): only `true` is allowed, remove the entry instead"
        continue
      }
      if $type != "bool" and $type != "string" and not ($value | is-record) {
        $errors = $errors | append $"($path).($key): expected `true`, a string or a mapping"
        continue
      }
      if ($value | is-record) {
        for field in ($value | columns) {
          if $field not-in $entry_fields {
            $errors = $errors | append $"($path).($key): unknown field `($field)`"
          }
        }
      }

      let manager = $manifest.managers | get $key
      let entry = normalize-entry $package.name $value ($manager.install? == null)
      let repos = $manager.repos? | default {} | columns
      for repo in $entry.repos {
        if $repo not-in $repos {
          $errors = $errors | append $"($path).($key): unknown repo `($repo)` for `($key)`"
        }
      }
      if $manager.install? == null and $entry.run == null {
        $errors = $errors | append $"($path).($key): command is missing, `($key)` has no install command"
      }
    }
  }

  for mount in ($manifest.mounts? | default {} | transpose name spec) {
    let path = $"mounts.($mount.name)"
    if not ($mount.spec | is-record) {
      $errors = $errors | append $"($path): must be a mapping of platforms"
      continue
    }
    for platform in ($mount.spec | columns) {
      if $platform not-in $platforms {
        $errors = $errors | append $"($path): unknown platform `($platform)`"
        continue
      }
      let value = $mount.spec | get $platform
      let items = if ($value | is-list) { $value } else { [$value] }
      for item in ($items | enumerate) {
        let item_path = if ($value | is-list) { $"($path).($platform).($item.index)" } else { $"($path).($platform)" }
        $errors = $errors ++ (validate-mount $item_path $mount.name $item.item ($manifest.platforms | get $platform))
      }
    }
  }

  $errors
}

# Checks that names hardcoded in the schema match the ones defined in the manifest.
def validate-schema [manifest: record, schema: record]: nothing -> list<string> {
  [
    [kind key defined known];
    [platform platformName ($manifest.platforms | columns) $schema.definitions.platformName.enum]
    [system systemName ($manifest.systems | columns) $schema.definitions.systemName.enum]
    [manager managerName ($manifest.managers | columns) $schema.definitions.managerName.enum]
  ]
  | each {|names|
    let missing = $names.defined | where $it not-in $names.known | each {|name| $"($names.kind) `($name)` is missing from definitions.($names.key)" }
    let stale = $names.known | where $it not-in $names.defined | each {|name| $"($names.kind) `($name)` in definitions.($names.key) is not defined in the manifest" }
    $missing ++ $stale
  }
  | flatten
  | each {|error| $"schema is out of date: ($error)" }
}

def print-errors [message: string]: list<string> -> nothing {
  let errors = $in
  if ($errors | is-not-empty) {
    $errors | each {|error| print $"(ansi red_bold)error:(ansi reset) ($error)" }
    error make --unspanned { msg: $message }
  }
}

# Reads and validates the manifest, then picks the system to work with.
def load [manifest: any, system: any]: nothing -> record {
  let manifest_path = $manifest | default $default_manifest | path expand
  let manifest = open $manifest_path
  let schema_path = $manifest_path | path dirname | path join .manifest.schema.json

  mut errors = validate $manifest
  if ($errors | is-empty) and ($schema_path | path exists) {
    $errors = validate-schema $manifest (open $schema_path)
  }
  $errors | print-errors "invalid manifest"

  let system = $system | default (detect-system $manifest)
  if $system not-in ($manifest.systems | columns) {
    error make --unspanned { msg: $"unknown system `($system)`, expected one of: ($manifest.systems | columns | str join ', ')" }
  }

  let system_spec = $manifest.systems | get $system
  let platform_spec = $manifest.platforms | get $system_spec.platform
  {
    manifest: $manifest
    system: $system
    platform: $system_spec.platform
    platform_spec: $platform_spec
    shell: $platform_spec.shell
    managers: $system_spec.managers
  }
}

# Runs the platform `prepare` command and extends `PATH` before changing anything.
def --env activate [ctx: record] {
  let prepare = $ctx.platform_spec.prepare?
  if $prepare != null and not (run $ctx.shell $prepare) {
    error make --unspanned { msg: "platform prepare command failed" }
  }
  $env.PATH = $env.PATH | prepend ($ctx.platform_spec.path? | default [] | path expand) | uniq
}

def priority [system: string, managers: list<string>, package: record, global: list<string>]: nothing -> list<string> {
  let prefer = $package.prefer?
  let preferred = if ($prefer | is-record) { $prefer | get -o $system | as-list } else { $prefer | as-list }

  $global ++ $preferred ++ $managers | uniq | where $it in $managers
}

def resolve [ctx: record, package: string]: nothing -> record {
  let spec = $ctx.manifest.packages | get $package
  let available = $spec | columns
  let allowed = $spec.platforms? == null or $ctx.platform in ($spec.platforms | as-list)
  let manager = if $allowed {
    priority $ctx.system $ctx.managers $spec $ctx.prefer | where $it in $available | get -o 0
  }
  let hooks = {
    pre: ($spec.hooks?.pre? | platform-command $ctx.platform)
    post: ($spec.hooks?.post? | platform-command $ctx.platform)
  }

  if $manager == null {
    return {package: $package, manager: null, name: null, repos: [], check: null, run: null, hooks: $hooks}
  }

  let command_only = ($ctx.manifest.managers | get $manager | get -o install) == null
  {package: $package, manager: $manager} | merge (normalize-entry $package ($spec | get $manager) $command_only) | insert hooks $hooks
}

# Resolves requested packages together with packages required by their managers.
def build-plan [ctx: record, requested: list<string>]: nothing -> list<record> {
  mut pending = $requested
  mut seen = []
  mut plan = []

  while ($pending | is-not-empty) {
    let package = $pending | first
    $pending = $pending | skip 1
    if $package in $seen {
      continue
    }
    $seen = $seen | append $package

    let resolved = resolve $ctx $package
    $plan = $plan | append $resolved
    if $resolved.manager != null {
      let requires = $ctx.manifest.managers | get $resolved.manager | get -o requires | as-list
      $pending = $pending ++ $requires
    }
  }

  $plan
}

def check-plan [ctx: record, plan: list<record>]: nothing -> list<string> {
  let used = $plan | where manager != null | get manager | uniq
  mut errors = []

  for manager in $used {
    let position = $ctx.managers | index-of $manager
    for required in ($ctx.manifest.managers | get $manager | get -o requires | as-list) {
      let source = $plan | where package == $required | get -o 0.manager
      if $source == null {
        $errors = $errors | append $"`($manager)` requires `($required)`, which has no source on ($ctx.system)"
      } else if ($ctx.managers | index-of $source) >= $position {
        $errors = $errors | append $"`($manager)` requires `($required)`, which resolves to `($source)`; it must come from a manager listed before `($manager)`"
      }
    }
  }

  $errors
}

def install-items [shell: list<string>, spec: record, items: list<record>, result: closure]: nothing -> list<record> {
  mut results = []

  for item in ($items | where run != null) {
    $results = $results | append (do $result $item (if (run $shell $item.run) { "installed" } else { "failed" }))
  }

  let regular = $items | where run == null
  if ($regular | is-empty) {
    return $results
  }

  let batch = $spec.install | str contains '{pkgs}'
  let batch_ok = $batch and (run $shell ($spec.install | str replace --all '{pkgs}' ($regular | get name | str join ' ')))

  if $batch_ok {
    return ($results ++ ($regular | each {|item| do $result $item installed }))
  }
  if $batch {
    warn "batch install failed, retrying one by one"
  }

  for item in $regular {
    let command = $spec.install | str replace --all '{pkgs}' $item.name | str replace --all '{pkg}' $item.name
    $results = $results | append (do $result $item (if (run $shell $command) { "installed" } else { "failed" }))
  }

  $results
}

def install-with [ctx: record, manager: string, items: list<record>, done: list<record>]: nothing -> list<record> {
  let spec = $ctx.manifest.managers | get $manager
  let shell = $ctx.shell
  let result = {|item, status| {package: $item.package, manager: $manager, name: $item.name, status: $status} }

  info $"($manager): ($items | get package | str join ' ')"

  let blocked = $spec.requires? | as-list | where {|required|
    $done | where package == $required and status in [failed unavailable] | is-not-empty
  }
  if ($blocked | is-not-empty) {
    warn $"($manager) is unusable, missing: ($blocked | str join ', ')"
    return ($items | each {|item| do $result $item skipped })
  }

  let needs_setup = if $spec.check? != null { not (succeeds $shell $spec.check) } else { $spec.setup? != null }
  if $needs_setup {
    if $spec.setup? == null {
      warn $"($manager) is not available and has no setup command"
      return ($items | each {|item| do $result $item failed })
    }
    info $"setting up ($manager)"
    if not (run $shell $spec.setup) {
      warn $"failed to set up ($manager)"
      return ($items | each {|item| do $result $item failed })
    }
  }

  mut refresh = false
  for repo in ($items | get repos | flatten | uniq) {
    let repo_spec = $spec.repos | get $repo
    if $repo_spec.check? != null and (succeeds $shell $repo_spec.check) {
      continue
    }
    info $"enabling ($manager) repo ($repo)"
    if (run $shell $repo_spec.run) {
      $refresh = true
    } else {
      warn $"failed to enable repo ($repo)"
    }
  }
  if $refresh and $spec.refresh? != null {
    run $shell $spec.refresh | ignore
  }

  let present = $items | where {|item| $item.check != null and (succeeds $shell $item.check) }
  mut results = $present | each {|item| do $result $item present }

  mut ready = []
  for item in ($items | where package not-in ($present | get package)) {
    if $item.hooks.pre != null and not (run $shell $item.hooks.pre) {
      warn $"pre-install hook of ($item.package) failed"
      $results = $results | append (do $result $item failed)
    } else {
      $ready = $ready | append $item
    }
  }
  $results = $results ++ (install-items $shell $spec $ready $result)

  $results | each {|row|
    let post = $items | where package == $row.package | get -o 0.hooks.post
    if $post == null or $row.status not-in [installed present] {
      $row
    } else if (run $shell $post) {
      $row
    } else {
      warn $"post-install hook of ($row.package) failed"
      $row | update status failed
    }
  }
}

def install-plan [ctx: record, packages: list<string>]: nothing -> record {
  let manifest = $ctx.manifest
  let unknown = $packages | where $it not-in ($manifest.packages | columns)
  if ($unknown | is-not-empty) {
    error make --unspanned { msg: $"unknown packages: ($unknown | str join ', ')" }
  }

  # Packages only installable on other platforms are skipped silently.
  let platform_managers = $manifest.systems | values | where platform == $ctx.platform | get managers | flatten | uniq
  let relevant = $manifest.packages | transpose name spec | where {|package|
    ($package.spec.platforms? == null or $ctx.platform in ($package.spec.platforms | as-list)) and ($package.spec | columns | any {|key| $key in $platform_managers })
  } | get name

  let requested = if ($packages | is-empty) { $relevant } else { $packages }
  let plan = build-plan $ctx $requested
  check-plan $ctx $plan | print-errors "cannot build install plan"

  let available = $plan | where manager != null
  let unavailable = $plan | where manager == null

  info $"install plan for ($ctx.system)"
  print (
    $available
    | select package manager name repos
    | update repos { str join ' ' }
    | sort-by {|row| $ctx.managers | index-of $row.manager } package
    | table --index false
  )
  for item in $unavailable {
    warn $"($item.package) has no source on ($ctx.system), skipping"
  }
  if ($packages | is-empty) {
    let skipped = ($manifest.packages | columns | length) - ($relevant | length)
    print $"($available | length) to install, ($unavailable | length) unavailable, ($skipped) for other platforms"
  }

  {available: $available, unavailable: $unavailable}
}

def install-run [ctx: record, plan: record]: nothing -> bool {
  mut results = $plan.unavailable | each {|item| {package: $item.package, manager: null, name: null, status: unavailable} }
  for manager in $ctx.managers {
    let items = $plan.available | where manager == $manager
    if ($items | is-not-empty) {
      $results = $results ++ (install-with $ctx $manager $items $results)
    }
  }
  let results = $results

  info "install summary"
  print ($results | where status != "installed" | sort-by status package)
  let count = {|status| $results | where status == $status | length }
  print $"(do $count installed) installed, (do $count present) already present, (do $count failed) failed, (do $count unavailable) unavailable"

  (do $count failed) == 0
}

# Expands mounts of the current platform into individual source -> target entries.
def mount-entries [ctx: record, configs: list<string>]: nothing -> list<record> {
  let mounts = $ctx.manifest.mounts? | default {}
  let unknown = $configs | where $it not-in ($mounts | columns)
  if ($unknown | is-not-empty) {
    error make --unspanned { msg: $"unknown mounts: ($unknown | str join ', ')" }
  }

  let names = if ($configs | is-empty) { $mounts | columns } else { $configs }
  let windows = $ctx.platform == "windows"
  let normalize = {|path| if $windows { $path | str replace --all '/' '\' } else { $path } }

  $names | each {|name|
    let value = $mounts | get $name | get -o $ctx.platform
    if $value == null {
      if ($configs | is-not-empty) {
        warn $"($name) has no mount on ($ctx.platform), skipping"
      }
      return []
    }

    let items = if ($value | is-list) { $value } else { [$value] }
    $items | each {|item|
      let spec = match ($item | describe) {
        "bool" => ({})
        "string" => {target: $item}
        _ => $item
      }
      let source = $repo | path join configs ($spec.source? | default $name) | do $normalize $in
      let target = $spec.target? | default ($ctx.platform_spec.config? | default "" | path join $name) | path expand --no-symlink | do $normalize $in
      let placeholders = {source: $source, target: $target, repo: $repo}
      {
        config: $name
        source: $source
        target: $target
        mode: (if $spec.run? != null { "command" } else { $spec.mode? | default "link" })
        check: ($spec.check? | fill $placeholders)
        run: ($spec.run? | fill $placeholders)
        undo: ($spec.undo? | fill $placeholders)
      }
    }
  } | flatten
}

def link-of [path: string]: nothing -> any {
  if ($path | path type) == "symlink" { ls --long --directory $path | get 0.target } else { null }
}

def same-path [left: string, right: string]: nothing -> bool {
  let clean = {|path| $path | str replace --regex '^\\\\\?\\' '' | path expand --no-symlink }
  (do $clean $left) == (do $clean $right)
}

# State of a mount: mounted, unmounted, conflict (something else is there) or unknown.
def mount-state [ctx: record, entry: record]: nothing -> string {
  if $entry.mode == "command" {
    if $entry.check == null { return "unknown" }
    return (if (succeeds $ctx.shell $entry.check) { "mounted" } else { "unmounted" })
  }

  if not ($entry.target | path exists --no-symlink) {
    return "unmounted"
  }
  if $entry.mode == "copy" {
    let same = ($entry.target | path type) == "file" and (open --raw $entry.target) == (open --raw $entry.source)
    return (if $same { "mounted" } else { "conflict" })
  }
  let link = link-of $entry.target
  if $link != null and (same-path $link $entry.source) { "mounted" } else { "conflict" }
}

def remove-link [ctx: record, path: string] {
  # junctions are removed with rmdir, which keeps the linked directory intact
  if $ctx.platform == "windows" and (^cmd /c rmdir $path | complete).exit_code == 0 {
    return
  }
  rm $path
}

def make-link [ctx: record, source: string, target: string]: nothing -> bool {
  let result = if $ctx.platform != "windows" {
    ^ln -s $source $target | complete
  } else if ($source | path type) == "dir" {
    ^cmd /c mklink /J $target $source | complete
  } else {
    ^cmd /c mklink $target $source | complete
  }
  if $result.exit_code != 0 {
    warn ($result.stderr + $result.stdout | str trim)
    if $ctx.platform == "windows" {
      warn "file symlinks on windows need Developer Mode or an elevated shell"
    }
  }
  $result.exit_code == 0
}

def mount-one [ctx: record, entry: record]: nothing -> string {
  let state = mount-state $ctx $entry
  if $state == "mounted" {
    return "present"
  }
  if $entry.mode == "command" {
    return (if (run $ctx.shell $entry.run) { "mounted" } else { "failed" })
  }

  try {
    if $state == "conflict" {
      if ($entry.target | path type) == "symlink" { remove-link $ctx $entry.target } else { rm --recursive --force $entry.target }
    }
    mkdir ($entry.target | path dirname)
    if $entry.mode == "copy" {
      cp $entry.source $entry.target
      "mounted"
    } else if (make-link $ctx $entry.source $entry.target) {
      "mounted"
    } else {
      "failed"
    }
  } catch {|error|
    warn $"($entry.config): ($error.msg)"
    "failed"
  }
}

def unmount-one [ctx: record, entry: record]: nothing -> string {
  if $entry.mode == "command" {
    if $entry.undo == null {
      warn $"($entry.config) has no undo command"
      return "skipped"
    }
    if $entry.check != null and not (succeeds $ctx.shell $entry.check) {
      return "absent"
    }
    return (if (run $ctx.shell $entry.undo) { "unmounted" } else { "failed" })
  }

  match (mount-state $ctx $entry) {
    "unmounted" => "absent"
    "conflict" => {
      warn $"($entry.target) is not managed by this repo, leaving it alone"
      "skipped"
    }
    _ => {
      try {
        if $entry.mode == "copy" { rm $entry.target } else { remove-link $ctx $entry.target }
        "unmounted"
      } catch {|error|
        warn $"($entry.config): ($error.msg)"
        "failed"
      }
    }
  }
}

def mount-plan [ctx: record, configs: list<string>, action: string]: nothing -> list<record> {
  let entries = mount-entries $ctx $configs
  info $"($action) plan for ($ctx.platform)"
  print (
    $entries
    | each {|entry|
      let target = if $entry.mode == "command" { "" } else { $entry.target }
      {config: $entry.config, target: $target, mode: $entry.mode, state: (mount-state $ctx $entry)}
    }
    | table --index false
  )
  $entries
}

def mount-run [ctx: record, entries: list<record>, action: string]: nothing -> bool {
  let results = $entries | each {|entry|
    let status = if $action == "mount" { mount-one $ctx $entry } else { unmount-one $ctx $entry }
    {config: $entry.config, target: $entry.target, status: $status}
  }

  info $"($action) summary"
  print ($results | where status not-in [mounted unmounted] | sort-by status config)
  let count = {|status| $results | where status == $status | length }
  print $"(do $count $"($action)ed") ($action)ed, (do $count present) already present, (do $count absent) absent, (do $count skipped) skipped, (do $count failed) failed"

  (do $count failed) == 0
}

# Install packages from the manifest using the best package manager per system.
def "main install" [
  ...packages: string     # packages to install (all relevant to the system when omitted)
  --manifest (-m): path   # manifest to read
  --system (-s): string   # system profile to use instead of detecting it
  --prefer (-p): string   # manager to try first for every package
  --dry-run (-n)          # print the install plan without installing anything
] {
  let ctx = load $manifest $system | insert prefer ($prefer | as-list)
  if $prefer != null and $prefer not-in $ctx.managers {
    warn $"`($prefer)` is not available on ($ctx.system), ignoring --prefer"
  }

  let plan = install-plan $ctx $packages
  if $dry_run {
    return
  }
  activate $ctx
  if not (install-run $ctx $plan) {
    exit 1
  }
}

# Link configs from the repo to the locations the apps read them from.
def "main mount" [
  ...configs: string      # configs to mount (all mounts of the platform when omitted)
  --manifest (-m): path   # manifest to read
  --system (-s): string   # system profile to use instead of detecting it
  --dry-run (-n)          # print the mount plan without changing anything
] {
  let ctx = load $manifest $system
  let entries = mount-plan $ctx $configs mount
  if $dry_run {
    return
  }
  activate $ctx
  if not (mount-run $ctx $entries mount) {
    exit 1
  }
}

# Remove config links created by `mount`, leaving anything else untouched.
def "main unmount" [
  ...configs: string      # configs to unmount (all mounts of the platform when omitted)
  --manifest (-m): path   # manifest to read
  --system (-s): string   # system profile to use instead of detecting it
  --dry-run (-n)          # print the unmount plan without changing anything
] {
  let ctx = load $manifest $system
  let entries = mount-plan $ctx $configs unmount
  if $dry_run {
    return
  }
  activate $ctx
  if not (mount-run $ctx $entries unmount) {
    exit 1
  }
}

# Bootstrap the system: install all packages, then mount all configs.
def main [
  --manifest (-m): path   # manifest to read
  --system (-s): string   # system profile to use instead of detecting it
  --prefer (-p): string   # manager to try first for every package
  --dry-run (-n)          # print the plans without changing anything
] {
  let ctx = load $manifest $system | insert prefer ($prefer | as-list)
  let plan = install-plan $ctx []
  let entries = mount-plan $ctx [] mount
  if $dry_run {
    return
  }
  activate $ctx
  let installed = install-run $ctx $plan
  let mounted = mount-run $ctx $entries mount
  if not ($installed and $mounted) {
    exit 1
  }
}
