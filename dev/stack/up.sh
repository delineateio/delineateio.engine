#!/usr/bin/env bash
set -e

# Ensures the stack is down
docker-compose down --remove-orphans

# Stands up the stack
docker-compose up -d --quiet-pull