#!/usr/bin/env bash

usage() {
  cat <<'EOF'
Usage:
  tmux.startup.sh [OPTIONS] [QUERY...]

Options:
  --no-attach    Create sessions without attaching to the first one
  -h, --help     Show this help message

Query syntax:
  foo                 Create 1 tab for "foo"
  foo * 3             Create 3 tabs for "foo"
  3 * foo             Create 3 tabs for "foo"
  foo + bar           Create 1 tab for each query
  foo * 3 + bar * 2   Create 3 "foo" tabs and 2 "bar" tabs

Examples:
  tmux.startup.sh foo
  tmux.startup.sh foo bar
  tmux.startup.sh 'foo * 3'
  tmux.startup.sh 'foo * 3 + bar * 2'
  tmux.startup.sh '3 * foo + 2 * bar' --no-attach
EOF
}

attach=true
queries=()

for arg in "$@"; do
  case "$arg" in
  --no-attach)
    attach=false
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    queries+=("$arg")
    ;;
  esac
done

if ((${#queries[@]} == 0)); then
  usage
  exit 1
fi

first_session=""

for query in "${queries[@]}"; do
  query="${query// /}"
  IFS='+' read -ra parts <<<"$query"

  # Session name is the first zoxide query without the count.
  session_part="${parts[0]}"

  if [[ "$session_part" =~ ^[0-9]+\*(.+)$ ]]; then
    session="${BASH_REMATCH[1]}"
  elif [[ "$session_part" =~ ^(.+)\*[0-9]+$ ]]; then
    session="${BASH_REMATCH[1]}"
  else
    session="$session_part"
  fi

  [[ -z "$first_session" ]] && first_session="$session"

  first=true

  for part in "${parts[@]}"; do
    if [[ "$part" =~ ^([0-9]+)\*(.+)$ ]]; then
      count="${BASH_REMATCH[1]}"
      dir_query="${BASH_REMATCH[2]}"
    elif [[ "$part" =~ ^(.+)\*([0-9]+)$ ]]; then
      dir_query="${BASH_REMATCH[1]}"
      count="${BASH_REMATCH[2]}"
    else
      dir_query="$part"
      count=1
    fi

    dir="$(zoxide query "$dir_query")" || {
      echo "Could not find directory: $dir_query" >&2
      exit 1
    }

    if $first; then
      tmux new-session -d -s "$session" -c "$dir"
      first=false
      start=1
    else
      start=0
    fi

    for ((i = start; i < count; i++)); do
      tmux new-window -t "$session" -c "$dir"
    done
  done
done

if $attach; then
  tmux attach-session -t "$first_session"
fi
