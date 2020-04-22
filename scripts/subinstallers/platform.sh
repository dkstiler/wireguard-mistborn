#!/bin/bash

# Get OS info
# Determine OS platform
UNAME=$(uname | tr "[:upper:]" "[:lower:]")
DISTRO=""
VERSION_ID=""
# If Linux, try to determine specific distribution
if [ "$UNAME" == "linux" ]; then
    # use /etc/os-release to get distro 
    DISTRO=$(cat /etc/os-release | awk -F= '/^ID=/{print $2}')
    VERSION_ID=$(cat /etc/os-release | awk -F= '/^VERSION_ID=/{print $2}' | tr -d '"')
fi

figlet "UNAME: $UNAME"
figlet "DISTRO: $DISTRO"
figlet "VERSION: $VERSION_ID"
