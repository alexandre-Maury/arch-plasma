#!/bin/bash

# script system.sh

##############################################################################
## Fichier de configuration interne, ne pas modifier       
# https://github.com/ChrisTitusTech/ArchTitus/blob/main/scripts/0-preinstall.sh                                                    
##############################################################################

LOG_FILES_INSTALL="$TARGET_DIR/installation/install."$(date +%d%m%Y.%H%M)".log"

mkdir -p "${HOME}/.local/share/plasma/desktoptheme"
mkdir -p "${HOME}/.local/share/kdecoration"
mkdir -p "${HOME}/.local/share/color-schemes"
mkdir -p "${HOME}/.local/share/icons"
mkdir -p "${HOME}/.local/share/fonts"

mkdir -p "${HOME}/.local/bin"
mkdir -p "$TARGET_DIR/installation"
mkdir -p "$TARGET_DIR/tmp"








