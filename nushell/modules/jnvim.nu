export def main [
  --since: datetime  # Start time (default: 1 hour ago)
  --until: datetime  # End time (default: now)
  --unit: string     # Filter by systemd unit (optional)
  --priority: string # Filter by priority: emerg, alert, crit, err, warning, notice, info, debug
] {
    # Apply defaults for datetime parameters
    let since_time = ($since | default ((date now) - 1hr))
    let until_time = ($until | default (date now))

    # Format datetime to string that journalctl accepts
    let since_str = ($since_time | format date "%Y-%m-%d %H:%M:%S")
    let until_str = ($until_time | format date "%Y-%m-%d %H:%M:%S")

    # Build journalctl arguments
    mut args = ["--no-pager" "--since" $since_str "--until" $until_str]

    # Add optional filters
    if ($unit != null) {
        $args = ($args | append ["-u" $unit])
    }

    if ($priority != null) {
        $args = ($args | append ["-p" $priority])
    }

    # Execute journalctl and pipe output to nvim using native pipeline
    ^journalctl ...$args | ^nvim -R -
}
