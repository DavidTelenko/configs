#!/usr/bin/env nu

# Installs packages described in `platform/.manifest.yaml` with the preferred
# package manager available on the current system.

const default_manifest = path self .manifest.yaml

const entry_fields = [name repo check run]

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

def index-of [value: any]: list -> int {
  $in | enumerate | where item == $value | get -o 0.index | default (-1)
}

# Runs a command in the platform shell with its output attached to the terminal.
def run [shell: list<string>, command: string]: nothing -> bool {
  try { ^($shell | first) ...($shell | skip 1) $command; true } catch { false }
}

# Runs a command in the platform shell silently, used for `check` commands.
def succeeds [shell: list<string>, command: string]: nothing -> bool {
  (^($shell | first) ...($shell | skip 1) $command | complete).exit_code == 0
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
    "bool" => {}
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

def unknown-fields [path: string, value: any, allowed: list<string>]: nothing -> list<string> {
  if not ($value | is-record) {
    return [$"($path): expected a mapping"]
  }
  $value | columns | where $it not-in $allowed | each {|field| $"($path): unknown field `($field)`" }
}

def validate [manifest: record]: nothing -> list<string> {
  let platforms = $manifest.platforms? | default {} | columns
  let managers = $manifest.managers? | default {} | columns
  let systems = $manifest.systems? | default {} | columns
  let packages = $manifest.packages? | default {} | columns
  mut errors = unknown-fields "manifest" $manifest [platforms systems managers packages]

  for platform in ($manifest.platforms? | default {} | transpose name spec) {
    $errors = $errors ++ (unknown-fields $"platforms.($platform.name)" $platform.spec [shell prepare path])
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

  if $manager == null {
    return {package: $package, manager: null, name: null, repos: [], check: null, run: null}
  }

  let command_only = ($ctx.manifest.managers | get $manager | get -o install) == null
  {package: $package, manager: $manager} | merge (normalize-entry $package ($spec | get $manager) $command_only)
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
  let pending = $items | where package not-in ($present | get package)
  mut results = $present | each {|item| do $result $item present }

  for item in ($pending | where run != null) {
    $results = $results | append (do $result $item (if (run $shell $item.run) { "installed" } else { "failed" }))
  }

  let regular = $pending | where run == null
  if ($regular | is-empty) {
    return $results
  }

  let batch = $spec.install | str contains '{pkgs}'
  let batch_ok = $batch and (run $shell ($spec.install | str replace --all '{pkgs}' ($regular | get name | str join ' ')))

  if $batch_ok {
    return ($results ++ ($regular | each {|item| do $result $item installed }))
  }
  if $batch {
    warn $"batch install with ($manager) failed, retrying one by one"
  }

  for item in $regular {
    let command = $spec.install | str replace --all '{pkgs}' $item.name | str replace --all '{pkg}' $item.name
    $results = $results | append (do $result $item (if (run $shell $command) { "installed" } else { "failed" }))
  }

  $results
}

# Install packages from the manifest using the best package manager per system.
def main [
  ...packages: string     # packages to install (all relevant to the system when omitted)
  --manifest (-m): path   # manifest to read
  --system (-s): string   # system profile to use instead of detecting it
  --prefer (-p): string   # manager to try first for every package
  --dry-run (-n)          # print the install plan without installing anything
] {
  let manifest_path = $manifest | default $default_manifest | path expand
  let manifest = open $manifest_path
  let schema_path = $manifest_path | path dirname | path join .manifest.schema.json

  mut errors = validate $manifest
  if ($errors | is-empty) and ($schema_path | path exists) {
    $errors = validate-schema $manifest (open $schema_path)
  }
  if ($errors | is-not-empty) {
    $errors | each {|error| print $"(ansi red_bold)error:(ansi reset) ($error)" }
    error make --unspanned { msg: "invalid manifest" }
  }

  let system = $system | default (detect-system $manifest)
  if $system not-in ($manifest.systems | columns) {
    error make --unspanned { msg: $"unknown system `($system)`, expected one of: ($manifest.systems | columns | str join ', ')" }
  }

  let system_spec = $manifest.systems | get $system
  let platform = $manifest.platforms | get $system_spec.platform
  let ctx = {
    manifest: $manifest
    system: $system
    platform: $system_spec.platform
    shell: $platform.shell
    managers: $system_spec.managers
    prefer: ($prefer | as-list)
  }
  if $prefer != null and $prefer not-in $ctx.managers {
    warn $"`($prefer)` is not available on ($system), ignoring --prefer"
  }

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

  let plan_errors = check-plan $ctx $plan
  if ($plan_errors | is-not-empty) {
    $plan_errors | each {|error| print $"(ansi red_bold)error:(ansi reset) ($error)" }
    error make --unspanned { msg: "cannot build install plan" }
  }

  let available = $plan | where manager != null
  let unavailable = $plan | where manager == null

  info $"install plan for ($system)"
  print (
    $available
    | select package manager name repos
    | update repos { str join ' ' }
    | sort-by {|row| $ctx.managers | index-of $row.manager } package
    | table --index false
  )
  for item in $unavailable {
    warn $"($item.package) has no source on ($system), skipping"
  }
  if ($packages | is-empty) {
    let skipped = ($manifest.packages | columns | length) - ($relevant | length)
    print $"($available | length) to install, ($unavailable | length) unavailable, ($skipped) for other platforms"
  }

  if $dry_run {
    return
  }

  if $platform.prepare? != null and not (run $ctx.shell $platform.prepare) {
    error make --unspanned { msg: "platform prepare command failed" }
  }

  $env.PATH = $env.PATH | prepend ($platform.path? | default [] | path expand) | uniq

  mut results = $unavailable | each {|item| {package: $item.package, manager: null, name: null, status: unavailable} }
  for manager in $ctx.managers {
    let items = $available | where manager == $manager
    if ($items | is-not-empty) {
      $results = $results ++ (install-with $ctx $manager $items $results)
    }
  }

  info "summary"
  print ($results | where status != "installed" | sort-by status package)
  let failed = $results | where status == "failed"
  print $"(($results | where status == "installed" | length)) installed, (($results | where status == "present" | length)) already present, ($failed | length) failed, ($unavailable | length) unavailable"

  if ($failed | is-not-empty) {
    exit 1
  }
}
