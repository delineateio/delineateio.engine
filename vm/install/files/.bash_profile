#!/usr/bin/env bash

source /etc/skel/.bashrc # Maintains colours :)
source /etc/environment # Resets PATH

# Activates the the venv if exists
if test -f "$HOME/project/.venv/bin/activate"; then
    # shellcheck source=/dev/null
    source "$HOME/project/.venv/bin/activate"
fi

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
export WARN="$(tput setaf 1)"
# shellcheck disable=SC2155
export DETAIL="$(tput setaf 6)"
# shellcheck disable=SC2155
export RESET="$(tput sgr0)"

# Defaults - enable compiled app
export DIO_ENV=dev
export DIO_LOCATION=../config
export DIO_VARS=${HOME}/project/.circleci/terraform

# shellcheck disable=SC2046
chmod +x $(find . -type f -name "*.sh")

# Ensures starship prompt used
eval "$(starship init bash)"

# Starts SSH sessions in the project folder and enables scripts
cd ~/project || return
clear
