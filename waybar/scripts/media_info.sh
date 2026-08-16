#!/usr/bin/env bash

# Requires: playerctl

__esc() {
  sed 's/"/\\"/g'
}

get() {
  local status_upper
  status_upper="$(playerctl status)"
  local status="${status_upper,,}"

  if [[ $status == stopped ]]; then
    echo "{ "\"class\": \"stopped"\" }"
    return
  fi

  local artist=$(echo $(playerctl metadata -f "{{ artist }}") | __esc)
  local title=$(echo $(playerctl metadata -f "{{ title }}") | __esc)
  local artist_title=$(echo $(playerctl metadata -f "{{ artist }} - {{ title }}") | __esc)
  local album=$(echo $(playerctl metadata -f "{{ album }}") | __esc)

  if [[ $status == playing && $1 != simple ]]; then
    local current_position=$(playerctl metadata -f "{{ position }}")
    local total_length=$(playerctl metadata -f "{{ mpris:length }}")

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
