#!/usr/bin/env bash

red() {
  echo "<span color='#fb4934'>$@</span>"
}
green() {
  echo "<span color='#b8bb26'>$@</span>"
}
yellow() {
  echo "<span color='#fabd2f'>$@</span>"
}
blue() {
  echo "<span color='#83a598'>$@</span>"
}
purple() {
  echo "<span color='#d3869b'>$@</span>"
}
aqua() {
  echo "<span color='#8ec07c'>$@</span>"
}
gray() {
  echo "<span color='#928374'>$@</span>"
}
orange() {
  echo "<span color='#fe8019'>$@</span>"
}

h() {
  echo $(orange "<big>$@</big>")
}

cmd() {
  echo $(purple $@)
}

W=" "
S="󰘶 "
C="󰘳 "
R="󰌑 "
T="󰌒 "
E="󱁐 "
n="{$(green n)}"
opened="$HOME/.config/hypr/scripts/data/cheatsheet_opened"

if [[ ! -z $(cat $opened) ]]; then
  notify-send -t 1 -r 777 " " # just to close opened cheat sheet
  echo "" >$opened
  exit
fi

echo 1 >$opened

notify-send -t 0 -r 777 " 󰋗 Cheat Sheet $W$S/" \
  """
 $(h  Manager)
 $(cmd $W X) - Close Window         $(cmd $W $T) - Open Windows List
 $(cmd $W F) - Fullscreen Window    $(cmd $W $R) - Launch Terminal
 $(cmd $W R) - Open App Launcher    $(cmd $W $S P) - Launch Color Picker
 $(cmd $W C) - Open Clipboard Menu  $(cmd $W $S W) - Close All Notifications
 $(cmd $W W) - Toggle Bar           $(cmd $W $C W) - Reload Bar
 $(cmd $W "$n") - Select $n Workspace
 $(cmd $W $S "$n") - Move Window to $n Workspace
 $(cmd $W $S /) - Toggle Cheat Sheet

 $(h 󰍹 System)
 $(cmd $W M) - Mute Volume   $(purple $W $S M) - Mute Microphone
 $(cmd $W V) - Volume Up     $(purple $W $S V) - Volume Down
 $(cmd $W I) - Mic Volume Up $(purple $W $S I) - Mic Volume Down
 $(cmd $W B) - Brightness Up $(purple $W $S B) - Brightness Down

 $(h  Player)
 $(cmd $W P) - Play / Pause
 $(cmd $W N) - Next Track        $(cmd $W $S N) - Previous Track
 $(cmd $W .) - Rewind +5 Seconds $(cmd $W $S .) - Next Source
 $(cmd $W ,) - Rewind -5 Seconds $(cmd $W $S ,) - Prev Source

 $(h  Session)                      $(h  Capture)
 $(cmd $W $C L) - Lock Machine             $(cmd $W S) - Fullscreen Screenshot
 $(cmd $W $S Q) - Suspend Machine (sleep)  $(cmd $W $S S) - Area Screenshot
 $(cmd $W $S O) - Turn-Off Screen          $(cmd $W $C S) - Window Screenshot
 $(cmd $W $S O) - Turn-On Screen           $(cmd $W $S D) - Fullscreen Record
"""
