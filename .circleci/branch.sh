#!/usr/bin/env bash
set -e

BRANCH="$CIRCLE_BRANCH"

FOLDER=$(dirname "$0")

# Sets defaults
cp "${FOLDER}/dev.env" ~/.env

# TODO: For now this replays on top
# of the dev env for cost purposes
if [ "$BRANCH" == "master" ]
then
    cp "${FOLDER}/pub.env" ~/.env
fi

# shellcheck source=/dev/null
source ~/.env

# Prints to screen for debugging
cat ~/.env
