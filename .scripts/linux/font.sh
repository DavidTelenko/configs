#!/usr/bin/env bash

fonts="$HOME/.local/share/fonts"
font="RobotoMono"

mkdir -p $fonts
pushd $fonts || {
  echo "$fonts does not exist"
  exit
}

curl -OL https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/$font.zip
unar -d $font.zip
rm $font.zip

popd
