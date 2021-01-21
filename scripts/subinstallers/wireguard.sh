#!/bin/bash

figlet "Mistborn: Installing Wireguard"

# if wireguard not in current repositories
if ! $(sudo apt-cache show wireguard > /dev/null 2>&1) ; then
    # install PPAs

    echo "Adding Wireguard PPAs"

    # Wireguard
    if [ "$DISTRO" == "raspbian" ] || [ "$DISTRO" == "raspios" ]; then
        echo "Adding Wireguard repo keys"
        sudo -E apt-get install -y dirmngr
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 8B48AD6246925553
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 7638D0442B90D010
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 04EE7237B7D453EC
        sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 648ACFD622F3D138 
    fi

    if [ "$DISTRO" == "ubuntu" ]; then
        # Ubuntu	
        sudo add-apt-repository -y ppa:wireguard/wireguard
    elif [ "$DISTRO" == "debian" ] || [ "$DISTRO" == "raspbian" ] || [ "$DISTRO" == "raspios" ]; then
        # Debian
        sudo bash -c 'echo "deb http://deb.debian.org/debian/ unstable main" > /etc/apt/sources.list.d/unstable.list'
        sudo bash -c "printf 'Package: *\nPin: release a=unstable\nPin-Priority: 90\n' > /etc/apt/preferences.d/limit-unstable"
    fi
fi

echo "Installing Wireguard"
sudo apt-get update
sudo -E apt-get install -y openresolv wireguard
