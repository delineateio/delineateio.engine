#!/usr/bin/env bash

source /etc/skel/.bashrc # Maintains colours :)
source /etc/environment # Resets PATH

# Ensure that the $PATH is set correctly
PATH=/snap/bin:$PATH # Ensures snap in the PATH
PATH=$HOME/google-cloud-sdk/bin:$PATH # Adds gcloud to PATH
PATH=$HOME/go/bin:$PATH
PATH=$HOME/.local/bin:$PATH # Apps Pip3 modules

# Sets script wide colours
# shellcheck disable=SC2034

START=$(tput setaf 3)
export START

COMPLETE=$(tput setaf 2)
export COMPLETE

DETAIL=$(tput setaf 6)
export DETAIL

RESET=$(tput sgr0)
export RESET

# Starts SSH sessions in the project folder and enables scripts
cd ~/project || return

# TODO: This is messy - ideally done by provisioning!
# shellcheck disable=SC2046
chmod +x $(find . -type f -name "*.sh")

clear
