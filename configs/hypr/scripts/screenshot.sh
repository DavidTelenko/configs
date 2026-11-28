#!/usr/bin/env bash

# Requires: grim, slurp, wf-recorder

time=$(date +%Y-%m-%d-%H-%M-%S)
rec_status_file="/tmp/recording.status"

# Safely make a directory and cd into it
__mkdir_cd() {
  if [[ ! -d $1 ]]; then
    mkdir -p $1
  fi
  cd $1
}

# Countdown with a message
__countdown() {
  for sec in $(seq $1 -1 1); do
    notify_send -t 1000 -r 777 "Taking shot in: $sec"
    sleep 1
  done
}

__shot_area='grim -t png -g "$(slurp)" $shot_file'
__shot_screen='grim -t png $shot_file'
__shot_win='grim -t png -o `xdotool getactivewindow` $shot_file'

__shot() {
  local shot_dir="$(xdg-user-dir PICTURES)/Screenshots"
  local shot_file="Screenshot_${time}.png"

  __mkdir_cd $shot_dir

  notify-send -t 1 -r 777 " " # close previous notification
  sleep 0.1
  eval $@

  cat $shot_file | wl-copy

  if [[ -e $shot_file ]]; then
    notify-send -u low -r 777 " $shot_file saved."
  fi
}

shot-win() {
  __shot $__shot_win
}

shot-area() {
  __shot $__shot_area
}

shot() {
  __shot $__shot_screen
}

__record_area='wf-recorder -c libx264 -C aac -x yuv420p -g "$(slurp)" -f $video_file'
__record_screen='wf-recorder -c libx264 -C aac -x yuv420p -f $video_file'

# waybar specific
__update_bar() {
  local $SIGNAL=1
  pkill -RTMIN+1 waybar
}

__record_detail() {
  if [[ -s $rec_status_file ]]; then
    local video_file=$(awk 'NR==1' $rec_status_file)

    killall wf-recorder

    printf "" >$rec_status_file
    notify-send -r 777 " $video_file saved."

    __update_bar
    exit
  fi

  local video_dir="$(xdg-user-dir VIDEOS)/Captures"
  local video_file="Capture_${time}.mp4"
  local log_file="$video_dir/$video_file.log"

  __mkdir_cd $video_dir

  notify-send -t 1000 -r 777 " Started"
  sleep 1.1

  eval $@ 1>$log_file 2>&1 &
  printf "%s\n%s" $video_file $log_file >$rec_status_file

  __update_bar
}

record() {
  __record_detail $__record_screen
}

record-area() {
  __record_detail $__record_area
}

# waybar specific
record-status() {
  if [[ -s $rec_status_file ]]; then
    echo '{"class": "recording"}'
  else
    echo '{"class": "idle"}'
  fi
}

"$@"
