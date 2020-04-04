#!/bin/bash

# Cockpit
figlet "Mistborn: Installing Cockpit"
if [ "$DISTRO" == "ubuntu" ]; then
    echo "Ubuntu backports enabled by default"
    
    sudo apt-get install -y cockpit cockpit-docker

elif [ "$DISTRO" == "debian" ]; then
    sudo grep -qF "buster-backports" /etc/apt/sources.list.d/backports.list \
    && echo "buster-backports already in sources" \
    || echo 'deb http://deb.debian.org/debian buster-backports main' | sudo tee -a /etc/apt/sources.list.d/backports.list
    
    sudo apt-get install -y cockpit cockpit-docker

elif [ "$DISTRO" == "raspbian" ]; then
    
    echo "Raspbian repos contain cockpit"
    sudo apt-get install -y cockpit cockpit-docker

fi

sudo cp ./scripts/conf/cockpit.conf /etc/cockpit/cockpit.conf
sudo systemctl restart cockpit.socket

# create system cockpit user
echo "Creating cockpit user"
sudo useradd -s /bin/bash -d /home/cockpit -m -G sudo -p $(openssl passwd -1 "$MISTBORN_DEFAULT_PASSWORD") cockpit || true
