#!/usr/bin/env bash
set -e

###################################################################
# Script Name	: host.sh
# Description	: Configures the host after VM started
# Args          : None
# Author       	: Jonathan Fenwick
# Email         : jonathan.fenwick@delineate.io
###################################################################

# Adds
function addhost() {

    IP="${1}"
    HOSTNAME="${2}"
    HOSTS_LINE="$IP $HOSTNAME"

    sudo grep -qxF "${HOSTS_LINE}" /etc/hosts || echo "${HOSTS_LINE}" | sudo tee -a /etc/hosts > /dev/null
}

function installCARoot() {

    sudo mkcert -uninstall
    CAROOT="$(pwd)/vm/certs"
    export CAROOT
    sudo mkcert -install
}

# Adds the host entries
addhost 127.0.0.1 delineate.local

#Installs the CA
installCARoot

# Activates the virtual env
source ./.venv/bin/activate
