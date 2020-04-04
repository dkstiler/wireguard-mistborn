#!/bin/bash

# Get OS info
# Determine OS platform
UNAME=$(uname | tr "[:upper:]" "[:lower:]")
DISTRO=""
# If Linux, try to determine specific distribution
if [ "$UNAME" == "linux" ]; then
    # use /etc/os-release to get distro 
    DISTRO=$(cat /etc/os-release | awk -F= '/^ID=/{print $2}')
fi

figlet "UNAME: $UNAME"
figlet "DISTRO: $DISTRO"
