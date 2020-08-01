#!/usr/bin/env bash
set -e

BRANCH="$CIRCLE_BRANCH"

FOLDER=$(dirname "$0")

# Sets defaults
cp "${FOLDER}/env/dev.env" ~/.env

# TODO: For now this replays on top
# of the dev env for cost purposes
if [ "$BRANCH" == "master" ]
then
    cp "${FOLDER}/env/pub.env" ~/.env
fi

# shellcheck source=/dev/null
source ~/.env

# Show values for debugging CircleCI
cat ~/.env
