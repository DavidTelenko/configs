#!/usr/bin/env bash

# modifying operations

sudo cp -rf ./keyd /etc/keyd
git config --global --add include.path "$(pwd)/git/.gitconfig"
gh config set editor nvim # TODO figure out if gh is installed

# systemctl

sudo systemctl enable --now keyd
sudo systemctl enable --now coolercontrold
