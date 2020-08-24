#!/bin/bash

#### ENV file

VAR_FILE=/opt/mistborn/.env

source /opt/mistborn/scripts/subinstallers/platform.sh

MISTBORN_DNS_BIND_IP="10.2.3.1"
#if [ "$DISTRO" == "ubuntu" ] && [ "$VERSION_ID" == "20.04" ]; then
#    MISTBORN_DNS_BIND_IP="10.2.3.1"
#fi

echo "MISTBORN_DNS_BIND_IP=${MISTBORN_DNS_BIND_IP}" | sudo tee ${VAR_FILE}
sudo chown mistborn:mistborn ${VAR_FILE}

GIT_BRANCH=$(git -C /opt/mistborn symbolic-ref --short HEAD || echo "master")
MISTBORN_TAG="latest"
if [ "$GIT_BRANCH" != "master" ]; then
    MISTBORN_TAG="test"
fi

echo "MISTBORN_TAG=$MISTBORN_TAG" | sudo tee -a ${VAR_FILE}

#### install and base services
iface=$(ip -o -4 route show to default | egrep -o 'dev [^ ]*' | awk 'NR==1{print $2}')

# default interface
sudo cp /opt/mistborn/scripts/services/Mistborn* /etc/systemd/system/
sudo find /etc/systemd/system/ -type f -name 'Mistborn*' | xargs sudo sed -i "s/User=root/User=$USER/"
#sudo find /etc/systemd/system/ -type f -name 'Mistborn*' | xargs sudo sed -i "s/ root:root / $USER:$USER /"
sudo find /etc/systemd/system/ -type f -name 'Mistborn*' | xargs sudo sed -i "s/DIFACE/$iface/"

sudo systemctl daemon-reload