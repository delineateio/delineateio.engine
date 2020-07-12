#!/usr/bin/env bash

source /etc/skel/.bashrc # Maintains colours :)
source /etc/environment # Resets PATH

# Ensure that the $PATH is set correctly
PATH=/snap/bin:$PATH # Ensures snap in the PATH
PATH=$HOME/google-cloud-sdk/bin:$PATH # Adds gcloud to PATH
PATH=$HOME/go/bin:$PATH
PATH=$HOME/.local/bin:$PATH # Apps Pip3 modules

# Sets script wide colours
# shellcheck disable=SC2155
export START="$(tput setaf 3)"
# shellcheck disable=SC2155
export COMPLETE="$(tput setaf 2)"
# shellcheck disable=SC2155
export DETAIL="$(tput setaf 6)"
# shellcheck disable=SC2155
export RESET="$(tput sgr0)"

# Defaults - enable compiled app
export ENV=debug
export LOCATION=../config

# Starts SSH sessions in the project folder and enables scripts
cd ~/project || return
clear

# shellcheck disable=SC2046
chmod +x $(find . -type f -name "*.sh")

# Ensures starship prompt used
eval "$(starship init bash)"
