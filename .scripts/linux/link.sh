#!/usr/bin/env bash

link() {
  echo "link $HOME/.config/$1 -> $(pwd)/$1"
  ln -sfn "$(pwd)/$1" "$HOME/.config/$1"
}

link_rc() {
  # NOTE: this is stiff but succint
  local from
  from="$(pwd)/$1/.$1rc"
  local to
  to="$HOME/.$1rc"

  echo "link $to -> $from"
  ln -sfn "$from" "$to"
}

link alacritty
link cmus
link dunst
link foot
link ghostty
link helix
link hypr
link kitty
link mpv
link nushell
link nvim
link rofi
link tmux
link ttyper
link tuicr
link vcmi
link waybar
link wezterm
link zellij

link_rc asdf
