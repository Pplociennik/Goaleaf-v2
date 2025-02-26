#!/bin/bash

# This script is used to prepare the development environment for the project.
# It will download repositories of all the microservices.
# The repositories will be downloaded in the main directory in such an order:
#    1. glf-configServer
#    2. glf-servicediscovery
#    3. glf-api-gateway
#    4. glf-accounts
#    5. glf-communities

# Requirements:
#    1. Git should be installed on the system.
#    2. The system should have access to the internet.

# These are the variables that will be used in the script.
HOME_DIR=$(pwd)
DEBUG=false

# A git installation. If git is available in the system path, just use 'git'.
GIT=git

# The repositories to be cloned.
CONFIG_SERVER_REPO=https://github.com/Pplociennik/glf-config-server.git
SERVICE_DISCOVERY_REPO=https://github.com/Pplociennik/glf-servicediscovery.git
API_GATEWAY_REPO=https://github.com/Pplociennik/glf-api-gateway.git
ACCOUNTS_REPO=https://github.com/Pplociennik/glf_accounts.git
COMMUNITIES_REPO=https://github.com/Pplociennik/glf_communities.git

# The directories where the repositories will be cloned.
CONFIG_SERVER_DIR=glf-configServer
SERVICE_DISCOVERY_DIR=glf-servicediscovery
API_GATEWAY_DIR=glf-api-gateway
ACCOUNTS_DIR=glf-accounts
COMMUNITIES_DIR=glf-communities

# Branches/Tags to checkout.
CONFIG_SERVER_BRANCH=main
SERVICE_DISCOVERY_BRANCH=main
API_GATEWAY_BRANCH=main
ACCOUNTS_BRANCH=main
COMMUNITIES_BRANCH=main

# Temporary directory for cloning
TEMP_DIR=$HOME_DIR/.temp

# Target directory for moving the cloned repositories
TARGET_DIR=../../../../..

log() {
    echo "[INFO] $*"
}

debug() {
    if [ "$DEBUG" = true ]; then
        echo
        echo "[DEBUG] $*"
    fi
}

error() {
    echo "[ERROR] $*"
    exit 1
}

checkAndClone() {
    debug "Function 'checkAndClone' called with parameters $*"
    if [ -d "$TARGET_DIR/$2" ]; then
        log "$3 already exists in the target directory. Skipping clone."
    else
        clone "$1" "$2" "$3"
        moveRepo "$2"
    fi
    debug "Function 'checkAndClone' finished."
}

clone() {
    debug "Function 'clone' called with parameters $*"
    log "Cloning $3..."
    $GIT clone "$1" "$2" || error "Failed to clone $3"
    log "$3 has been cloned successfully."
    debug "Function 'clone' finished."
}

moveRepo() {
    debug "Function 'moveRepo' called with parameters $*"
    log "Moving $1 to target directory..."
    mv "$1" "$TARGET_DIR" || error "Failed to move $1"
    log "$1 has been moved successfully."
    debug "Function 'moveRepo' finished."
}

switchDirectory() {
    debug "Switching to $1"
    cd "$1" || error "Failed to switch to directory $1"
    debug "Switched to $(pwd)"
}

log "Preparing the development environment for the project..."

# Create temporary directory
if [ -d "$TEMP_DIR" ]; then
    log "Removing the existing temporary directory..."
    rm -rf "$TEMP_DIR" || error "Failed to remove temporary directory"
fi
log "Creating temporary directory..."
mkdir "$TEMP_DIR" || error "Failed to create temporary directory"

switchDirectory "$TEMP_DIR"

# Config Server
checkAndClone "$CONFIG_SERVER_REPO" "$CONFIG_SERVER_DIR" "ConfigServer"

# Service Discovery
checkAndClone "$SERVICE_DISCOVERY_REPO" "$SERVICE_DISCOVERY_DIR" "ServiceDiscovery"

# API Gateway
checkAndClone "$API_GATEWAY_REPO" "$API_GATEWAY_DIR" "ApiGateway"

# Accounts
checkAndClone "$ACCOUNTS_REPO" "$ACCOUNTS_DIR" "Accounts"

# Communities
checkAndClone "$COMMUNITIES_REPO" "$COMMUNITIES_DIR" "Communities"

# Clean up temporary directory
switchDirectory "$HOME_DIR"
log "Cleaning up temporary directory..."
rm -rf "$TEMP_DIR" || error "Failed to clean up temporary directory"

log "The development environment has been prepared successfully."

if [ "$DEBUG" = true ]; then
    exit 0
else
    exec bash
fi