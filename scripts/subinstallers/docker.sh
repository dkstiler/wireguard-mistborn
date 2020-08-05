#!/bin/bash

# Docker
figlet "Mistborn: Installing Docker"

sudo apt update
sudo -E apt install -y python python3-pip python3-setuptools libffi-dev python3-dev libssl-dev

if [ "$DISTRO" == "ubuntu" ] && [ "$VERSION_ID" == "20.04" ]; then
    echo "Automated Docker install"
    sudo -E apt-get install -y docker-compose
else
    echo "Manual Docker installation"
    source ./scripts/subinstallers/docker_manual.sh
fi

# set docker-compose path used in Mistborn
if [ ! -f /usr/local/bin/docker-compose ]; then
    sudo -E ln -s $(which docker-compose) /usr/local/bin/docker-compose
fi
