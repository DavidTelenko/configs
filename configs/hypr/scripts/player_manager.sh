#!/usr/bin/env bash

# Requires: playerctl
# TODO: use `read` instead of `cat`

state_file="$HOME/.config/hypr/scripts/data/player_state"

if [[ ! -s $state_file ]]; then
  echo 0 >$state_file
fi

__select_source() {
  readarray -t players < <(playerctl -l)
  echo $(($1 % ${#players[@]})) >$state_file
}

next() {
  __select_source $(($(cat $state_file) + 1))
}

prev() {
  __select_source $(($(cat $state_file) - 1))
}

get() {
  local index=$(cat $state_file)

  readarray -t players < <(playerctl -l)

  if ((index >= ${#players[@]})); then
    echo 0
    return
  fi

  echo ${players[$index]}
}

"$@"
