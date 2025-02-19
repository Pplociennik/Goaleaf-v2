#!/bin/bash

# This script is used to build the libraries needed for the PP projects.
# The libraries are built in the following order:
#    1. pp-base
#    2. pp-commons
#    3. pp-modinfo

# Requirements:
#    1. Git installed and available in the PATH.
#    2. Maven installed and available in the PATH.
#    3. The path to the local maven repository must be provided.
#    4. The branches/tags to be built must be provided.

# Environment:

# A path to the local installation of Maven (if not available in the PATH). Use 'mvn' if Maven is available in the PATH.
MVN=mvn
# A path to the local Git installation (if not available in the PATH). Use 'git' if Git is available in the PATH.
GIT=git

# A path to the local maven repository.
MAVEN_REPO=/home/przemek/.m2/repository
# The branches/tags to be built.
PP_BASE_BRANCH_OR_TAG=master
PP_COMMONS_BRANCH_OR_TAG=master
PP_MODINFO_BRANCH_OR_TAG=master

# These are constants used in the script:
HOME=$(pwd)
TEMP_DIR=$HOME/.temp

# These are the paths to the libraries' repositories:
PP_BASE_REPO=https://github.com/Pplociennik/pp-base.git
PP_COMMONS_REPO=https://github.com/Pplociennik/pp-commons.git
PP_MODINFO_REPO=https://github.com/Pplociennik/pp-modinfo.git

log() {
    echo "[INFO] $*"
}

error() {
    echo "[ERROR] $*"
    exit 1
}

build() {
    $MVN clean install -Dmaven.repo.local=$MAVEN_REPO -DskipTests || error "Build failed"
}

log "Building the libraries needed for the PP projects..."

# ---------------- First remove temporary directories, if they exist ----------------

if [ -d "$TEMP_DIR" ]; then
    log "Removing the existing temporary directories..."
    rm -rf "$TEMP_DIR" || error "Failed to remove temporary directories"
fi

# ---------------- Create temporary directories ----------------

log "Creating temporary directories..."
mkdir -p "$TEMP_DIR" || error "Failed to create temporary directories"

# ---------------- Clone the repositories ----------------

log "Cloning the repositories..."

log "Cloning pp-base..."
$GIT clone $PP_BASE_REPO $TEMP_DIR/pp-base || error "Failed to clone pp-base"

log "Cloning pp-commons..."
$GIT clone $PP_COMMONS_REPO $TEMP_DIR/pp-commons || error "Failed to clone pp-commons"

log "Cloning pp-modinfo..."
$GIT clone $PP_MODINFO_REPO $TEMP_DIR/pp-modinfo || error "Failed to clone pp-modinfo"

# ---------------- Switch to the specified branches/tags ----------------

log "Switching to the specified branches/tags..."

log "Switching to branch/tag $PP_BASE_BRANCH_OR_TAG in pp-base..."
cd $TEMP_DIR/pp-base || error "Failed to change directory to pp-base"
$GIT checkout $PP_BASE_BRANCH_OR_TAG || error "Failed to checkout branch/tag $PP_BASE_BRANCH_OR_TAG in pp-base"

log "Switching to branch/tag $PP_COMMONS_BRANCH_OR_TAG in pp-commons..."
cd $TEMP_DIR/pp-commons || error "Failed to change directory to pp-commons"
$GIT checkout $PP_COMMONS_BRANCH_OR_TAG || error "Failed to checkout branch/tag $PP_COMMONS_BRANCH_OR_TAG in pp-commons"

log "Switching to branch/tag $PP_MODINFO_BRANCH_OR_TAG in pp-modinfo..."
cd $TEMP_DIR/pp-modinfo || error "Failed to change directory to pp-modinfo"
$GIT checkout $PP_MODINFO_BRANCH_OR_TAG || error "Failed to checkout branch/tag $PP_MODINFO_BRANCH_OR_TAG in pp-modinfo"

# ---------------- Build the libraries ----------------
log "Building pp-base..."
cd $TEMP_DIR/pp-base || error "Failed to change directory to pp-base"
build

log "Building pp-commons..."
cd $TEMP_DIR/pp-commons || error "Failed to change directory to pp-commons"
build

log "Building pp-modinfo..."
cd $TEMP_DIR/pp-modinfo || error "Failed to change directory to pp-modinfo"
build

# ---------------- Clean up ----------------

cd $HOME || error "Failed to change directory to home"
rm -rf $TEMP_DIR || error "Failed to remove temporary directories"

# ---------------- Done ----------------

log "Building the libraries completed successfully."