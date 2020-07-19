#!/usr/bin/env bash
set -e

BRANCH="$CIRCLE_BRANCH"

FOLDER=$(dirname "$0")
pwd

# Sets defaults
cp "${FOLDER}/dev.env" ~/.env

# TODO: Rename 'master' to 'io'
# TODO: For now deploys master to .pub
if [ "$BRANCH" == "master" ]
then
    cp "${FOLDER}/pub.env" ~/.env
fi

# shellcheck source=/dev/null
source ~/.env

# Prints to screen for debugging
cat ~/.env
