#!/usr/bin/env bash
set -e

# Picks up args
ROOT="$(git rev-parse --show-toplevel)"

# Changes platform & applies terraform
cd "$ROOT/ops"

 # shellcheck source=/dev/null
source variables.env

# Build infrastructure
terraform init 
terraform validate
terraform apply -lock=true -refresh=true -auto-approve