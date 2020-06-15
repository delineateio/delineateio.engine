#!/usr/bin/env bash
set -e

# Picks up args
ROOT="$(git rev-parse --show-toplevel)"

# Changes platform
cd "${ROOT}/ops"

# Sources env variables
 # shellcheck source=/dev/null
source variables.env

# Runs terraform
terraform validate
terraform destroy -lock=true -refresh=true -auto-approve 