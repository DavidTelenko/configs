#!/usr/bin/env bash

# Requires: playerctl, ~/.config/hypr/scripts/player_manager.sh

__esc() {
  sed 's/"/\\"/g'
}

get() {
  local player=$($HOME/.config/hypr/scripts/player_manager.sh get)

  local status_upper="$(playerctl -p $player status)"
  local status="${status_upper,,}"

  if [[ $status == stopped ]]; then
    echo "{ "\"class\": \"stopped"\" }"
    return
  fi

  local artist=$(echo $(playerctl -p $player metadata -f "{{ artist }}") | __esc)
  local title=$(echo $(playerctl -p $player metadata -f "{{ title }}") | __esc)
  local artist_title=$(echo $(playerctl -p $player metadata -f "{{ artist }} - {{ title }}") | __esc)
  local album=$(echo $(playerctl -p $player metadata -f "{{ album }}") | __esc)

  if [[ $status == playing && $1 != simple ]]; then
    local current_position=$(playerctl -p $player metadata -f "{{ position }}")
    local total_length=$(playerctl -p $player metadata -f "{{ mpris:length }}")

    local progress=$(echo $current_position $total_length |
      awk '{printf "%f", $1 / ($2 + 1) * 10}')
    progress=${progress%%.*}

    local class="\"class\": \"$status-$progress\""
  else
    local class="\"class\": \"$status"\"
  fi

  echo {\"text\": \"$artist_title\", \
    \"alt\": \"$status\", \
    \"tooltip\": "\"$title\n$artist\n$album\"", \
    $class}
}

can() {
  if [[ $(playerctl status) == Stopped ]]; then
    return 1
  fi
  return 0
}

"$@"
