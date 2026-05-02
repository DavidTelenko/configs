#!/usr/bin/env bash

link() {
  echo "link $HOME/.config/$1 -> $(pwd)/$1"
  ln -sfn "$(pwd)/$1" "$HOME/.config/$1"
}

link alacritty
link cmus
link dunst
link foot
link ghostty
link hypr
link kitty
link mpv
link nushell
link nvim
link rofi
link ttyper
link waybar
link wezterm
link zellij
link helix
